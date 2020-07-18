# typed: false
# frozen_string_literal: true

require_relative '../garage'
require_relative '../store'

class GarageController
  def initialize(data, _response_method)
    data.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
  end

  def park(data)
    building  = data.dig(:params, :building) || Garage::RIVER
    days_data = Garage.park(data[:user_id], building)

    GarageView.new.garage(days_data, building)
  end

  def book_spot(data)
    building = data[:params][:building]
    spot_id  = data[:spot_id]

    Store.book_spot(data[:date], data[:user_id], building, spot_id)

    days_data = Garage.park(data[:user_id], building)
    GarageView.new.garage(days_data, building)
  end

  def cancel_spot(data)
    building = data[:params][:building]
    spot_id  = data[:spot_id]

    Store.cancel_spot(data[:date], data[:user_id], building, spot_id)

    days_data = Garage.park(data[:user_id], building)
    GarageView.new.garage(days_data, building)
  end

  private

  def day_text(day_data)
    if day_data[:booked_spot]
      "park on spot #{day_data[:booked_spot_id]}"
    elsif day_data[:vacancy]
      ':car: parking available'
    else
      'all places are taken'
    end
  end

  def build_day(day_data, building)
    date = day_data[:date]
    button = day_data[:booked_spot] ? button(:cancel, date) : (day_data[:vacancy] && button(:book, date))

    day(date.strftime('%A'), day_text(day_data), building, button)
  end
end
