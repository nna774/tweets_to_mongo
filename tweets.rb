require 'mongo'
require 'twitter'
require 'json'

require_relative "config.rb"

Mongo::Logger.logger = Logger.new(STDERR)
client = Mongo::Client.new([ MONGO ], {:database => "twitter"})

db = client.database

collection = db[:tweets]

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = CK
  config.consumer_secret     = CS
  config.access_token        = AT
  config.access_token_secret = AS
end

client.user do |obj|
  p = nil
  case obj
    when Twitter::Streaming::DeletedTweet
      p = { :event => "DeleteTweet", :obj => obj.to_h }
    when Twitter::DirectMessage
      p = { :event => "DM", :obj => obj.to_h }
    when Twitter::Tweet
      p = { :event => "Tweet", :obj => obj.to_h }
    when Twitter::Streaming::Event
      p = { :event => "Event", :name => obj.name, :source => obj.source.to_h, :target => obj.target.to_h, :obj => obj.target_object.to_h }
  end
  collection.insert_one(p) unless p.nil?
end
