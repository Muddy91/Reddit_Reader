require "httparty"

class RedditRetriever
  def initialize(user)
    @user = user
    @key = ENV['API_REDDIT']
    @id = ENV['CLIENT_ID']
    @username = ENV['USERNAME']
    @password = ENV['PASSWORD']
    @user_agent = ENV["USER_AGENT"]
  end

  def get_oath_token
    auth = {:username => @id,
           :password => @key}
    token_info = HTTParty.post("https://www.reddit.com/api/v1/access_token",
      :basic_auth  => auth,
      :headers => {'user-agent' => @user_agent },
      :body => { :grant_type => 'password',
                :username =>  @username,
                :password => @password,
                }
                   )
    token_info
    @token = token_info["access_token"]
  end

  def get_user_info
    user_info = HTTParty.get("https://oauth.reddit.com/api/v1/me/trophies",
      :headers => {"Authorization" => "bearer #{@token}",
        'user-agent' => @user_agent }
      )
  end


end