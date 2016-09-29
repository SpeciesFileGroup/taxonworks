class TimeSecondValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_second, 0)
    @max_value = options.fetch(:max_second, 59)
    super
  end
end