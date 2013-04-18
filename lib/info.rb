require 'redis'
require 'awesome_print'

uri = URI.parse('redis://redistogo:fdb46ad8a2b3c2b553773560bb4314fe@spinyfin.redistogo.com:9320/')
DB = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

puts 'DB INFO:'
ap(DB.info)