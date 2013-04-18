require 'twitter'

# Initializes connection to Twitter
Twitter.configure do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.oauth_token = ENV["OAUTH_TOKEN"]
  config.oauth_token_secret = ENV["OAUTH_SECRET"]
end

# Tweets.
def tweet_price(data)
    buy = data[:buy]
    sell = data[:sell]
    if buy and sell
        Twitter.update("Buy: #{buy} \nSell: #{sell}")
        
        puts 'Tweet sent.'
    else 
        puts "Tweet not sent. See Logs."
    end
end
