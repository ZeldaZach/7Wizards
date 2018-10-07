class UserMarketingInfo < ActiveRecord::Base

  # include base mode behavior
  include BaseModel
  
  belongs_to :user
  belongs_to :partner

  def self.create_user_info(user, options= {})
    user_info = UserMarketingInfo.new
    user_info.user        = user

    unless options['7wz_partner'].blank?
      partner = Partner.find_by_name(options['7wz_partner'])
      user_info.partner     = partner
    end

    user_info.source      = options["7wz_src"]
    user_info.campaign_id = options["7wz_cid"]
    user_info.keywords    = options["7wz_kw"]
    user_info.referrer    = options["7wz_rfv"]
    user_info.save!
    user_info
  end

  def self.get_referrer_host(user)
    user_info = find_by_user_id(user.id)
    if user_info && user_info.partner && user_info.partner.host_url
      return user_info.partner.host_url
    end
    nil
  end
  
  def adjust

    if self.source
      if self.campaign_id 
        promotion = GameProperties::PROMOTION_BY_USER_INFO_SOURCE[self.source.to_sym]
        if promotion
          campaign = promotion[self.campaign_id.to_sym]
          self.user.add_staff!(campaign[:staff_bonus], "add_bonus", "promotion.add_bonus") if campaign
        end
      end
    end
  end

end
