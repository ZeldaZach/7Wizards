class AbstractTutorial

#  include Helpers::TranslateHelper
  
  def initialize(name, price = 0)
    @name  = name
    @price = price
  end
  
  def name
    @name
  end

  def price
    @price
  end

  #override
  def new
    t = UserTask.new(:name => name)
    t
  end

  #override
  def description(options = {})
    tf "#{name}_description", options
  end

  def done_description
    tf "#{name}_done_description"
  end

  def notification
    tf "#{name}_notification"
  end

  def tf(field, options = {})
    key = "#{UserTask.name.underscore}.#{field}"
    options.merge!({:scope => [:activerecord, :attributes]})
    I18n.t(key, options)
  end

  #override
  def is_done?(user = nil)
    user.tutorial_done
  end

  def has?(user)
    user.user_tasks.task_name(name).size > 0
  end

  def add(user)
    task = new_item_instance
    user.user_tasks << task
    return task
  end

  def done!(user, options = {})
    return if user.tutorial_done || !AbstractTutorial.is_started?(user)

    if !has?(user)
      if price > 0
        user.add_money!(price, name, "tasks.#{name}")
        Message.done_task(user, notification)
      end
      add user
      user.save!

      clear_accept_task(user)
    end
  end
  
  class << self
    def is_started?(user)
      !RedisCache.get("tasks_started_#{user.id}").nil?
    end

    def start(user)
      RedisCache.put("tasks_started_#{user.id}", Time.new, 1.month)
    end

    def all_tasks_completaed?(user)
      user.uncompleted_task.nil? && !user.last_compleated.nil?
    end
    
  end

  def set_accept_task(user)
    RedisCache.put("tasks_accep_#{user.id}", Time.new, 1.month)
  end

  def clear_accept_task(user)
    RedisCache.del("tasks_accep_#{user.id}")
  end
  
  def self.is_accepted_task(user)
    !RedisCache.get("tasks_accep_#{user.id}").nil?
  end

  protected

  def new_item_instance
    self.new
  end

end
