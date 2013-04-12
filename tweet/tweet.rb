require 'twitter'
require 'httparty'


# Initializes connection to Twitter
Twitter.configure do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.oauth_token = ENV["OAUTH_TOKEN"]
  config.oauth_token_secret = ENV["OAUTH_SECRET"]
end

# Fetches buy and sell data from MtGox
resp = HTTParty.get "http://data.mtgox.com/api/1/BTCUSD/ticker"
buy = resp["return"]["buy"]["display"]
sell = resp["return"]["sell"]["display"]


# Tweets
if resp and buy and sell
    Twitter.update "Buy: #{buy} \n\nSell: #{sell}\n"
end

