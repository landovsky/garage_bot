require 'rubygems'
require 'bundler/setup'

# require_relative 'app/store'
# require_relative 'app/garage'
require_relative 'app/slack_router'
# require_relative 'app/views/garage_view'
# require_relative 'app/slack/dsl_two'

# pay = proc { |action| { 'user' => { 'id' => 'DKJ9389' }, 'actions' => { 'action_id' => action } } }
# p0 = pay.call 'garage'
# p1 = pay.call 'garage/333'
# p2 = pay.call 'garage/398493/neco'
# p3 = pay.call 'garage/398493/book?neco=333&aha=1'

app_home_button = JSON.parse File.read('tmp/app_home-book_btn.json')
app_home_select = JSON.parse File.read('tmp/app_home-select.json')
app_home_event  = JSON.parse File.read('tmp/app_home_opened.json')
view = JSON.parse File.read('view.json')


