# typed: false
# frozen_string_literal: true

require 'net/http'

module SlackApp
  class HTTPClient
    def self.views_publish(payload)
      post('https://slack.com/api/views.publish', payload)
    end

    def self.views_update(payload)
      post('https://slack.com/api/views.update', payload)
    end

    def self.views_open(payload)
      post('https://slack.com/api/views.open', payload)
    end

    def self.post(url, payload, token = ENV['SLACK_API_TOKEN'])
      uri  = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.initialize_http_header(authorization(token)) if token
      request.content_type = 'application/json'
      request.body = payload.to_json

      http.request(request)
    end

    def self.authorization(token)
      { authorization: "Bearer #{token}" }
    end
  end
end