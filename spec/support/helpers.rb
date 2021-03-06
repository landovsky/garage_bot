# frozen_string_literal: true

module Helpers
  def load_expectation(event)
    raw_request, expected_result = [
      File.read("spec/fixtures/#{event}.txt"),
      JSON.parse(File.read("spec/fixtures/#{event}.json")).symbolize_keys
    ]
    expected_result = normalize_payload(deep_symbolize_keys(expected_result))
    [raw_request, expected_result]
  end

  def normalize_payload(payload)
    if payload[:blocks]
      payload[:blocks] = payload[:blocks].map do |block|
        normalize_block block.merge(block_id: nil)
      end
    elsif payload[:view][:blocks]
      payload[:view][:blocks] = payload[:view][:blocks].map do |block|
        normalize_block block.merge(block_id: nil)
      end
    else
      raise 'Unknown payload structure.'
    end

    payload
  end

  def cassette_exists?(cassette_name)
    File.exist?('spec/vcr_casettes')
  end

  def deep_symbolize_keys(hash)
    hash.deep_transform_keys! { |key| key.to_sym }
  end

  private

  def normalize_block(block)
    if block[:text]
      block[:text] = block[:text].except(:verbatim, :emoji)
      block[:text][:text] = block[:text][:text].gsub('&gt;', '>')
    end
    block
  end
end
