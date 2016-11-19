require "pp"
class Display
  def designate_target
    puts "please input an username"
    username = gets.chomp
    puts "\n"
    username
  end


  def display_user_info(info)
    return unless user_exists?(info)

    puts "---------"
    puts "You searched for #{info['data']['name']}"
    puts "The user has #{info['data']['link_karma']} link karma"
    puts "The user has #{info['data']['comment_karma']} comment karma"
    mod = "is not a mod" unless info['data']['is_mod']
    mod = "is a mod" if info['data']['is_mod']
    puts "The user #{mod} "
    ver_status = "not "
    ver_status = "" if info['data']['has_verified_email']
    puts "The user has #{ver_status}verfied their email"
    puts "----------"
  end

  def display_comment(comment)

    return unless user_exists?(comment)
    
    if !!comment["data"]["children"].empty?
      puts "User has no comments posted"
      return
    end

    puts "The text of this user's comment says"
    puts "-----------"
    puts comment["data"]["children"][0]["data"]["body"]
    puts "-----------"
    puts "It has a score of #{comment["data"]["children"][0]["data"]["score"]} karma"
    puts "and was posted in #{comment["data"]["children"][0]["data"]["subreddit"]}"
  end

  def display_post(post)

    return unless user_exists?(post)
    
    if !!post["data"]["children"].empty?
      puts "User has no posts"
      return
    elsif post["data"]["children"][0]["data"]["title"] == nil
      puts "User has no posts"
      return
    end

    puts "It was called: \n'#{post["data"]["children"][0]["data"]["title"]}'"
    puts "and linked to \n#{post["data"]["children"][0]["data"]["url"]}"
    puts "It has a score of #{post["data"]["children"][0]["data"]["score"]} karma"
    puts "and was posted in #{post["data"]["children"][0]["data"]["subreddit"]}"
  end

  def display_stats(special_hash)
    return if special_hash.nil?
    special_hash[:list].reverse!
    if special_hash[:list].empty?
      puts "No stats are available"
      return
    end
    precent = special_hash[:list][0][1].to_f/special_hash[:total].to_f
    puts "This user's favorite subreddit is #{special_hash[:list][0][0]} "
    puts "They have #{special_hash[:list][0][1]} posts/comments there"
    puts "That's #{(precent*100).round(4)} precent of their posts "

    puts "Their second favorite subreddit is #{special_hash[:list][1][0]}" unless special_hash[:list][1].nil?
    puts "Their third favorite subreddit is #{special_hash[:list][2][0]}" unless special_hash[:list][2].nil?
    
  end

  def display_worst(content)
    return if content.nil?
    if content == false
      puts "Not available"
      return
    end
    puts "this is the user's worst preforming post/comment"
    puts "It was a #{content[:type]} that scored #{content[:karma]}"
    if content[:type] == "comment"
      puts "It said"
      puts "-----------"
      puts content[:data]
      puts "-----------"
    elsif content[:type] == "comment"
      puts "It was called: \n '#{content[:title]}'"
      puts "And linked to #{content[:url]}"
    end
    puts "It was posted in #{content[:subreddit]}"
  end

  def display_all_subreddits(special_hash)
    if special_hash.nil?
      return
    end
    puts "This is the list of all subreddits they've contributed to"
    pp special_hash[:list].reverse!
    puts "This is the total of contributions. Capped at 1000."
    pp special_hash[:total]
  end

  def user_exists?(info)
    if info['message'] == "Not Found"
      puts "There is no such user. Did you type their name correctly?"
      return false
    end
    true
  end
end