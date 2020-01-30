# frozen_string_literal: true

require_relative '../views/garage_view'
require_relative '../garage'

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
  end
end
