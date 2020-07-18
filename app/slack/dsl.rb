# typed: false
# frozen_string_literal: true

module Slack
  module DSL
    def self.home_view(*blocks)
      view blocks(*blocks)
    end

    def self.view(content)
      content.merge(type: :home)
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

    private

    def random_block_id
      rand(1..10_000).to_s
    end
  end
end
