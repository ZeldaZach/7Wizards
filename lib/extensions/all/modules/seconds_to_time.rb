module Extensions
  module All
    module Modules
      module SecondsToTime

        # will return in minutes form minutes:seconds
        def seconds_to_time
          seconds = self.to_i

          minutes = seconds / 1.minute
          seconds = seconds - minutes.minutes

          "#{format_time_part(minutes)}:#{format_time_part(seconds)}"
        end

        # will return in hour form hours:minutes:seconds
        def seconds_to_full_time(show_hour = false)

          seconds = self.to_i

          minutes = seconds / 1.minute
          seconds = seconds - minutes.minutes

          hours = minutes.minutes / 1.hour
          minutes = (minutes.minutes - hours.hours) / 1.minute

          if hours > 0 || show_hour
            "#{format_time_part(hours)}:#{format_time_part(minutes)}:#{format_time_part(seconds)}"
          else
            "#{format_time_part(minutes)}:#{format_time_part(seconds)}"
          end
        end

        def seconds_to_minutes
          seconds = self.to_i
          total_minutes = seconds / 1.minute
          total_minutes.to_i
        end

        def seconds_to_hours
          seconds = self.to_i
          total_hours = seconds / 1.hour
          total_hours.to_i
        end

        def seconds_to_days
          seconds = self.to_i
          total_days = seconds / 24.hours
          total_days.to_i
        end

        private

        def format_time_part(part)
          part < 10 ? "0#{part}" : part.to_s
        end
      end
    end
  end
end