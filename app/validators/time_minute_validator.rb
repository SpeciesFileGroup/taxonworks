=begin
  Child class of DateTimeValidator class

  Example on how to use this class:
    In the model file call
      validates :model_attribute, time_minute: true

    To pass parameters to have custom min/max values
      validates :model_attribute, time_minute: { min_minute: 3, max_minute: 29 }

  Description:
    This class is a custom validators for date minute related attributes.
    Checks if the model_attribute is empty, an integer, and within min_minute and max_minute inclusive

  Optional parameters:
    allow_blank, default true, from base class
      If true, allows the model attribute to be empty, aka not set

    message, default "must be an integer between #{@min_value} and #{@max_value}", from base class
      Error message to be added to the model_attribute if an error occurs

    min_minute, default 0
      Minimum minute value for the model_attribute

    max_minute, default 59
      Maximum minute value for the model_attribute
=end

class TimeMinuteValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_minute, 0)
    @max_value = options.fetch(:max_minute, 59)
    super
  end
end