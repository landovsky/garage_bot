#!/usr/bin/env ruby

# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pry'

require_relative 'app/slack_router'

ENV['BOT_ENV'] = 'test'

module Tests
  class << self
    def call
      results = []
      results << app_home_book
      results << app_home_cancel
      results << app_home_opened
      results << app_home_select
      results << command
      results << message_response
      results << message_response_button
      results << message_response_select
      results << challenge
      puts results.flatten.compact.count
    end

    def app_home_book
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result[:view], 8)
      results << 'view type mismatch' unless actual_result[:view][:type] != 'home'
      print_results(results, __method__)
    end

    def app_home_cancel
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result[:view], 8)
      results << 'view type mismatch' unless actual_result[:view][:type] != 'home'
      print_results(results, __method__)
    end

    def app_home_opened
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result[:view], 8)
      results << 'view type mismatch' unless actual_result[:view][:type] != 'home'
      print_results(results, __method__)
    end

    def app_home_select
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result[:view], 8)
      results << 'view type mismatch' unless actual_result[:view][:type] != 'home'
      print_results(results, __method__)
    end

    def command
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result, 8)
      print_results(results, __method__)
    end

    def message_response
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result, 8)
      print_results(results, __method__)
    end

    def message_response_button
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result, 8)
      print_results(results, __method__)
    end

    def message_response_select
      raw_request, expected_result = load_expectation(__method__)
      actual_result = SlackRouter.call(raw_request).symbolize_keys

      results = []
      results << base_keys_present(expected_result, actual_result)
      results << base_keys_not_blank(actual_result)
      results << match_block_count(actual_result, 8)
      print_results(results, __method__)
    end

    def challenge
      raw_request, expected_result = [File.read('fixtures/challenge.txt'), File.read('fixtures/challenge.json')]
      actual_result = SlackRouter.call(raw_request)

      'challenge verification failed' unless actual_result == JSON.parse(raw_request)['challenge']
    end

    def load_expectation(event)
      [File.read("fixtures/#{event}.txt"), JSON.parse(File.read("fixtures/#{event}.json")).symbolize_keys]
    end

    def match_block_count(blocks, expected_count)
      'view blocks count mismatch' unless blocks[:blocks].count == expected_count
    end

    def base_keys_present(expected_result, actual_result)
      expected_keys = expected_result.keys.sort
      actual_keys   = actual_result.keys.sort
      result = expected_keys == actual_keys
      output = %{some of base keys are missing:
        expected keys: #{expected_keys}
        actual keys: #{actual_keys}
      }
      output unless result
    end

    def base_keys_not_blank(actual_result)
      'some base keys are empty' unless actual_result.none? { |k, v| v.empty? }
    end

    def print_results(results, meth)
      puts section(meth) unless results.empty?
      results.each { |r| puts r } unless results.empty?
      results.compact
    end

    def section(method)
      puts '_________________________'
      puts method
    end
  end
end

Tests.call
