require 'rubygems'
require 'bundler/setup'

require 'slack'

require_relative 'app/store'
require_relative 'app/garage'
require_relative 'app/router'
require_relative 'app/views/garage_view'
require_relative 'app/slack/dsl_two'

# client = Slack.configure do |config|
#   config.token = ENV['SLACK_API_TOKEN']
# end
# SLACK = Slack::Web::Client.new

pay = proc { |action| { 'user' => { 'id' => 'DKJ9389' }, 'actions' => { 'action_id' => action } } }

app_home_button = JSON.parse File.read('tmp/app_home-book_btn.json')
app_home_select = JSON.parse File.read('tmp/app_home-select.json')

p0 = pay.call 'garage'
p1 = pay.call 'garage/333'
p2 = pay.call 'garage/398493/neco'
p3 = pay.call 'garage/398493/book?neco=333&aha=1'

g = GarageView.new
