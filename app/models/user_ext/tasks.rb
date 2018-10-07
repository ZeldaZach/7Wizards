module UserExt
  module Tasks

    def uncompleted_task
      compleated = user_tasks
      
      AllTutorials.all.each do |task|
        exists = false
        compleated.each do |item|
          if item.name == task.name
            exists = true
            break
          end
        end
        
        if task.is_done?(self)
          task.done!(self)
        else
          task.set_accept_task(self)
        end
        
        return task unless exists
      end
      nil
    end

    def last_compleated
      user_task = user_tasks.order_by_id.last
      task = AllTutorials.get(user_task.name) if user_task
      task
    end

    def done_task!(name, options = {})
      task = AllTutorials.get(name)
      task.done!(self, options)
    end

    def is_done_task(name)
      task = AllTutorials.get(name)
      task.is_done?(self)
    end

    def has_task?(name)
      task = AllTutorials.get(name)
      task.has?(self)
    end
    
  end
end
