# typed: true
# frozen_string_literal: true

require_relative 'dynamo'

module Store
  def self.all_spots(_building, _email_domain)
    # 14 - permanently reserved for EduVerse
    # 79 - permanently reserved for Merchantee
    # 80 - permanently reserved for Colours of Data

    shared_spots = [15, 30, 31, 32, 80, 81, 82, 83, 155, 156, 158, 159, 160, 166, 191, 197, 199, 200, 201, 202]

    # This can be used to assign different spots to different email domains
    _data = {
      Garage::RIVER => {
        'applifting.cz' => shared_spots
      }
    }

    shared_spots
  end

  def self.book_spot(date, user, building, spot_id, email_domain)
    day_spots = load_item(date, building)

    return false unless spot_id_available?(day_spots, building, spot_id.to_i, email_domain)

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

  def self.available_spots(day_spots, building, email_domain)
    taken_spots = day_spots.map { |spot| spot['spot_id'].to_i }

    all_spots(building, email_domain) - taken_spots
  end

  def self.spot_id_available?(day_spots, building, spot_id, email_domain)
    available_spots(day_spots, building, email_domain).include? spot_id.to_i
  end

  def self.load_item(date, building)
    raw = Dynamo.fetch(date, building)

    raw.dig('item', 'payload') || []
  end
end
