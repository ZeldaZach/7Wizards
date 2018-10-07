class Amazon
  
  BIGPOIN_BUCKED = 'wiz-avatars-bp'
  PROD_BUCKED = 'wiz-avatars-prod'
  AMAZONE_HOST = "http://s3.amazonaws.com:80/"
  
  class << self

    def put(name, file_name, user)
      return unless File.exist?(file_name)
      
      Thread.start do
        bucket = get_aws_bucket(user)
        bucket.put(name, File.open(file_name), {}, 'public-read')
      end
    end

    def get_url(user, name)
      get_key(user, name).public_link
    end

    def exists?(user = nil, name = nil)
#      get_key(user, name).exists?
       true
    end

    def get_bucket_url(user)
      get_aws_bucket(user).public_link
    end

#    def get_modification_time(user, name)
#      time = get_aws_bucket(user).key(get_key(user, name)).last_modified
#      return time ? time.to_i : ""
#    end

    def delete(user)
      get_key(user, "custom_#{user.id}.jpg").delete
    end

    private

    def get_key(user, name)
      RightAws::S3::Key.create(get_aws_bucket(user), name)
    end
  
    def get_aws_bucket(user)
      return @aws_bucket if @aws_bucket

      aws = RightAws::S3.new(S3Config.aws_access_key, S3Config.aws_secret_access_key, 
        {:multi_thread => true, :port => 80, :protocol => "http"})
      
      @aws_bucket = aws.bucket(get_bucket_name(user), false) #get bucket
      @aws_bucket = aws.bucket(get_bucket_name(user), true, 'public-read') if @aws_bucket.nil? #create bucket
      @aws_bucket
    end

    def get_bucket_name(user)
      user.respond_to?(:bigpoint?) && user.bigpoint? ? BIGPOIN_BUCKED : PROD_BUCKED
    end
  end

end
