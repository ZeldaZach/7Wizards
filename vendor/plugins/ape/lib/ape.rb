APE_SERVER_URL = 'http://127.0.0.1:6969/0/?'

class Ape
  def self.push(content)
    cmd = [{
        :cmd => 'inlinepush',
        :params => {
          :raw => 'data',
          :channel => 'public',
          :data => {
            :msg => content
          }
        }
      }]

    url = URI.parse(APE_SERVER_URL + URI.escape(JSON.dump(cmd)))

    Net::HTTP.get(url)
  end

  def self.block(user, reason)
    cmd = [{
        :cmd => 'block',
        :params => {
          :raw => 'data',
          :channel => 'public',
          :username => user,
          :reason   => reason
        }
      }]

    url = URI.parse(APE_SERVER_URL + URI.escape(JSON.dump(cmd)))

    begin
      Net::HTTP.get(url)
    rescue
    end

  end

  def self.set_defaults
    ApeConfig.host ||= 'www.7wizards.com'
    ApeConfig.port ||= ''
  end

end
