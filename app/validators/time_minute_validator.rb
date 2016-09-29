class TimeMinuteValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_minute, 0)
    @max_value = options.fetch(:max_minute, 59)
    super
  end
end