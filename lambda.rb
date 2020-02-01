# frozen_string_literal: true

require 'json'
require_relative 'app/controller'

def handler(event:, context:)
  response_body = Controller.call(event['body'])
  { statusCode: 200, body: response_body.to_json }
end
