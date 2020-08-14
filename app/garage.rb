# typed: true
# frozen_string_literal: true

require_relative 'store'
require_relative 'utils'

module Garage
  DAY_SEC   = 86_400
  DAY_COUNT = 4

  SALDOVKA = 'saldovka'
  RIVER    = 'river'

  def self.park(user, building = RIVER)
    (Utils.today..Utils.days_from_now(DAY_COUNT)).map do |date|
      park_on(date, user, building)
    end
  end

  def self.park_on(date, user, building = RIVER)
    day_spots          = Store.load_item(date, building)
    booked_spot_ids    = day_spots.select { |spot| spot['spot_user'] == user }.map { |spot| spot&.fetch('spot_id', nil)&.to_i }
    available_spot_ids = Store.available_spots(day_spots, building)

    {
      date: date,
      booked_spot_ids: booked_spot_ids,
      available_spot_ids: available_spot_ids,
      parked_users: day_spots
    }
  rescue => e
    Utils.error e
    raise e
  end
end
