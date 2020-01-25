require 'aws-sdk-dynamodb'
require_relative 'utils'

module Dynamo
  TABLE_NAME = ENV['DYNAMO_GARAGE_TABLE']
  DB         = Aws::DynamoDB::Client.new

  Aws.config.update(region: ENV['AWS_REGION'])

  def self.primary_key(date, building)
    {
      'date'     => Utils.date_to_timestamp(date),
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

    item = DB.get_item(params)
    item
  rescue  Aws::DynamoDB::Errors::ServiceError => error
    puts "Unable to read item:"
    puts "#{error.message}"
  end

  def self.persist(date, building, payload)
    pk = Utils.date_to_timestamp(date)

    data = params(date, building, payload)

    begin
      DB.put_item(data)
      puts "Added item: #{pk}  - #{building}: #{payload}"

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to add item:"
      puts "#{error.message}"
    end
  end
end
