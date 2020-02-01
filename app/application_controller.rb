# frozen_string_literal: true

require_relative 'controllers/garage_controller'
require_relative 'utils'

class ApplicationController
  def self.call(controller, data, response_method)
    klass, action = controller.split('#')
    controller = Object.const_get("#{klass}_controller".camelize).send(:new, data, response_method)
    puts "ApplicationController data: #{data}"

    response = controller.send action.to_sym, data

    response_method[:method][response]
  rescue => e
    Utils.error e
    raise e
  end
end
