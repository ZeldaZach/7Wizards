class UserItems::AmuletRegenec < UserItems::Amulet

#  KEY = 'regenec'
  TYPE = TYPE_OTHER

  # Emerald of life
  # Неогенез
  # Восстанавливает здоровье на 4.0% быстрее. Действует постоянно.
  # Эффект 96 уровня: повышает регенерацию здоровья до 200%

  def self.check_requirements(user)
    user.has_item?("p3")
  end

end
