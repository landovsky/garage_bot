# frozen_string_literal: true

require 'slack'
require_relative 'garage'
require_relative 'store'
require_relative 'http_client'

module Controller
  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end

  SLACK = Slack::Web::Client.new

  def self.call(request_data)
    # /garage command received
    if request_data['token']
      command_text = request_data['text'][0]
      building     = command_text && command_text[0].downcase == 's' ? Garage::SALDOVKA : Garage::RIVER
      Garage.park(request_data['user_id'], building)

    # button interaction received
    else
      parsed   = JSON.parse request_data['payload']
      user     = parsed['user']['id']
      response = button_clicked?(parsed) ? parse_button(parsed, user) : parse_select(parsed, user)

      if parsed['view']
        view = Slack::DSL.view(:home, response)
        SLACK.views_publish(user_id: user, view: view)
      else
        HTTPClient.post(parsed['response_url'], response)
      end
    end
  rescue => e
    Utils.error e
  end

  def self.parse_button(payload, user)
    building = payload['actions'][0]['block_id'].split('-')[0]
    action   = payload['actions'][0]['text']['text'].downcase == 'book' ? :book : :cancel
    date     = DateTime.parse(payload['actions'][0]['value']).to_time
    _persist = Store.call(action, date, user, building)

    Garage.park(user, building)
  end

  def self.parse_select(payload, user)
    building = payload['actions'][0]['selected_option']['value']

    Garage.park(user, building)
  end

  def self.button_clicked?(payload)
    payload['actions'][0]['type'] == 'button'
  end
end
