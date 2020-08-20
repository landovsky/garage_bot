#!/usr/bin/env ruby
# typed: ignore

# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pry'
require 'yaml'

TMP      = 'tmp/'
FIXTURES = 'spec/fixtures/'
VCRS     = 'spec/vcr_cassettes/'

variants = %w[
  app_home_opened app_home_book app_home_cancel app_home_parkers
  app_home_select command_invoke command_book command_cancel command_select
  command_parkers challenge
]

def move_files(variant)
  errors = []
  if File.exist? "#{TMP}payload_raw.txt"
    `mv #{TMP}payload_raw.txt #{FIXTURES}#{variant}.txt`
    puts " - raw payload moved.\n"
  else
    errors << { error: "No raw request found." }
  end

  if File.exist? "#{TMP}output.json"
    `mv #{TMP}output.json #{FIXTURES}#{variant}.json`
    puts " - output json moved.\n"
  else
    errors << { error: "No output json found." }
  end
  errors
end

def save_variant_timestamp(variant)
  fixtures_yaml = "#{FIXTURES}fixtures.yml"
  previous_data = YAML.load File.read(fixtures_yaml)
  new_data      = previous_data ? previous_data.merge(variant => Time.now) : { variant => Time.now }
  File.open(fixtures_yaml, 'w+') { |file| file.write(YAML.dump new_data) }
end

def remove_vcr_cassette(variant)
  cassette = VCRS + variant.to_s + '.yml'
  if File.exist?(cassette)
    File.delete(cassette)
    puts " - cassette deleted.\n"
  end
end

while true
  variants.each_with_index do |index, item|
    puts "#{item}) #{index}\n"
  end
  puts "\n"
  variant_code = gets.chomp
  break if variant_code == 'q'
  variant_name = variants[variant_code.to_i]

  puts "Processing #{variant_name}...\n"
  errors = move_files(variant_name)

  if errors.empty?
    save_variant_timestamp(variant_name)
    remove_vcr_cassette(variant_name)
  else
    puts errors.map { |i| i[:error] }.join(', ')
    puts "Continue? (y/n)"
    input = gets.chomp
    break if input == 'n'
  end
end
