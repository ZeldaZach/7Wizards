class ExternalGames

  require 'open-uri'
  require 'xml'

  KongregateGame = Struct.new(:title, :id, :thumbnail, :category, :flash_file, :width, :height, :url, :description, :rating, :gameplays)

  GAMES_URL = "xxx"

  @@kongregate_games = nil
  @@kongregate_categories = nil

  def self.get_games
    return @@kongregate_games if get_cached && get_cached[:games].size > 0

    items = []
    @@kongregate_categories = {}
    @@kongregate_games = []
    
    # we can ignore parse for dev mode
    unless GameProperties.is_enabled_mode?(:games)
      return @@kongregate_games
    end

    RedisLock.lock "kongregate_games_lock" do
    
      doc = read
      doc.find("//gameset/game").each do |node|
        game = KongregateGame.new
        game.id         = xml_elements_text(node, "id")
        game.title      = xml_elements_text(node, "title")
        game.thumbnail  = xml_elements_text(node, "thumbnail")
        game.category   = xml_elements_text(node, "category")
        game.flash_file = xml_elements_text(node, "flash_file")
        game.width      = xml_elements_text(node, "width")
        game.height     = xml_elements_text(node, "height")
        game.url        = xml_elements_text(node, "url")
        game.description= xml_elements_text(node, "description")
        game.rating     = xml_elements_text(node, "rating")
        game.gameplays  = xml_elements_text(node, "gameplays")

        @@kongregate_categories[game.category.to_s] ||= []
        @@kongregate_categories[game.category.to_s] << game
        items << game
      end

      items.sort! do |item1, item2|
        -item1.rating.to_f <=> -item2.rating.to_f
      end
      
      @@kongregate_games = items
      set_cached({:games => @@kongregate_games, :categories => @@kongregate_categories})
    end
    
    @@kongregate_games
  end

  def self.get(id)
    get_games.each do |game|
      return game if game.id == id
    end
    nil
  end

  def self.categories
    get_games if @@kongregate_categories.nil?
    @@kongregate_categories 
  end

  def self.get_by_category(category)
    categories[category] || []
  end

  private

  def self.xml_elements_text(node, path)
    r = ''
    begin
      r = node.find(path).first
      r = r.content unless r.nil?
    rescue
    end
    r
  end

  def self.read
    r = open(GAMES_URL).read
    parser = XML::Parser.string r
    parser.parse
  end

  def self.set_cached(options = {})
    RedisCache.put("kongregate_cached", options, 6.hours)
  end

  def self.get_cached
    options = RedisCache.get("kongregate_cached")
    if options
      @@kongregate_categories = options[:categories]
      @@kongregate_games      = options[:games]
    end
    options
  end

end
