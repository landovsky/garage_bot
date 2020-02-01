# frozen_string_literal: true

class String
  def camelize
    split('_').map { |i| i[0].upcase + i[1..-1] }.join('')
  end
end
