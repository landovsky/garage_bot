module SlackLocal
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
        "type": "plain_text",
        "text": "Parking in"
      }
    }.merge(accessory: building_picker)
  end

  def self.divider
    {
      "type": "divider"
    }
  end

  def self.building_picker
    {
      "type": "static_select",
      "placeholder": {
        "type": "plain_text",
        "text": "Select an item",
        "emoji": true
      },
      "options": [
        {
          "text": {
            "type": "plain_text",
            "text": "Choice 1",
            "emoji": true
          },
          "value": "value-0"
        },
        {
          "text": {
            "type": "plain_text",
            "text": "Choice 2",
            "emoji": true
          },
          "value": "value-1"
        },
        {
          "text": {
            "type": "plain_text",
            "text": "Choice 3",
            "emoji": true
          },
          "value": "value-2"
        }
      ]
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

  def self.create_message(days_data, building)
    {
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
