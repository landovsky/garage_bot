# frozen_string_literal: true

require_relative 'http_client'
require_relative 'store'
require_relative 'utils'
require_relative 'slack/dsl'

module Garage
  DAY_SEC = 86_400
  DAY_COUNT = 5

  def self.park(user, building = Store::RIVER)
    date_data = (Utils.today..Utils.days_from_now(DAY_COUNT)).map do |date|
      park_on(date, user, building)
    end

    Slack::DSL.create_message(date_data, building)
  end

  def self.park_on(date, user, building = Store::RIVER)
    day_spots      = Store.load_item(date, building)
    booked_spot_id = day_spots.find { |spot| spot['spot_user'] == user }&.dig('spot_id')&.to_i
    spot_available = Store.spot_available?(day_spots, building) unless booked_spot_id

    { date: date, booked_spot: !!booked_spot_id, booked_spot_id: booked_spot_id, vacancy: spot_available }
  end
end
