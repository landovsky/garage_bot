# frozen_string_literal: true

require_relative '../views/garage_view'
require_relative '../garage'
require_relative '../store'

class GarageController
  def initialize(data, response_method)
    data.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
  end

  def garage(data)
    Garage.park(data[:user], data[:params][:building])
  end

  def book(data)
    Store.book(data[:date], data[:user], data[:building])

    GarageView.render
  end

  def cancel(data)
    Store.cancel(data[:date], data[:user], data[:building])

    GarageView.render
  end
end
