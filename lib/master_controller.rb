require_relative "reddit_retriever"

r = RedditRetriever.new("simple_bot")
r.get_oath_token
r.get_user_karma