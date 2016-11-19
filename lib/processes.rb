require_relative "reddit_retriever"
require_relative "display"

class Execution
  def initialize
    @retriver = RedditRetriever.new
    @display = Display.new
  end

  def basic_info(target = @display.designate_target)
    info = @retriver.get_user_info(target)
    @display.display_user_info(info)
    target
  end

  def output_comment(comment)
    @display.display_comment(comment)
  end

  def report
    target = basic_info
    output_stats(target)
    puts "\n\nInformation on the user's best comment"
    output_comment(@retriver.get_comment(target, {"sort" => "top",
                    "                            limit" => "1"}))
    puts "\n\nInformation on the user's most controversial comment"
    output_comment(@retriver.get_comment(target,{"sort" => "controversial",
                    "                            limit" => "1"}))
    puts "\n\nInformation on the user's best post"
    output_post(@retriver.get_posts(target,{"sort" => "top",
                                 "limit" => "1"}))
    puts "\n\nInformation on the user's most controversial post"
    output_post(@retriver.get_posts(target,{"sort" => "controversial",
                                 "limit" => "1"}))
    puts "\n\nInformation on the user's worst preformer"
      display_worst(target)
    puts "\n\nEvery subreddit contributed to"
      display_subreddits(target)

  end

  def display_worst(target  = @display.designate_target)
    mhash = generate_worst(target)
    @display.display_worst(mhash)
  end

  def output_post(post)
    @display.display_post(post)
  end

  def output_stats(target = @display.designate_target)
    rhash = generate_subs_frequented(target)
    @display.display_stats(rhash)
  end

  def display_subreddits(target = @display.designate_target)
    rhash = generate_subs_frequented(target)
    @display.display_all_subreddits(rhash)
  end

  private 

  def generate_subs_frequented(target)
    #this is not going to be easy
    #the basic theory is that we take an username, we call the api to get their posts over and over until there are no more left and get the subreddit out of each. 
    #also inperfect, reddit caps us at the last 1000 posts from an user
    
    subreddit = []
    last = ""
    total = 0
    stop = false
    until stop == true
      stop = true if last.nil?
      posts = @retriver.get_comment(target, {"sort" => "top",
                                  "limit" => "99",
                                  "after" => last})
      return unless @display.user_exists?(posts)
      posts["data"]["children"].each_with_index do |post|
        subreddit << post["data"]["subreddit"]
        total += 1
      end
      last = posts['data']['after']
    end

    subreddit_hash = Hash.new(0)
    subreddit.each do |subreddit|
      subreddit_hash[subreddit] += 1
    end
    list_of_reddits = subreddit_hash.sort_by {|key, value| value} 
    {list: list_of_reddits, total: total}
  end

  def generate_worst(target)
    #naturally reddit doesn't provide downvote data. 
    return unless @display.user_exists?(target)
    low_post = nil
    score = 200000
    last = ""
    stop = false
    until stop == true
      stop = true if last.nil?
      posts = @retriver.get_comment(target, {"sort" => "top",
                                  "limit" => "99",
                                  "after" => last})
      return unless @display.user_exists?(posts)

      posts["data"]["children"].each do |post|
        if post["data"]["score"] < score
          low_post = post 
          score = post["data"]["score"] 
        end
      end

      last = posts['data']['after']
    end
    return false if low_post.nil?
    type = "post"
    type = "comment" unless low_post["data"]["title"]
    data_hash = {type: type, karma: low_post["data"]["score"], data: low_post["data"]["body"], 
                title: low_post["data"]["title"], url:low_post["data"]["url"], subreddit: low_post["data"]["subreddit"], }
  end
end