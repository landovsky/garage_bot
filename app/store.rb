# typed: true
# frozen_string_literal: true

require_relative 'dynamo'

module Store
  def self.all_spots(building)
    data = {
      Garage::RIVER => [155, 156, 157, 158, 159, 160, 161, 165, 166, 197, 199, 200, 201, 202],
      Garage::SALDOVKA => [1, 2, 3, 4]
    }
    data[building]
  end

  def self.book_spot(date, user, building, spot_id)
    day_spots = load_item(date, building)

    return false unless spot_id_available?(day_spots, building, spot_id.to_i)

    action_merge_booking(day_spots, spot_id.to_i, user).tap do |new_payload|
      Dynamo.persist(date, building, new_payload)
    end
  end

  def self.cancel_spot(date, user, building, spot_id)
    day_spots = load_item(date, building)

    action_cancel_spot_booking(day_spots, user, spot_id.to_i).tap do |new_payload|
      Dynamo.persist(date, building, new_payload)
    end
  end

  def self.action_merge_booking(day_spots, spot_id, user)
    day_spots.reject { |spot| spot['spot_id'] == spot_id } << ({ 'spot_id': spot_id, 'spot_user': user })
  end

  def self.action_cancel_spot_booking(day_spots, user, spot_id)
    day_spots.reject { |spot| spot['spot_user'] == user && spot['spot_id'] == spot_id.to_i }
  end

  def self.available_spots(day_spots, building)
    taken_spots = day_spots.map { |spot| spot['spot_id'].to_i }

    all_spots(building) - taken_spots
  end

  def self.spot_id_available?(day_spots, building, spot_id)
    available_spots(day_spots, building).include? spot_id.to_i
  end

  def self.load_item(date, building)
    raw = Dynamo.fetch(date, building)

    raw.dig('item', 'payload') || []
  end
end
