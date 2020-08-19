#!/usr/bin/env ruby
# typed: ignore

# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pry'

variants = %w[
  app_home_book app_home_cancel app_home_opened app_home_parkers
  app_home_select challenge command message_book message_cancel
]

def rename_files(variant)
  if File.exist? 'tmp/payload_raw.txt'
    `mv tmp/payload_raw.txt spec/fixtures/#{variant}.txt`
  else
    { error: "No raw request found." }
  end

  if File.exist? 'tmp/output.json'
    `mv tmp/output.json spec/fixtures/#{variant}.json`
  else
    { error: "No output json found." }
  end
end

while true
  variants.each_with_index do |index, item|
    puts "#{item}) #{index}\n"
  end
  puts "\n"
  variant = gets.chomp
  break if variant == 'q'
  result = rename_files(variants[variant.to_i])
  if result[:error]
    puts result[:error]
    puts "Continue?"
    input = gets.chomp
    break if input == 'q'
  end
end
