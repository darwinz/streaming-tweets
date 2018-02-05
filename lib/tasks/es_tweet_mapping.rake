require "tweetstream"
require "json"
require 'net/http'

namespace :es_tweet_mapping do
  desc "Get a single tweet and convert to json"
  task tweet_to_json: :environment do
    # Set up the TweetStream configuration using environment variables
    TweetStream.configure do |config|
	  config.consumer_key       = ENV["TS_CONSUMER_KEY"]
	  config.consumer_secret    = ENV["TS_CONSUMER_SECRET"]
	  config.oauth_token        = ENV["TS_OAUTH_TOKEN"]
	  config.oauth_token_secret = ENV["TS_OAUTH_TOKEN_SECRET"]
	  config.auth_method        = :oauth
	end

    # This will pull a single sample tweet and store the tweet as json into a file
    TweetStream::Client.new.track("ruby", "rails") do |status|
      f = File.open(File.join(Rails.root, "tmp", "tweetmap.json"), "w")
      f.write(status.to_h.to_json)
      f.close
      break
    end
  end

  desc "Generate the ElasticSearch mapping"
  task gen_mapping: :environment do
    Rake::Task['es_tweet_mapping:tweet_to_json'].invoke
  end

  desc "Post the ElasticSearch mapping to ElasticSearch"
  task es_post_mapping: :environment do
    # This method will create the index and mapping in ElasticSearch 
    # by posting the mapping json data to the ES URI found in environment config
    es_index_name = '/tweets'
    es_uri = URI.parse(ENV["TS_ELASTICSEARCH_URI"] + es_index_name)
    header = {"Content-Type": "text/json"}
    http = Net::HTTP.new(es_uri.host, uri.port)
    request = Net::HTTP::Put.new(es_uri.request_uri, header)
    # The mapping is found in the json file and read into the request.body
    f = File.open(File.join(Rails.root, "tmp", "tweetmap.json"), "r")
    request.body = f.read
    response = http.request(request)
    puts "#{response.to_s}"
    f.close
  end

end
