# typed: ignore
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'App home' do
  ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  let(:router) { SlackApp::Router }

  describe 'book a spot from app home' do
    it 'payload has expected number of keys' do
      raw_request, expected_result = load_expectation :app_home_book

      # binding.pry
      travel_to Time.parse('2020-08-18 20:50') do
        VCR.use_cassette("app_home_book") do |neco|
          binding.pry
          response = router.call(raw_request)
          parsed   = normalize_payload(deep_transform(JSON.parse(response.body)))

          expect(parsed.dig(:view, :blocks)).to eq expected_result.dig(:view, :blocks)
        end
      end
    end
  end

  describe 'cancel a spot from app home' do
    it 'payload has expected number of keys' do
      # raw_request, expected_result = load_expectation :app_home_cancel

      travel_to Time.parse('2020-08-18 20:45') do
        VCR.use_cassette("app_home_cancel", match_requests_on: %i[body]) do
          response = router.call(raw_request)
          # parsed   = normalize_payload(deep_transform(JSON.parse(response.body)))

          # expect(parsed.dig(:view, :blocks)).to eq expected_result.dig(:view, :blocks)
        end
      end
    end
  end

  describe 'show parkers' do
    it 'payload has expected number of keys' do
      raw_request, expected_result = load_expectation :app_home_parkers

      travel_to Time.parse('2020-08-18 20:45') do
        VCR.use_cassette("app_home_parkers", match_requests_on: %i[body]) do
          response = router.call(raw_request)
          # parsed   = normalize_payload(deep_transform(JSON.parse(response.body)))

          # expect(parsed.dig(:view, :blocks)).to eq expected_result.dig(:view, :blocks)
        end
      end
    end
  end

  describe 'change building from select', skip: 'WIP' do
    it 'payload has expected number of keys' do
      raw_request, expected_result = load_expectation :app_home_select

      travel_to Time.parse('2020-08-18 20:45') do
        VCR.use_cassette("app_home_select", match_requests_on: %i[body]) do
          response = router.call(raw_request)
          parsed   = normalize_payload(deep_transform(JSON.parse(response.body)))

          expect(parsed.dig(:view, :blocks)).to eq expected_result.dig(:view, :blocks)
        end
      end
    end
  end
end
