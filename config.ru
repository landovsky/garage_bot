require 'json'
require 'pry'
require 'rack/app'
require 'rest-client'
require_relative 'garage_bot'
require_relative 'http_client'

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
    # parsed = JSON.parse(payload)
    response.status = 200
    # HTTPClient.post(URI.unescape(params[response_url], GarageBot.blocks.to_json)
    GarageBot.blocks.to_json
  rescue
    response.status = 400
    { error: "could not parse JSON" }
  end

  post '/response' do
    raw = URI.decode_www_form(payload)
    parsed = JSON.parse raw[0][1]
    response.status = 200
    HTTPClient.post(URI.unescape(parsed['response_url']), GarageBot.blocks.to_json)
  rescue
    response.status = 400
    { error: "could not parse JSON" }
  end
end

run MyApp
