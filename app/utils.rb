# typed: true
# frozen_string_literal: true

require_relative 'hash'
require_relative 'string'

module Utils
  class << self
    def timestamp_to_date(unixtime)
      Date.strptime(unixtime.to_s, '%s')
    end

    def date_to_timestamp(date)
      date = DateTime.parse(date) if date.is_a? String
      beginning_of_day = Date.new(date.year, date.month, date.day)
      beginning_of_day.to_time.to_i
    end

    def today
      now = Time.now
      Date.new(now.year, now.month, now.day)
    end

    def days_from_now(number)
      today + number
    end

    def error(e)
      puts '==== ERROR ===='
      puts e
      puts e.backtrace[0..2]
      puts '==============='
    end
  end
end
