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
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)


# Fetches buy and sell data from MtGox
def fetch_data
    resp = HTTParty.get("http://data.mtgox.com/api/1/BTCUSD/ticker")
    buy = resp["return"]["buy"]["display"]
    sell = resp["return"]["sell"]["display"]
    
    return {:buy => buy, :sell => sell}
end


# Stores new price data in Redis.
def update_price(data)
    REDIS.set("buy", data[:buy] || "")
    REDIS.set("sell", data[:sell] || "")
    
    puts "New prices saved to server."
end


# Tweets.
def tweet_price(data)
    buy = data[:buy]
    sell = data[:sell]
    if buy and sell
        Twitter.update("Buy: #{buy} \n\nSell: #{sell}\n")
        
        puts 'Tweet sent.'
    else 
        puts "Tweet not sent. See Logs."
    end
end




# Fetches new data from MtGox.
mtGox_data = fetch_data()


# Updates if Redis doesn't have data.
if !redis.get("buy") or !redis.get("sell") then update_price(mtGox_data) end


# To avoid the Twitter gem from throwing an error due to duplicate statuses, the last price data is stored and the new data is checked against it.
if redis.get("buy") == mtGox_data["buy"] and redis.get("sell") == mtGox_data["sell"]
    puts "Price has not changed."
    puts mtGox_data
else
    tweet_price(mtGox_data)
    update_price(mtGox_data)
    
    puts mtGox_data
end
