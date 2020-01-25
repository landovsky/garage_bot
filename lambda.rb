require 'json'
require_relative 'app/controller'

def handler(event:, context:)
  request_data = URI.decode_www_form(event['body']).to_h
  response_body = Controller.call(request_data)
  { statusCode: 200, body: response_body.to_json }
end
