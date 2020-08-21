# typed: ignore
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'App home' do
  let(:router)     { SlackApp::Router }
  let(:timestamps) { YAML.load(File.open('spec/fixtures/fixtures.yml')) }

  describe 'open bot from app home' do
    it_behaves_like 'recorded response', :app_home_opened
  end

  describe 'book a spot' do
    it_behaves_like 'recorded response', :app_home_book
  end

  describe 'cancel a spot' do
    it_behaves_like 'recorded response', :app_home_cancel
  end

  describe 'show parkers' do
    it_behaves_like 'recorded response', :app_home_parkers
  end

  describe 'change building from select' do
    it_behaves_like 'recorded response', :app_home_select
  end
end
