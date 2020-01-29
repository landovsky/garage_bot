require 'rubygems'
require 'bundler/setup'

require 'slack'

require_relative 'app/store'
require_relative 'app/garage'

client = Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

SLACK = Slack::Web::Client.new
