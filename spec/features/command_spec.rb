# typed: ignore
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Invoke by command' do
  ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  let(:router)     { SlackApp::Router }
  let(:timestamps) { YAML.load(File.open('spec/fixtures/fixtures.yml')) }

  describe 'open bot by command' do
    it_behaves_like 'recorded response', :command_invoke
  end

  describe 'book a spot' do
    it_behaves_like 'recorded response', :command_book
  end

  describe 'cancel a spot' do
    it_behaves_like 'recorded response', :command_cancel
  end

  describe 'show parkers' do
    it_behaves_like 'recorded response', :command_parkers
  end

  describe 'change building from select' do
    it_behaves_like 'recorded response', :command_select
  end
end
