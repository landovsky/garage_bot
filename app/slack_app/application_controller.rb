# typed: true
# frozen_string_literal: true

require_relative 'utils'

module SlackApp
  class ApplicationController
    def self.call(controller, data, response_method)
      klass, action = controller.split('#')
      controller = Object.const_get("#{klass}_controller".camelize).send(:new, data, response_method)
      response   = controller.send action.to_sym, data

      response_method[:method][response]
    rescue => e
      Utils.error e
      raise e
    end
  end
end