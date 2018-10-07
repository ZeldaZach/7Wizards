module Wizards
  module HomeExt
    module Tutorials

      def refresh
        @user = current_user
        populate_task
        render_content :tutorial, {:destination => :tutorial_content}
      end
      
#      def navigate_blog_task
#        @user = current_user
#        @user.done_task!(TutorialBlog::NAME)
#        redirect_to home_path(:action => :index_ajax)
#      end

      
      def get_task
        @user = current_user
        @task  = @user.uncompleted_task
        @description = @task.description if @task
        render_content :tutorial, {:destination => :tutorial_content}
      end

      def start_tutorial
        user = current_user
        if AbstractTutorial.all_tasks_completaed?(user)

          user.tutorial_done = true
          user.save!

          AllGameItems::ACHIVEMENT_ELDERS.extend!(user, 1)

          redirect_to :action => :index_ajax
        else
          AbstractTutorial.start(user)
          redirect_to :action => :get_task
        end
      end

      def receive_gift
        user = current_user

        user.done_task!(TutorialLastTask::NAME)
        
        AllGameItems::ACHIVEMENT_ELDERS.extend!(user, 1)
        
        redirect_to :action => :index_ajax
      end

      def cancel_tutorial
        @user = current_user
        @description = t(:cancel_tutorial_description)
        render_content :tutorial, {:destination => :tutorial_content}
      end

      def populate_task

        if AbstractTutorial.is_accepted_task(@user)
          @task = @user.uncompleted_task
          @description = @task.description if @task
        else
          @last_task = @user.last_compleated
          @description = @last_task.done_description if @last_task
        end

      end

    end
  end
end