RAILS_ROOT = "/var/www/7wizards/current"

God.watch do |w|
    w.name = "orbited"
    w.start = "orbited --config=#{RAILS_ROOT}/config/orbited.cfg"
    w.behavior(:clean_pid_file)
    w.start_if do |start|
      start.condition(:process_running) do |c|
          c.interval = 3.seconds
          c.running = false
        end
    end
end

God.watch do |w|
    w.name = "morbid"
    w.start = "morbid"
    w.behavior(:clean_pid_file)
    w.start_if do |start|
      start.condition(:process_running) do |c|
          c.interval = 3.seconds
          c.running = false
        end
    end
end
							  