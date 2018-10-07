module UserExt
  module Integrations
    
    def User.register_hi5(hi5_name, gender, hi5_id)

      user = User.new
      user.gender   = gender
      user.hi5_id   = hi5_id
      user.hi5_name = hi5_name

      user.name     = "HI5#{hi5_id}"
      user.email    = "mail#{hi5_id}_#{rand(10)}@7wizards.com"
      user.password = "#{rand(1000)}-7wiz"
      user.active_avatar_id = 1 #default avatar
      user.register(false)
      user.save!
      user
    end

    def User.facebook_register(user_info)
      fb_id = user_info[0]["uid"]
      name  = user_info[0]["name"]
      email = user_info[0]["email"]

      user = User.find :first, :conditions => {:fb_id => fb_id, :deleted => false}
      return user if user #facebook user registered

      user = User.new
      user.gender   = "m"
      user.fb_id    = fb_id
      user.fb_email = email
      user.fb_name  = name.gsub(" ", "_")
      
      user.name     = "FB_#{fb_id}"
      user.email    = "FB_#{email}"
      user.password = "#{rand(1000)}-7wiz"
      user.active_avatar_id = 1 #default avatar
      user.register(false)
      user.save!
      user
    end
    
  end
end
