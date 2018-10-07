class UserItems::AmuletKakdams < UserItems::Amulet

#  KEY = 'kakdams'
  TYPE = TYPE_FIGHT

  # Amethyst of strength
  # Крит-Камень
  # Повышает вероятность нанести критический удар на 50.0%. Действует постоянно.
  # Эффект 100 уровня: первый удар +25% к вероятности попасть по противнику (данный эффект не блокируется кулоном "Антимаг").
  # Если первый удар проходит, он 100% наносит критический урон (данный эффект блокируется кулоном "Антимаг")

  def self.check_requirements(user)
    user.a_skill >= @config_required_skill
  end
  
end
