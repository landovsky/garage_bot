# frozen_string_literal: true

module Slack
  module DSLTwo
    def section(text = nil, type: :plain_text, accessory: nil, fields: nil, block_id: nil)
      base = {
        type: 'section',
        block_id: block_id || rand(1..10_000).to_s
      }

      out = base.merge(text: { type: type, text: text }) if text
      out = out.merge(fields: fields) if fields
      out = out.merge(accessory: accessory) if accessory
      out
    end

    def divider
      {
        type: 'divider'
      }
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
  end
end
