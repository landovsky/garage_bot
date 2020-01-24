require 'aws-sdk-dynamodb'
require 'pry'

module Dynamo
  TABLE_NAME = 'applifting-parking'
  RIVER      = 'river'

  def self.all_spots(building = RIVER)
    data = {
      Dynamo::RIVER => [500, 501, 502, 503, 504, 505]
    }
    data[building]
  end

  DAY_SPOTS =
    [
      { 'spot_id' => 502, 'spot_user' => "ivan"},
      { 'spot_id' => 500, 'spot_user' => "tomas"},
      { 'spot_id' => 501, 'spot_user' => "petr"}
    ].freeze

  def self.action_merge_booking(day_spots, spot_id, user)
    day_spots.reject { |spot| spot['spot_id'] == spot_id } << ({ 'spot_id': spot_id, 'spot_user': user })
  end

  def self.action_cancel_booking(day_spots, user)
    day_spots.reject { |spot| spot['spot_user'] == user }
  end

  def self.first_available_spot(day_spots)
    taken_spots = day_spots.map { |spot| spot['spot_id'].to_i }

    (all_spots - taken_spots).first
  end

  def self.spot_available?(day_spots)
    first_available_spot(day_spots).is_a? Integer
  end

  def self.timestamp_to_date(unixtime)
    DateTime.strptime(unixtime.to_s, '%s')
  end

  def self.date_to_timestamp(date)
    beginning_of_day = Date.new(date.year, date.month, date.day)
    beginning_of_day.to_time.to_i
  end

  def self.book(date, user, building = RIVER)
    day_spots = load_item(date, building)

    spot_id = first_available_spot(day_spots)
    return false unless spot_id

    new_payload = action_merge_booking(day_spots, spot_id, user)

    store(date, building, new_payload)
  end

  def self.cancel(date, user, building = RIVER)
    day_spots = load_item(date, building)

    new_payload = action_cancel_booking(day_spots, user)

    store(date, building, new_payload)
  end

  def self.config
    Aws.config.update(region: "eu-central-1")
  end

  def self.primary_key(date, building)
    {
      'date'     => date_to_timestamp(date),
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

    pk = date_to_timestamp(date)

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

    dynamodb.get_item(params)
  rescue  Aws::DynamoDB::Errors::ServiceError => error
    puts "Unable to read item:"
    puts "#{error.message}"
  end
end

Dynamo.config
# Dynamo.store(Time.now, Dynamo::RIVER, "1", "tomas")
# Dynamo.load(Time.now, Dynamo::RIVER)
