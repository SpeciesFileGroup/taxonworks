class TimeHourValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_hour, 0)
    @max_value = options.fetch(:max_hour, 23)
    super
  end
end