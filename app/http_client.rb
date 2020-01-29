require 'net/http'

class HTTPClient
  def self.post(url, payload, token = ENV['SLACK_API_TOKEN'])
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.initialize_http_header(headers(token))
    request.body = payload.to_json

    http.request(request)
  end

  def self.headers(token = nil)
    base = base_headers
    token ? base.merge(authorization(token)) : base
  end

  def self.base_headers
    { "content-type": "application/json" }
  end

  def self.authorization(token)
    { "authorization": "bearer #{token}" }
  end
end
