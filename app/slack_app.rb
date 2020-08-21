# typed: true
# frozen_string_literal: true

require 'slack/block_kit'

require_relative 'slack_app/application_controller'
require_relative 'slack_app/dsl'
require_relative 'slack_app/helper'
require_relative 'slack_app/http_client'
require_relative 'slack_app/router'
require_relative 'slack_app/utils'

require_relative 'views/garage_view'
require_relative 'controllers/garage_controller'

module SlackApp
end
