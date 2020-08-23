# typed: false
# frozen_string_literal: true

require_relative '../garage'
require_relative '../store'

class HolidayController < SlackApp::ApplicationController
  def app_mentioned
    respond_with thread: :book_button
    respond_with message: :book_button
    respond_with direct_message: :book_button
  end

  def new
    respond_with view: :new
  end

  def create
    update
    respond_with modal: :close

  end
end

#