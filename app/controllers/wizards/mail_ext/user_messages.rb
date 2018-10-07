module Wizards
  module MailExt
    module UserMessages

      def user_messages
        id    = params[:id]
        @kind = params[:kind]
        @kind = Message::MESSAGE_FROM if @kind.blank?

        @user = current_user

        if !id.blank?
          @selected_message = Message.select_message(id, @user.id)
          @history = Message.user_messages_history(@user.id, @selected_message.detail, page) if @selected_message
        end

        if @selected_message.nil?
          if @kind.to_i == Message::MESSAGE_FROM
            Message.mark_incoming_as_read!(@user)
            @user_messages = Message.incoming_messages(@user.id, page)
          else
            @user_messages = Message.sent_messages(@user.id, page)
          end
        end

      end

      def new_message
        user = current_user
        @id       = params[:recipient_id]
        @title    = params[:title]
        @message  = params[:message]
        
        recipient = User.find_by_id(@id)

        @name = recipient.name if recipient
        @relations = Relation.find_all_by_kind_and_user_id Relation::KIND_FRIEND, user.id
        render_popup :title => t(:new_message)
      end

      def new_message_process
        user = current_user
        name         = params[:autocompleate_user_name]
        id           = params[:recipient_id]
        title        = params[:title]
        message      = params[:message]
        message_id   = params[:message_id]

        recipient = User.find_by_name(name)
        recipient = User.find_by_id(id) if recipient.nil?

        r = MailRules.can_send_message(user, recipient, title, message, name)
        if r.allow?
          Message.send_message(user, recipient, title, message)
          
          user.done_task!(TutorialMessage::NAME)

          redirect_to mail_path(:action => :user_messages, :kind => Message::MESSAGE_TO)
        else
          options = {}

          options[:action]       = :new_message
          options[:title]        = title
          options[:message]      = message
          options[:recipient_id] = id
          options[:message_id]   = message_id if !message_id.blank?
          redirect_to_with_notice r.message, options
        end
        
      end

      def reply
        @message_id = params[:message_id]
        message = Message.find_by_id(@message_id)
        recipient = User.find_by_id(message.detail)

        @id            = recipient.id
        @name          = recipient.name
        @title         = message.title.match(/^Re:/) ? message.title : "Re: #{message.title}"
        @reply_message = message.message

        render_popup :title => t(:new_message)
      end

      def remove
        id = params[:id]
        if !id.blank?
          message = Message.find_by_id_and_user_id(id, current_user.id)
          message.destroy if message
        end
        redirect_to :action => :user_messages, :kind => params[:kind]
      end

    end
  end
end
