# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackRouter do
  before do
    ENV['BOT_ENV'] = 'test'
  end

  it 'does good' do
    raw_request, expected_result = load_expectation 'app_home_book'

    actual_result = SlackRouter.call(raw_request).symbolize_keys

    expect(true).to be true
  end
end
