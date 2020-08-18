# typed: strong
# frozen_string_literal: true

require_relative 'slack_app/application_controller'
require_relative 'slack_app/dsl'
require_relative 'slack_app/helper'
require_relative 'slack_app/http_client'
require_relative 'slack_app/router'
require_relative 'slack_app/utils'

require_relative 'views/garage_view'
require_relative 'controllers/garage_controller'

require 'active_support/core_ext/hash'

module SlackApp
end
