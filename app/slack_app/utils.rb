# typed: true
# frozen_string_literal: true

module SlackApp
  module Utils
    class << self
      def error(e)
        puts '==== ERROR ===='
        puts e
        puts e.backtrace[0..2]
        puts '==============='
      end
    end
  end
end