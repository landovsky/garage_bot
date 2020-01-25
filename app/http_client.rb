require 'net/http'

class HTTPClient
  def self.post(url, payload)
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = "application/json"
    request.body = payload.to_json

    http.request(request)
  end
end
