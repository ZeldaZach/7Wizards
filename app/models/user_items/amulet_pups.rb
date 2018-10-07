class UserItems::AmuletPups < UserItems::Amulet

#  KEY = 'pups'
  TYPE = TYPE_FIGHT

  # Hessonite 
  # Неваляш
  # Повышает вероятность уклониться от удара на 1.0%. Действует постоянно.
  # Эффект 100 уровня: добавляет +10% к суммарной характеристике "ловкость" (данный эффект не блокируется кулоном "Антимаг")

  def self.check_requirements(user)
    user.a_dexterity >= @config_required_dexterity
  end

end
