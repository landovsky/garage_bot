require_relative 'http_client'

class GarageBot
  def initialize(request)
    @request = request
    puts request
  end

  def self.call(request)

  end

  def self.response
    {
      "replace_original": true,
      "blocks": [
        {
          "type": "section",
          "block_id": "EJKJEI",
          "text": {
            "type": "plain_text",
            "emoji": true,
            "text": "Your parking for 14.5. - 22.4."
          }
        },
        {
          "type": "divider"
        }
      ]
    }
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

  def self.day(name, status, button = nil)
    base = {
      "type": "section",
            "block_id": "EJKJ2EI-#{name}",
      "text": {
        "type": "mrkdwn",
        "text": "*#{name.upcase}*\n#{status}"
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
      "value": "#{type}-#{day}"
    }
    type == :cancel ? base.merge('style': 'danger') : base
  end

  def self.blocks
    {
      "replace_original": true,
      "blocks": [
        header,
        divider,
        day('monday', 'park on spot 553', button(:book, 'monday')),
        day('tuesday', ':car: parking available', button(:cancel, 'tuesday')),
        day('wednesday', 'all places are taken'),
        day('thursday', 'park on spot 553', button(:cancel, 'thursday')),
        day('friday', ':car: parking available', button(:book, 'friday')),
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
