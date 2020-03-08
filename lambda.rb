# typed: false
# frozen_string_literal: true

load_paths = Dir['vendor/ruby/2.5.0/**/lib']
$LOAD_PATH.unshift(*load_paths)

require 'json'
require_relative 'app/slack_router'

def handler(event:, context:)
  raw_payload = event['body']
  raw_payload = Base64.decode64(raw_payload) if event['isBase64Encoded']
  response_body = SlackRouter.call(raw_payload)

  if response_body.is_a? String
    { statusCode: 200, body: response_body, headers: plain_text }
  else
    { statusCode: 200, body: response_body.to_json }
  end
end

def plain_text
  { 'content-type': 'text/plain' }
end
