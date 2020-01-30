# frozen_string_literal: true

require_relative 'controllers/garage_controller'

class ApplicationController
  def self.call(controller, data, response_method)
    klass, action = controller.split('#')
    controller = "#{klass}_controller".camelize.constantize.send(:new, data, response_method)
    controller.send action.to_sym, data
  end
end
