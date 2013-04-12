require 'twitter'
require 'httparty'
require 'redis'


# Initializes connection to Twitter
Twitter.configure do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.oauth_token = ENV["OAUTH_TOKEN"]
  config.oauth_token_secret = ENV["OAUTH_SECRET"]
end

#Initializes connection to Redis server
uri = URI.parse(ENV['REDISTOGO_URL'])
redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
if !redis.get("buy") then redis.set("buy", "") end
if !redis.get("sell") then redis.set("sell", "") end


# Fetches buy and sell data from MtGox
def data
    resp = HTTParty.get("http://data.mtgox.com/api/1/BTCUSD/ticker")
    buy = resp["return"]["buy"]["display"]
    sell = resp["return"]["sell"]["display"]
    
    return {:buy => buy, :sell => sell}
end


# Tweets
def tweet_price(buy, sell)
    if buy and sell
        Twitter.update("Buy: #{buy} \n\nSell: #{sell}\n")
        puts 'Tweet sent.'
    end
end

mtGox_data = data()

# To avoid the Twitter gem from throwing an error due to duplicate statuses, the last price data is stored and the new data is checked against it.
if redis.get("buy") == mtGox_data["buy"] and redis.get("sell") == mtGox_data["sell"]
    puts "Price has not changed."
    puts mtGox_data
else
    tweet_price(mtGox_data["buy"], mtGox_data["sell"])
    redis.set("buy", mtGox_data["buy"])
    redis.set("sell", mtGox_data["sell"])
    
    puts mtGox_data
end
