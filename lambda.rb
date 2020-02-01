# frozen_string_literal: true

require 'json'
require_relative 'app/slack_router'

def handler(event:, context:)
  response_body = SlackRouter.call(event['body'])
  { statusCode: 200, body: response_body.to_json }
end
