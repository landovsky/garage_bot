# frozen_string_literal: true

# Rack app for local testing
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pry'
require 'rack/app'
require_relative 'app/utils'

require_relative 'app/slack_app'

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
    { error: ex.message, trace: ex.backtrace[0..5] }
  end

  post '/chatbot' do
    File.open('payload_raw.txt', 'wb') { |file| file.write(payload) } if ENV['BOT_ENV'] == 'dev'

    res = SlackApp::Router.call(payload)
    if res.is_a? String
      response.status = 'text/plain'
    end
    response.status = 200
    res
  rescue => e
    ::Utils.error e
    response.status = 400
  end
end

run MyApp
