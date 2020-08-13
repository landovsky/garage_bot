# typed: false
# frozen_string_literal: true

require_relative '../utils'

class GarageView
  U = Utils
  include ::SlackApp::DSL
  include ::SlackApp::Helper

  def view
    binding.pry
    SlackApp::DSL.home_view actions(button('Cancel', action: path_for(:garage, :cancel, date: "12323", building: 'ahaha'), style: :danger))
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
    booked_spots = day_data[:booked_spot_ids].map do |booked_spot|
      button(booked_spot.to_s, action: path_for(:garage, :spot, :cancel, date: date, building: building, spot_id: booked_spot).to_s, style: :danger)
    end
    bookable_spots = day_data[:available_spot_ids].map do |available_spot|
      button(available_spot.to_s, action: path_for(:garage, :spot, :book, date: date, building: building, spot_id: available_spot).to_s)
    end
    buttons = booked_spots + bookable_spots
    if buttons.count.positive?
      [
        section(":#{date.strftime('%A')}: *#{date.strftime('%A')}*", type: 'mrkdwn'),
        actions(buttons)
      ].compact
    else
      [
        section(":#{date.strftime('%A')}: *#{date.strftime('%A')}*", type: 'mrkdwn'),
        section('All spots taken.')
      ]
    end
  end

  def building_picker(building)
    # HACK, solution is to get actions.selected_option.value from interaction payload
    next_building = building == Garage::SALDOVKA ? Garage::RIVER : Garage::SALDOVKA
    {
      'type': 'static_select',
      'action_id': path_for(:garage, building: next_building),
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
