require 'aws-sdk-dynamodb'
require 'pry'
require_relative 'utils'

module Dynamo
  TABLE_NAME = 'applifting-parking'
  RIVER      = 'river'
  SALDOVKA   = 'saldovka'

  def self.all_spots(building = RIVER)
    data = {
      Dynamo::RIVER => [159, 160, 161, 165, 166],
      Dynamo::SALDOVKA => [1, 2, 3, 4]
    }
    data[building]
  end

  def self.action_merge_booking(day_spots, spot_id, user)
    day_spots.reject { |spot| spot['spot_id'] == spot_id } << ({ 'spot_id': spot_id, 'spot_user': user })
  end

  def self.action_cancel_booking(day_spots, user)
    day_spots.reject { |spot| spot['spot_user'] == user }
  end

  def self.first_available_spot(day_spots, building)
    taken_spots = day_spots.map { |spot| spot['spot_id'].to_i }

    (all_spots(building) - taken_spots).first
  end

  def self.spot_available?(day_spots, building)
    first_available_spot(day_spots, building).is_a? Integer
  end

  def self.book(date, user, building = RIVER)
    day_spots = load_item(date, building)

    spot_id = first_available_spot(day_spots, building)
    return false unless spot_id

    action_merge_booking(day_spots, spot_id, user).tap do |new_payload|
      store(date, building, new_payload)
    end
  end

  def self.call(action, date, user, building = RIVER)
    if action == :book
      book(date, user, building)
    else
      cancel(date, user, building)
    end
  end

  def self.cancel(date, user, building = RIVER)
    day_spots = load_item(date, building)

    action_cancel_booking(day_spots, user).tap do |new_payload|
      store(date, building, new_payload)
    end
  end

  def self.config
    Aws.config.update(region: "eu-central-1")
  end

  def self.primary_key(date, building)
    {
      'date'     => Utils.date_to_timestamp(date),
      'building' => building
    }
  end

  def self.params(date, building = RIVER, payload)
    {
      table_name: TABLE_NAME,
      item: primary_key(date, building).merge('payload' => payload)
    }
  end

  def self.store(date, building = RIVER, payload)
    dynamodb = Aws::DynamoDB::Client.new

    pk = Utils.date_to_timestamp(date)

    data = params(date, building, payload)

    begin
      dynamodb.put_item(data)
      puts "Added item: #{pk}  - #{building}: #{payload}"

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to add item:"
      puts "#{error.message}"
    end
  end

  def self.load_item(date, building = RIVER)
    raw = load(date, building)

    raw.dig('item', 'payload') || []
  end

  def self.load(date, building = RIVER)
    dynamodb = Aws::DynamoDB::Client.new

    params = {
      table_name: TABLE_NAME,
      key: primary_key(date, building)
    }

    item = dynamodb.get_item(params)
    item
  rescue  Aws::DynamoDB::Errors::ServiceError => error
    puts "Unable to read item:"
    puts "#{error.message}"
  end
end

Dynamo.config
