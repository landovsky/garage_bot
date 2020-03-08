# typed: false
# frozen_string_literal: true

require_relative '../slack/dsl_two'
require_relative '../slack_router'
require_relative '../utils'

class GarageView
  U = Utils
  include Slack::DSLTwo

  # { date_data: date_data, building: building }
  # { date: date, booked_spot: !!booked_spot_id, booked_spot_id: booked_spot_id, vacancy: spot_available }

  def view
    binding.pry
    Slack::DSLTwo.home_view actions(button('Cancel', action: SlackRouter.action(:garage, :cancel, date: "12323", building: 'ahaha'), style: :danger))
  end

  def garage(days_data, building)
    content = []
    content << section('Parking in')
    content << actions(building_picker(building))
    content << days_data.map { |day_data| build_day(day_data, building) }
    c = content.flatten
    File.open('content.json', 'wb') { |file| file.write(JSON.dump(c)) } if ENV['BOT_ENV'] == 'dev'
    c
  end

  private

  def build_day(day_data, building)
    date = day_data[:date]
    btn  = if day_data[:booked_spot]
             button('Cancel', action: SlackRouter.action(:garage, :cancel, date: date, building: building), style: :danger)
           elsif day_data[:vacancy]
             button('Book', action: SlackRouter.action(:garage, :book, date: date, building: building))
           end

    section("*#{date.strftime('%A')}*\n#{day_text(day_data)}", type: 'mrkdwn', accessory: btn)
  end

  def day_text(day_data)
    if day_data[:booked_spot]
      "park on spot #{day_data[:booked_spot_id]}"
    elsif day_data[:vacancy]
      ":car: #{day_data[:vacancies]} #{day_data[:vacancies] == 1 ? 'spot' : 'spots'} available"
    else
      'all places are taken'
    end
  end

  def day(name, status, building, button = nil)
    base = {
      'type': 'section',
      'block_id': [building, rand(1..1_000_000).to_s].join('-'),
      'text': {
        'type': 'mrkdwn',
        'text': "*#{name}*\n#{status}"
      }
    }
    button ? base.merge(accessory: button) : base
  end

  def building_picker(building)
    # HACK, solution is to get actions.selected_option.value from interaction payload
    next_building = building == Garage::SALDOVKA ? Garage::RIVER : Garage::SALDOVKA
    {
      'type': 'static_select',
      'action_id': SlackRouter.action(:garage, building: next_building),
      'placeholder': {
        'type': 'plain_text',
        'text': 'Select an item',
        'emoji': true
      },
      'initial_option': {
        'text': {
          'type': 'plain_text',
          'text': building.camelize,
          'emoji': true
        },
        'value': building
      },
      'options': [
        {
          'text': {
            'type': 'plain_text',
            'text': Garage::SALDOVKA.camelize,
            'emoji': true
          },
          'value': Garage::SALDOVKA
        },
        {
          'text': {
            'type': 'plain_text',
            'text': Garage::RIVER.camelize,
            'emoji': true
          },
          'value': Garage::RIVER
        }
      ]
    }
  end
end
