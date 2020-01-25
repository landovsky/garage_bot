require 'rest-client'

class HTTPClient
  def self.post(url, payload)
    RestClient.post(url, payload, headers={ "Content-type" => "application/json"})
  end
end
