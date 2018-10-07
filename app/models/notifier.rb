class Notifier < ActionMailer::Base
  
  helper :application

  include Helpers::TranslateHelper

  DEVELOPMENT_MAIL = "xxx"
  NOREPLY_MAIL = "xxx"
  MAIN_HOST = GameProperties::PRODUCTION_HOST

  def load_postmarkapp
    options = YAML.load_file("#{RAILS_ROOT}/config/action_mailer.yml")[RAILS_ENV]["kavalok"]
    @@smtp_settings = {
      :port           => options["port"],
      :authentication => options["authentication"],
      :address        => options["address"],
      :tls            => options["tls"],
      :user_name      => options["user_name"],
      :password       => options["password"],
      :domain         => options["domain"]
    }
  end

#  def load_gmail
#    options = YAML.load_file("#{RAILS_ROOT}/config/action_mailer.yml")[RAILS_ENV]["gmail"]
#    @@smtp_settings = {
#      :port           => options["port"],
#      :authentication => options["authentication"],
#      :address        => options["address"],
#      :enable_starttls_auto => options["enable_starttls_auto"],
#      :user_name            => options["user_name"],
#      :password       => options["password"],
#      :domain         => options["domain"]
#    }
#  end

  def confirm_registration(recipient)
    
    load_postmarkapp
    hash = ActiveSupport::SecureRandom.hex(10)
    RedisCache.put hash, recipient.id, 2.days

    url = recipient.partner_url.nil? ? MAIN_HOST + visitor_path(:action => :confirm_mail, :ch => hash) :
      recipient.partner_url + "?ch=#{hash}"
    
    unsubscribe_url = recipient.partner_url.nil? ? MAIN_HOST + visitor_path(:action => :unsubscribe, :uh => recipient.email_md5) :
      recipient.partner_url + "?uh=#{recipient.email_md5}"

    subject       t(:new_account)
    recipients    RAILS_ENV == "production" ? recipient.email : DEVELOPMENT_MAIL
    from          NOREPLY_MAIL
    sent_on       Time.now
    body          :name => recipient.name, :url => url, :unsubscribe_url => unsubscribe_url
    content_type  "text/html"
  end

  def send_user_password(user, password)
    
    load_postmarkapp
    subject       t(:registration)
    recipients    RAILS_ENV == "production" ? user.email : DEVELOPMENT_MAIL
    from          NOREPLY_MAIL
    sent_on       Time.now
    body          :password => password, :login => user.name
    content_type  "text/html"
  end

  def restore_password(user)

    load_postmarkapp
    hash = ActiveSupport::SecureRandom.hex(10)
    RedisCache.put hash, user.id, 2.days

    url = user.partner_url.nil? ? MAIN_HOST + visitor_path(:action => :change_password, :rh => hash) :
      user.partner_url + "?rh=#{hash}"

    unsubscribe_url = user.partner_url.nil? ? MAIN_HOST + visitor_path(:action => :unsubscribe, :uh => user.email_md5) :
      user.partner_url + "?uh=#{user.email_md5}"

    subject       t(:restore_password)
    recipients    RAILS_ENV == "production" ? user.email : DEVELOPMENT_MAIL
    from          NOREPLY_MAIL
    sent_on       Time.now
    body          :name => user.name, :url => url, :unsubscribe_url => unsubscribe_url
    content_type  "text/html"
  end

  def payment_successful(user)
    
    load_postmarkapp

    subject       t(:payment_succesful)
    recipients    RAILS_ENV == "production" ? user.email : DEVELOPMENT_MAIL
    from          NOREPLY_MAIL
    sent_on       Time.now
    body          :hash => hash, :name => user.name
    content_type  "text/html"
  end

  def payment_refused(user)
    
    load_postmarkapp

    subject       t(:payment_refused)
    recipients    RAILS_ENV == "production" ? user.email : DEVELOPMENT_MAIL
    from          NOREPLY_MAIL
    sent_on       Time.now
    body          :hash => hash, :name => user.name
    content_type  "text/html"
  end

  def test(email)
    load_postmarkapp

    subject       "7wizard.com test mail"
    recipients    email
    from          NOREPLY_MAIL
    sent_on       Time.now
    body          
    content_type  "text/html"
  end

  def t(key)
    translate(key, :scope => [:mailer, :notifier])
  end

end
