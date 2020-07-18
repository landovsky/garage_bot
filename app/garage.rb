# typed: true
# frozen_string_literal: true

require_relative 'store'
require_relative 'utils'

module Garage
  DAY_SEC = 86_400
  DAY_COUNT = 5

  SALDOVKA = 'saldovka'
  RIVER    = 'river'

  def self.park(user, building = RIVER)
    (Utils.today..Utils.days_from_now(DAY_COUNT)).map do |date|
      park_on(date, user, building)
    end
  end

  def self.park_on(date, user, building = RIVER)
    day_spots      = Store.load_item(date, building)
    booked_spot_id = day_spots.find { |spot| spot['spot_user'] == user }&.fetch('spot_id', nil)&.to_i
    spot_available = Store.spot_available?(day_spots, building) unless booked_spot_id

    {
      date: date,
      booked_spot: !!booked_spot_id,
      booked_spot_id: booked_spot_id,
      vacancy: spot_available,
      vacancies: count_available_spots(day_spots, building)
    }
  rescue => e
    Utils.error e
    raise e
  end

  def self.count_available_spots(day_spots, building)
    Store.all_spots(building).count - day_spots.count
  end
end
