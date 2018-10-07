class Schedule::Base

  def self.redefine(clazz)
    clazz.singleton_methods(false).each do |m|

      clone = method(m).to_proc
      
      eval <<-CLAZZ
        class << clazz
          remove_method :#{m}
        end
      CLAZZ

      self.class.class_eval do
        define_method(m) do |*args|
          begin
            Dir.chdir RAILS_ROOT
            clone.call(args)
          rescue Exception => e
            if GameProperties::PROD
              ExceptionNotifier.deliver_background_exception_notification(e)
            else
              raise e
            end
          end
        end
      end
    end
  end
end
