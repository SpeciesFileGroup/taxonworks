=begin
  Child class of DateTimeValidator class

  Example on how to use this class:
    In the model file call
      validates :model_attribute, date_day: true

    To pass parameters to have custom min/max values
      validates :model_attribute, date_day: { min_day: 3, max_day: 29 }

  Description:
    This class is a custom validators for date day related attributes.
    Checks if the model_attribute is empty, an integer, and within min_day and max_day inclusive
    If BOTH year_sym and month_sym are passed in, the validity of the day within a specific year
    and month will be checked as well

  Optional parameters:
    allow_blank, default true
      If true, allows the model attribute to be empty, aka not set, from base class

    message, default "must be an integer between #{@min_value} and #{@max_value}" 
      Error message to be added to the model_attribute if an error occurs

    min_day, default 1
      Minimum day value for the model_attribute

    max_day, default 31
      Maximum day value for the model_attribute

    year_sym
      Symbol of a model attribute containing the year value

    month_sym
      Symbol of a model attribute containing the month value
=end

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