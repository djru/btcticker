require 'httparty'
require 'redis'


#Initializes connection to Redis server
uri = URI.parse(ENV['REDISTOGO_URL'])
DB = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)


# Fetches buy and sell data from MtGox
def fetch_data
    resp = HTTParty.get("http://data.mtgox.com/api/1/BTCUSD/ticker")
    buy = resp["return"]["buy"]["display"]
    sell = resp["return"]["sell"]["display"]
    
    return {:buy => buy, :sell => sell}
end


# Stores new price data in Redis.
def update_price(data)
    DB.set("buy", data[:buy] || "")
    DB.set("sell" data[:sell] || "")
    
    puts "New prices saved to server."
end
