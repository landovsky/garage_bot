module Utils
  def self.timestamp_to_date(unixtime)
    Date.strptime(unixtime.to_s, '%s')
  end

  def self.date_to_timestamp(date)
    beginning_of_day = Date.new(date.year, date.month, date.day)
    beginning_of_day.to_time.to_i
  end

  def self.today
    now = Time.now
    Date.new(now.year, now.month, now.day)
  end

  def self.days_from_now(number)
    today + number
  end
end
