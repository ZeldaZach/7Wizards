module Helpers
  module Hi5Helper
    MALE = "m"
    FEMALE = "f"
    FEMALE_LIST = ["female", "женский", "жіноча", "mujer", "weiblich", "femme"]

    def get_user_name(session)
      xml_userinfo = session.users_getInfo(:uids => session.session_user_id, :fields => ["first_name", "last_name"])
      first_name =  xml_userinfo.search("//first_name").map{|uidNode| uidNode.inner_html.to_s}
      last_name =  xml_userinfo.search("//last_name").map{|uidNode| uidNode.inner_html.to_s}

      return "#{first_name.to_s}_#{last_name.to_s}"
    
    end

    def get_user_gender(session)
      xml_userinfo = session.users_getInfo(:uids => session.session_user_id, :fields => "sex")
      g =  xml_userinfo.search("//sex").map{|uidNode| uidNode.inner_html.to_s}
      return FEMALE_LIST.include?(g.to_s) ? FEMALE : MALE
    end

    def hi5_buy_gold(session, count, product)
      xml_res = session.hi5_payment_redeemCoins({:amount => count.to_s, :product_sku => product, :product_name => 'buy_gold'})
      
      if GameProperties::PROD
        r = xml_res.search("//transaction_id").map{|uidNode| uidNode.inner_html.to_s}
      else
        r = xml_res.search("//fake_transaction_id").map{|uidNode| uidNode.inner_html.to_s}
      end
      r
    end

    def hi5_publish(session, message, title, image_url)
      attachment = {:caption => title, :media => [{:type => "image", :src => "#{hi5_host}#{image_url}" }]}
      session.stream_publish({:message => message, 
                              :attachment => attachment.to_json,
                              :action_links => "",
                              :target_id => current_user.hi5_id,
                              :uid => current_user.hi5_id})
    end
  end
end
