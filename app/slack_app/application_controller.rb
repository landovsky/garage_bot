# typed: true
# frozen_string_literal: true

require_relative 'utils'

module SlackApp
  class ApplicationController
    def self.call(controller, data, response_handler)
      klass, action = controller.split('#')
      controller = Object.const_get("#{klass}_controller".camelize).send(:new, data, response_handler)
      payload    = controller.send action.to_sym, data

      res = response_handler[:method][payload]
      puts "Slack message: #{res.message}"
      body = JSON.parse res.body
      puts "Error: #{body}" unless body['ok']
      res
    rescue => e
      Utils.error e
      raise e
    end
  end
end