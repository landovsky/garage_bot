# Rack app for local testing
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pry'
require 'rack/app'
require_relative 'app/controller'

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

  post '/chatbot' do
    request_data = URI.decode_www_form(payload).to_h
    response.status = 200
    Controller.route(request_data)
  rescue
    response.status = 400
    { error: "could not parse JSON" }
  end
end

run MyApp
