require 'rubygems'
require 'bundler/setup'

require 'slack'

require_relative 'app/store'
require_relative 'app/garage'
require_relative 'app/router'

# client = Slack.configure do |config|
#   config.token = ENV['SLACK_API_TOKEN']
# end
# SLACK = Slack::Web::Client.new

pay = proc { |action| { 'user' => { 'id' => 'DKJ9389' }, 'actions' => { 'action_id' => action } } }

p0 = pay.call 'garage'
p1 = pay.call 'garage/333'
p2 = pay.call 'garage/398493/neco'
p3 = pay.call 'garage/398493/book?neco=333&aha=1'
