require_relative 'http_client'
require_relative 'dynamo'
require_relative 'utils'

module GarageBot
  DAY_SEC = 86_400
  DAY_COUNT = 5

  def self.garage(user, building = Dynamo::RIVER)
    date_data = (Utils.today..Utils.days_from_now(DAY_COUNT)).map do |date|
      garage_on(date, user, building)
    end

    message(date_data, building)
  end

  def self.garage_on(date, user, building = Dynamo::RIVER)
    day_spots      = Dynamo.load_item(date, building)
    booked_spot_id = day_spots.find { |spot| spot['spot_user'] == user }&.dig('spot_id')&.to_i
    spot_available = Dynamo.spot_available?(day_spots, building) unless booked_spot_id

    { date: date, booked_spot: !!booked_spot_id, booked_spot_id: booked_spot_id, vacancy: spot_available }
  end

  def self.day_text(day_data)
    if day_data[:booked_spot]
      "park on spot #{day_data[:booked_spot_id]}"
    elsif day_data[:vacancy]
      ':car: parking available'
    else
      'all places are taken'
    end
  end

  def self.header(building)
    {
      "type": "section",
      "block_id": "EJKJEI",
      "text": {
        "type": "mrkdwn",
        "text": "Parking in *#{building.upcase}*"
      }
    }
  end

  def self.divider
    {
      "type": "divider"
    }
  end

  def self.build_day(day_data, building)
    date = day_data[:date]
    button = day_data[:booked_spot] ? button(:cancel, date) : (day_data[:vacancy] && button(:book, date))

    day(date.strftime('%A'), day_text(day_data), building, button)
  end

  def self.day(name, status, building, button = nil)
    base = {
      "type": "section",
            "block_id": [building, rand(1..1000000).to_s].join('-'),
      "text": {
        "type": "mrkdwn",
        "text": "*#{name}*\n#{status}"
      }
    }
    button ? base.merge(accessory: button) : base
  end

  def self.button(type, day)
    base = {
      "type": "button",
      "text": {
        "type": "plain_text",
        "emoji": true,
        "text": type.to_s.upcase
      },
      "value": day
    }
    type == :cancel ? base.merge('style': 'danger') : base
  end

  def self.message(days_data, building)
    {
      "replace_original": true,
      "blocks": [
        header(building),
        divider,
        *days_data.map {|day_data| build_day(day_data, building) }
      ]
    }
  end

  def self.link
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*<fakelink.ToMoreTimes.com|Show me next week>*"
      }
    }
  end
end
