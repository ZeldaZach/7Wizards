class UserItems::AmuletStahanka < UserItems::Amulet

#  KEY = 'stahanka'
  TYPE = TYPE_WORK

  # Moonstone 
  # Фермстень
  # Помогает получить зарплату за работу на участке больше на 7.5%.
  # Эффект 100 уровня: увеличение эффекта до 495 %

  def self.check_requirements(user)
    user.s_meditation_minutes / 60 >= @config_required_meditation_hours
  end
  
end
