class DateDayValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_day, 1)
    @max_value = options.fetch(:max_day, 31)

    if options.key?(:year_sym) && options.key?(:month_sym)
      year = record[options[:year_sym]]
      month = record[options[:month_sym]]

      begin
        @max_value = Time.utc(year, month).end_of_month.day
        @message = "#{value} is not a valid day for the month provided"
        
      rescue ArgumentError
        record.errors.add(options[:month_sym], "#{month} is not a valid month")
      end
    end

    super
  end
end