require "tweetstream"
require "json"

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
      root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      f = File.open(File.join(root, "tmp", "tweetmap.json"), "w")
      f.write(status.to_h.to_json)
      break
    end
  end

  desc "Generate the ElasticSearch mapping"
  task gen_mapping: :environment do
    Rake::Task['es_tweet_mapping:tweet_to_json'].invoke
  end

  desc "Post the ElasticSearch mapping to ElasticSearch"
  task es_post_mapping: :environment do
  end

end
