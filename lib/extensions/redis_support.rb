require 'redis'

module RedisSupport

  class Instance
    def redis
      Thread.current[:redis] ||= Redis.new
    end
  end

  class Cache
    def put(key, value, expire = nil)
      if value
        value = Marshal.dump value
        r = RedisInstance.redis
        r.set key, value, expire
      else
        del key
      end
    end

    def get(key, default = nil)
      r = RedisInstance.redis
      value = r.get key
      value = Marshal.load value if value
      value || default
    end

    def del(key)
      r = RedisInstance.redis
      r.del key
    end
  end

  class Lock
    def lock(name, time = 10.seconds)
      name = name + '_lock' if !name.end_with?('_lock')

      r = RedisInstance.redis
      if r.setnx(name, (Time.now + time).to_i)
        begin
          yield
        ensure
          r.del name
        end
        return true
      else
        value = r.get name
        if value.to_i < Time.now.to_i
          new_value = r.getset name, (Time.now + time).to_i
          if new_value == value
            begin
              yield
            ensure
              r.del name
            end
            return true
          end
        end
      end

      false
    end

  end
end

RedisInstance = RedisSupport::Instance.new
RedisCache = RedisSupport::Cache.new
RedisLock = RedisSupport::Lock.new