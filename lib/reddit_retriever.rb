require "httparty"
require "pp"

class RedditRetriever
  def initialize
    @key = ENV['API_REDDIT']
    @id = ENV['CLIENT_ID']
    @username = ENV['USERNAME']
    @password = ENV['PASSWORD']
    @user_agent = ENV["USER_AGENT"]
    get_oath_token
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

  def get_user_info(target)
    sleep(1)
    user_info = HTTParty.get("https://oauth.reddit.com/user/#{target.to_s}/about",
      :headers => {"Authorization" => "bearer #{@token}",
        'user-agent' => @user_agent }
      )
   user_info
  end

  def get_comment(target,query)
    sleep(1)
     comment_info = HTTParty.get("https://oauth.reddit.com/user/#{target.to_s}/comments",
      :headers => {"Authorization" => "bearer #{@token}",
        'user-agent' => @user_agent },
      :query => query
      )
  end

  def get_posts(target,query)
    sleep(1)
    post = HTTParty.get("https://oauth.reddit.com/user/#{target.to_s}/overview",
      :headers => {"Authorization" => "bearer #{@token}",
        'user-agent' => @user_agent },
      :query => query)
  end
end