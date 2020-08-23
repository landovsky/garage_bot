# typed: false
# frozen_string_literal: true

require_relative '../garage'
require_relative '../store'

class MockController < SlackApp::ApplicationController
  def park
    @building  = request.dig(:params, :building) || Garage::RIVER
    @days_data = Garage.park(request[:user_id], @building)

    respond_with view: :garage
  end

  def book_spot(data)
    @building = request[:request][:building]
    spot_id  = request[:spot_id]

    Store.book_spot(request[:date], request[:user_id], building, spot_id)

    @days_data = Garage.park(request[:user_id], @building)
    respond_with view: :garage
  end

  def cancel_spot(data)
    @building = request[:request][:building]
    spot_id  = request[:spot_id]

    Store.cancel_spot(request[:date], request[:user_id], building, spot_id)

    @days_data = Garage.park(request[:user_id], @building)
    respond_with view: :garage
  end

  def who_parked(data)
    building  = request.dig(:params, :building)
    @days_data = Garage.park(request[:user_id], building)

    respond_with modal: :who_parked
  end

  private

  def day_text(day_data)
    if day_request[:booked_spot]
      "park on spot #{day_request[:booked_spot_id]}"
    elsif day_request[:vacancy]
      ':car: parking available'
    else
      'all places are taken'
    end
  end

  def build_day(day_data, building)
    date = day_request[:date]
    button = day_request[:booked_spot] ? button(:cancel, date) : (day_request[:vacancy] && button(:book, date))

    day(date.strftime('%A'), day_text(day_data), building, button)
  end
end
