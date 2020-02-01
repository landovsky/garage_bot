# frozen_string_literal: true

load_paths = Dir['vendor/ruby/2.5.0/**/lib']
$LOAD_PATH.unshift(*load_paths)

require 'json'
require_relative 'app/slack_router'

def handler(event:, context:)
  response_body = SlackRouter.call(event['body'])
  { statusCode: 200, body: response_body.to_json }
end
