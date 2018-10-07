class ClanPowerItem < AbstractClanItem

  KEY = 'clan_power'  

  def get_power(clan, full_power)
    return 0 if !clan
    p = get_value_percent(clan)
    p > 0 ? (clan.get_active_users_power * p).to_i : 0
  end

end
