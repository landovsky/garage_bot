# frozen_string_literal: true

require_relative 'dynamo'

module Store
  def self.all_spots(building)
    data = {
      Garage::RIVER => [159, 160, 161, 165, 166],
      Garage::SALDOVKA => [1, 2, 3, 4]
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

  def self.call(action, date, user, building)
    if action == :book
      book(date, user, building)
    else
      cancel(date, user, building)
    end
  end

  def self.book(date, user, building)
    day_spots = load_item(date, building)

    spot_id = first_available_spot(day_spots, building)
    return false unless spot_id

    action_merge_booking(day_spots, spot_id, user).tap do |new_payload|
      Dynamo.persist(date, building, new_payload)
    end
  end

  def self.cancel(date, user, building)
    day_spots = load_item(date, building)

    action_cancel_booking(day_spots, user).tap do |new_payload|
      Dynamo.persist(date, building, new_payload)
    end
  end

  def self.load_item(date, building)
    raw = Dynamo.fetch(date, building)

    raw.dig('item', 'payload') || []
  end
end
