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

  def self.blocks
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
        },
        {
          "type": "section",
                "block_id": "EJKJ2EI-monday",
          "text": {
            "type": "mrkdwn",
            "text": "*Monday*\nspot 553"
          },
          "accessory": {
            "type": "button",
                    "style": "danger",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Cancel"
            },
            "value": "cancel-monday"
          }
        },
            {
          "type": "section",
                "block_id": "EJKJEI-tuesday",
          "text": {
            "type": "mrkdwn",
            "text": "*Tuesday*\n#{Time.now}"
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Reserve"
            },
            "value": "book-tuesday"
          }
        },
            {
          "type": "section",
                "block_id": "EJKJEI-wednesday",
          "text": {
            "type": "mrkdwn",
            "text": "*Wednesday*\nall places are taken"
          }
        },
            {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Thursday*\nspot 534"
          },
          "accessory": {
            "type": "button",
                    "style": "danger",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Cancel"
            },
            "value": "cancel-thursday"
          }
        },
            {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Friday*\nparking available"
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Reserve"
            },
            "value": "book-friday"
          }
        },
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
