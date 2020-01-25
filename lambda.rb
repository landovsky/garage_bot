require 'json'

def handler(event:, context:)
  request_data = URI.decode_www_form(event).to_h
  # response_body = Controller.call(request_data)
  { statusCode: 200, body: request_data }
rescue => e
  { statusCode: 400, body: { error: e }
end
