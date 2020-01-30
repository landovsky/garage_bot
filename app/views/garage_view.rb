# frozen_string_literal: true

require_relative '../slack/dsl_two'
require_relative '../slack_router'

class GarageView
  include Slack::DSLTwo

  def render
    button = button('Cancel', action: SlackRouter.action(:garage, :book, date: Utils.date_to_timestamp(DateTime.now)))
    section 'Parking', accessory: button
  end
end
