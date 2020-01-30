# frozen_string_literal: true

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
require_relative 'app/slack/dsl'
require_relative 'app/slack_router'
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
    # puts request_data
    response.status = 200
    Router.call(request_data)
  rescue => e
    response.status = 400
    { msg: 'could not parse JSON', error: e }
  end

  post '/test' do
    request_data = JSON.parse payload
    # user_id = request_data['event']['user']

    response.status = 200

    SlackRouter.call(request_data)

    # blocks  = Garage.park user_id
    # view    = Slack::DSL.view(:home, blocks)
    # options = { user_id: user_id, view: view }

    # SLACK.views_publish(options)
    # puts '
    # SLACK.views_update(view_id: 'VT9UVQVAT', view: view)
    # binding.pry
  rescue => e
    puts '==== ERROR ===='
    puts e
    puts e.backtrace.first
    puts '==============='
  end
end

run MyApp
