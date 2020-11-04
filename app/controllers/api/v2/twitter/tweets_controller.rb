require 'json'
require 'typhoeus'

# The code below sets the bearer token from your environment variables
# To set environment variables on Mac OS X, run the export command below from the terminal:
# export BEARER_TOKEN='YOUR-TOKEN'
@bearer_token = Rails.application.credentials.dig(:twitter, :bearer_token)

@stream_url = "https://api.twitter.com/2/tweets/search/stream"
@rules_url = "https://api.twitter.com/2/tweets/search/stream/rules"

@sample_rules = [
  { 'value': 'dog has:images', 'tag': 'dog pictures' },
  { 'value': 'cat has:images -grumpy', 'tag': 'cat pictures' },
]

params = {
  "expansions": "attachments.poll_ids,attachments.media_keys,author_id,entities.mentions.username,geo.place_id,in_reply_to_user_id,referenced_tweets.id,referenced_tweets.id.author_id",
  "tweet.fields": "attachments,author_id,conversation_id,created_at,entities,geo,id,in_reply_to_user_id,lang",
  # "user.fields": "description",
  # "media.fields": "url", 
  # "place.fields": "country_code",
  # "poll.fields": "options"
}

def get_all_rules
  @options = {
    headers: {
      "User-Agent": "v2FilteredStreamRuby",
      "Authorization": "Bearer #{@bearer_token}"
    }
  }

  @response = Typhoeus.get(@rules_url, @options)

  raise "An error occurred while retrieving active rules from your stream: #{@response.body}" unless @response.success?

  @body = JSON.parse(@response.body)
end

def set_rules(rules)
  return if rules.nil?

  @payload = {
    add: rules
  }

  @options = {
    headers: {
      "User-Agent": "v2FilteredStreamRuby",
      "Authorization": "Bearer #{@bearer_token}",
      "Content-type": "application/json"
    },
    body: JSON.dump(@payload)
  }

  @response = Typhoeus.post(@rules_url, @options)
  raise "An error occurred while adding rules: #{@response.status_message}" unless @response.success?
end

def delete_all_rules(rules)
  return if rules.nil?

  @ids = rules['data'].map { |rule| rule["id"] }
  @payload = {
    delete: {
      ids: @ids
    }
  }

  @options = {
    headers: {
      "User-Agent": "v2FilteredStreamRuby",
      "Authorization": "Bearer #{@bearer_token}",
      "Content-type": "application/json"
    },
    body: JSON.dump(@payload)
  }

  @response = Typhoeus.post(@rules_url, @options)

  raise "An error occurred while deleting your rules: #{@response.status_message}" unless @response.success?
end

def setup_rules
  # Gets the complete list of rules currently applied to the stream
  @rules = get_all_rules
  puts "Found existing rules on the stream:\n #{@rules}\n"

  puts "Do you want to delete existing rules and replace with new rules? [y/n]"
  answer = gets.chomp
  if answer == "y"
    # Delete all rules
    delete_all_rules(@rules)
  else
    puts "Keeping existing rules and adding new ones."
  end
  
  # Add rules to the stream
  set_rules(@sample_rules)
end

def stream_connect(params)
  @options = {
    timeout: 20,
    method: 'get',
    headers: {
      "User-Agent": "v2FilteredStreamRuby",
      "Authorization": "Bearer #{@bearer_token}"
    },
    params: params
  }

  @request = Typhoeus::Request.new(@stream_url, @options)
  @request.on_body do |chunk|
    puts chunk
  end
  @request.run
end

setup_rules

timeout = 0
while true
  stream_connect(params)
  sleep 2 ** timeout
  timeout += 1
end
