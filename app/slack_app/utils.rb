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

      def log_output(output)
        File.open('tmp/output.json', 'wb') { |file| file.write(JSON.dump(output)) }
      end
    end
  end
end