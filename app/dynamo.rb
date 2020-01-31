# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require_relative 'utils'

module Dynamo
  TABLE_NAME = ENV['DYNAMO_GARAGE_TABLE']
  DB         = Aws::DynamoDB::Client.new

  Aws.config.update(region: ENV['AWS_REGION'])

  def self.primary_key(date, building)
    raise "date '#{date}' must be a Date or String, was s #{date.class}" unless date.is_a?(Date) || date.is_a?(String)
    raise "building '#{building}' must be a string, was s #{building.class}" unless building.is_a? String
    {
      'date' => Utils.date_to_timestamp(date),
      'building' => building
    }
  end

  def self.params(date, building, payload)
    {
      table_name: TABLE_NAME,
      item: primary_key(date, building).merge('payload' => payload)
    }
  end

  def self.fetch(date, building)
    params = {
      table_name: TABLE_NAME,
      key: primary_key(date, building)
    }

    DB.get_item(params)
  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts 'Unable to read item:'
    Utils.error e
  end

  def self.persist(date, building, payload)
    raise "date '#{date}' must be a Date or String, was s #{date.class}" unless date.is_a?(Date) || date.is_a?(String)
    raise "building '#{building}' must be a string, was s #{building.class}" unless building.is_a? String

    data = params(date, building, payload)

    begin
      DB.put_item(data)
      puts "Added item: #{date}  - #{building}: #{payload}"
    rescue Aws::DynamoDB::Errors::ServiceError => e
      puts 'Unable to add item:'
      Utils.error e
    end
  end
end
