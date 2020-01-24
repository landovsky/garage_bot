require 'json'
require 'pry'
require 'rack/app'
require 'rest-client'
require_relative 'garage_bot'
require_relative 'http_client'
require_relative 'dynamo'

class MyApp < Rack::App

  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header',
          'Content-type' => 'application/json'

  serializer do |obj|
    if obj.is_a?(String)
      obj
    else
      JSON.dump(obj)
    end
  end

  error StandardError, NoMethodError do |ex|
    { error: ex.message }
  end

  get '/' do
    { hello: 'world' }
  end

  post '/chatbot' do
    request_data = URI.decode_www_form(payload).to_h
    response.status = 200
    router(request_data)
  rescue
    response.status = 400
    { error: "could not parse JSON" }
  end

  def router(request_data)
    # /garage command
    if request_data['token']
      GarageBot.garage(request_data['user_id'])
    # button clicked
    else
      parsed = JSON.parse request_data['payload']
      action = parsed['actions'][0]['text']['text'].downcase == 'book' ? :book : :cancel
      date   = DateTime.parse(parsed['actions'][0]['value']).to_time
      user   = parsed['user']['id']
      _persist = Dynamo.call(action, date, user)

      response_msg = GarageBot.message([GarageBot.garage_on(date, user)]).to_json

      HTTPClient.post(parsed['response_url'], response_msg)
    end
  end
end

run MyApp
