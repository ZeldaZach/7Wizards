class ClanProtectionItem < AbstractClanItem

  KEY = 'clan_protection'

  def get_protection(clan, full_protection)
    return 0 if !clan
    p = get_value_percent(clan)
    p > 0 ? (clan.get_users_protection * p).to_i : 0
  end

end
