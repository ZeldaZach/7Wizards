God.watch do |w|
    w.pid_file = "/var/run/memcached.pid"
    w.name = "memcached-session"
    w.group = "server"
    w.interval = 10.seconds
#    w.start  = "/usr/bin/memcached -d -l 127.0.0.1 -p 11211 -P #{w.pid_file}"
    w.start = "/usr/bin/memcached -m 128 -p 11211 -u deploy -l 127.0.0.1 -P #{w.pid_file}"
    w.stop = "kill 'cat #{w.pid_file}'; rm #{w.pid_file}"
    w.restart = "#{w.stop}; #{w.start}"
    
    #w.start     = "/etc/init.d/memcached start"
    #w.stop      = "/etc/init.d/memcached stop"
    #w.restart   = "/etc/init.d/memcached restart"
	
    w.start_grace = 10.seconds
    w.restart_grace = 10.seconds
    w.behavior(:clean_pid_file)

    w.start_if do |start|
        start.condition(:process_running) do |c|
	    c.interval = 10.seconds
	    c.running = false
	end
     end
			    
    w.restart_if do |restart|
        restart.condition(:memory_usage) do |c|
	    c.above = 128.megabytes
	    c.times = [3, 5] # 3 out of 5 intervals
	end
		  
	restart.condition(:cpu_usage) do |c|
	    c.above = 10.percent
	    c.times = 5
	end
    end
				        
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
		      
			      
