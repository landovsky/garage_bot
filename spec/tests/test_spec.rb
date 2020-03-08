# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackRouter do
  it 'does good' do
    file = load_expectation 'app_home_book'
    binding.pry
    expect(true).to be true
  end
end
