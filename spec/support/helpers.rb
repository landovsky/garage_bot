# frozen_string_literal: true

module Helpers
  def load_expectation(event, request_format: :txt, response_format: :json)
    request = File.read("spec/fixtures/#{event}.#{request_format}")
    response = JSON.parse(File.read("fixtures/#{event}.#{response_format}")
    [request, response.symbolize_keys]
  end
end
