God.watch do |w|
    w.pid_file = "/opt/redis/redis.pid"
    w.name = "redis-server"
    w.interval = 30.seconds # default
    w.start = "redis-server /opt/redis/conf/redis.conf"
    w.stop = "redis-cli shutdown"
    w.restart = "#{w.stop}; redis-server /opt/redis/conf/redis.conf"
    w.start_grace = 10.seconds
    w.restart_grace = 10.seconds

    w.behavior(:clean_pid_file)

    w.start_if do |start|
	start.condition(:process_running) do |c|
	    c.interval = 5.seconds
	    c.running = false
	end
    end

    w.restart_if do |restart|
	restart.condition(:memory_usage) do |c|
	    c.above = 300.megabytes
	    c.times = [3, 5] # 3 out of 5 intervals
	end

	restart.condition(:cpu_usage) do |c|
	    c.above = 30.percent
	    c.times = 5
	end
    end
    
# lifecycle
    w.lifecycle do |on|
	on.condition(:flapping) do |c|
	    c.to_state = [:start, :restart]
	    c.times = 5
	    c.within = 5.minute
	    c.transition = :unmonitored
	    c.retry_in = 10.minutes
	    c.retry_times = 5
	    c.retry_within = 2.hours
	end
    end
end