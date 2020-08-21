# typed: ignore
# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples "recorded response" do |situation|
  ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  let(:something) { parameter }

  it 'actual response matches recorded response' do
    raw_request, expected_result = load_expectation situation.to_sym

    travel_to(timestamps[situation.to_s]) if cassette_exists?(situation.to_s)

    VCR.use_cassette(situation.to_s) do |cassette|
      response      = JSON.parse router.call(raw_request).to_json
      normalized    = normalize_payload(deep_symbolize_keys(response))

      actual_blocks   = response.dig(:view, :blocks)
      expected_blocks = expected_result.dig(:view, :blocks)

      expect(actual_blocks).to eq expected_blocks
    end

    travel_back if cassette_exists?(situation.to_s)
  end
end