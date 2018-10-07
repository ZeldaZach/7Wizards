module Helpers
  module TimerHelper

    def timer_script(options = {})

      options[:timer_url]    ||= wizards_path :action => :reload_user_info
    
      "createTimer(#{options.to_json}); "
    end

    #timer for meditation located on home page
    def time_meditation
      user = current_user
      t = user.meditation_finished_at.nil? ? 0 : user.meditation_finished_at - Time.now

      {
        :seconds => t.to_i,
        :span_id => :meditation_timer,
        :timer_url => home_path(:action => :index_ajax),
      }
    end

    #create timer for next fight, located on top panel
    def time_fights
      user = current_user
      t = user.remaining_fight_regenerate_time
      {:seconds => t.to_i, :span_id => :top_timer}
    end

    #create timer for top panel (fights or meditation)
    def time_top_panel
      meditation = time_meditation
      fights     = time_fights

      top_time = {:seconds => 0, :span_id => :top_timer}

      if meditation[:seconds] > 0
        top_time[:seconds] = meditation[:seconds]
        return top_time
      end

      if fights[:seconds] > 0
        top_time[:seconds] = fights[:seconds]
        return top_time
      end
    
      top_time
    end

    def dragon_timer
      dragon = Dragon.current
      t = dragon.nil? ? 0 : dragon.time_left
      {:seconds => t.to_i, :span_id => :dragon_timer, :timer_url => home_path(:action => :index_ajax)}
    end

    def timers_javascript
      timers = "stopTimers();"
      timers << timer_script(time_meditation)
      timers << timer_script(time_top_panel)
      if controller_name == "home" && action_name == "index_ajax"
        timers << timer_script(dragon_timer)
      end
      javascript_tag timers
    end
  end
end
