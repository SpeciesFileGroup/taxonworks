class DateYearValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_year, 1000)
    @max_value = options.fetch(:max_year, Time.now.year + 5)
    super
  end
end