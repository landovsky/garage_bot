# typed: false
# frozen_string_literal: true

module SlackApp
  module DSL
    def self.home_view(*blocks)
      view blocks(*blocks), type: :home
    end

    def self.modal_view(blocks)
      modal(blocks)
    end

    def self.view(content, type:)
      content.merge(type: type)
    end

    def self.modal(content)
      {
        "type": "modal",
        "title": {
          "type": "plain_text",
          "text": "My App",
          "emoji": true
        },
        "submit": {
          "type": "plain_text",
          "text": "Submit",
          "emoji": true
        },
        "close": {
          "type": "plain_text",
          "text": "Cancel",
          "emoji": true
        }
      }.merge(blocks(content))
    end

    def self.blocks(*blocks)
      { blocks: blocks }
    end

    def section(text = nil, type: :plain_text, accessory: nil, fields: nil, block_id: random_block_id)
      base = {
        type: 'section',
        block_id: block_id
      }

      base = base.merge(text: { type: type, text: text }) if text
      base = base.merge(fields: fields) if fields
      base = base.merge(accessory: accessory) if accessory
      base
    end

    def divider
      {
        type: 'divider'
      }
    end

    def actions(elements, block_id: random_block_id, **opts)
      {
        type: 'actions',
        block_id: block_id,
        elements: [elements].flatten
      }.merge(opts)
    end

    def button(text, action:, **opts)
      {
        type: 'button',
        text: {
          type: 'plain_text',
          text: text
        },
        action_id: action
      }.merge(opts)
    end

    def datepicker(action:)
      {
        type: 'datepicker',
        initial_date: '1990-04-28',
        action_id: action,
        placeholder: {
          type: 'plain_text',
          text: 'Select a date',
          emoji: true
        }
      }
    end

    private

    def random_block_id
      rand(1..10_000).to_s
    end
  end
end
