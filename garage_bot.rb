require_relative 'http_client'
require_relative 'dynamo'

class GarageBot
  def initialize(request)
    @request = request
    puts request
  end

  def self.garage(user, building = Dynamo::RIVER)
    date_data = garage_on(Time.now, user, building)
    # day_data2 = garage_on(DateTime.new(Time.now.year, Time.now.month, Time.now.day+1), user, building)
    message([date_data])
  end

  def self.garage_on(date, user, building = Dynamo::RIVER)
    day_spots      = Dynamo.load_item(date)
    booked_spot_id = day_spots.find { |spot| spot['spot_user'] == user }&.dig('spot_id')&.to_i
    spot_available = Dynamo.spot_available?(day_spots) unless booked_spot_id

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

  def self.header
    {
      "type": "section",
      "block_id": "EJKJEI",
      "text": {
        "type": "plain_text",
        "emoji": true,
        "text": "Your parking for 14.5. - 22.4."
      }
    }
  end

  def self.divider
    {
      "type": "divider"
    }
  end

  def self.build_day(day_data)
    date = day_data[:date]
    button = day_data[:booked_spot] ? button(:cancel, date) : (day_data[:vacancy] && button(:book, date))

    day(date.strftime('%A'), day_text(day_data), button)
  end

  def self.day(name, status, button = nil)
    base = {
      "type": "section",
            "block_id": "EJKJ2EI-#{name}",
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

  def self.message(days_data)
    {
      "replace_original": true,
      "blocks": [
        header,
        divider,
        *days_data.map {|day_data| build_day(day_data) },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakelink.ToMoreTimes.com|Show me next week>*"
          }
        }
      ]
    }
  end
end
