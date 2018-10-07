Dir[File.dirname(__FILE__) + "/all/*.rb"].sort.each do |path|
  filename = File.basename(path, '.rb')
  require "extensions/all/#{filename}"
end
