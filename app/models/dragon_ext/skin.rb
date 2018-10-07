module DragonExt::Skin
  
  BODY_COLORS = [16315343, 14277352, 5452834, 6620935, 402436, 2955840]
  MAX_CLOTHES = 5

  def avatar
    if self.a_level == 1
      body_id = 0
    else
      body_id = ((self.a_level - 1) % MAX_CLOTHES) + 1
    end

    if self.kind == Dragon::KIND_DOUBLE_HEALTH
      id = 6
    elsif self.kind == Dragon::KIND_DOUBLE_POWER
      id = 7
    else
      id = (self.a_level / BODY_COLORS.size).to_i
    end

    
    avatar = AllUserAvatars.get_by_key("dragon")
    avatar.default_used_clothes = {"armory" => {:id => id, :color => 0}, "fon" => {:name =>"vulcan", :color => 0xFFFFFF}}
    avatar.body_color = BODY_COLORS[body_id]
    avatar
  end
end
