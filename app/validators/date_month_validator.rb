class DateMonthValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_month, 1)
    @max_value = options.fetch(:max_month, 12)
    super
  end
end