require 'tweetstream'
require 'json'

namespace :es_tweet_mapping do
  desc "Get a single tweet and convert to json"
  task tweet_to_json: :environment do
    TweetStream.configure do |config|
	  config.consumer_key       = 'CONSUMER_KEY'
	  config.consumer_secret    = 'CONSUMER_SECRET'
	  config.oauth_token        = 'OAUTH_TOKEN'
	  config.oauth_token_secret = 'OAUTH_TOKEN_SECRET'
	  config.auth_method        = :oauth
	end

    # This will pull a single sample tweet
	TweetStream::Client.new.track('ruby', 'rails') do |status|
      return "#{status.to_json}"
	end
  end

  desc "Generate the ElasticSearch mapping"
  task gen_mapping: :environment do
  end

  desc "Post the ElasticSearch mapping to ElasticSearch"
  task es_post_mapping: :environment do
  end

end
