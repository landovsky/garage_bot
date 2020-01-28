# Rack app for local testing
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pry'
require 'rack/app'
require_relative 'app/controller'

# TMP
require_relative 'app/garage'
require_relative 'app/store'
require 'slack'

class MyApp < Rack::App
  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end

  SLACK = Slack::Web::Client.new

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

  post '/chatbot' do
    request_data = URI.decode_www_form(payload).to_h
    puts request_data
    response.status = 200
    Controller.call(request_data)
  rescue
    response.status = 400
    { error: "could not parse JSON" }
  end

  post '/test' do
    request_data = JSON.parse payload
    puts request_data
    user = request_data['event']['user']
    response.status = 200
    blocks = Garage.park(user, Store::SALDOVKA)[:blocks]
    view = { type: "home", view: blocks }

    SLACK.views_update(user: 'UJC1L8Q87', view: view)
  end
end

run MyApp
