=begin
  Child class of DateTimeValidator class

  Example on how to use this class:
    In the model file call
      validates :model_attribute, time_second: true

    To pass parameters to have custom min/max values
      validates :model_attribute, time_second: { min_second: 3, max_second: 29 }

  Description:
    This class is a custom validators for date second related attributes.
    Checks if the model_attribute is empty, an integer, and within min_second and max_second inclusive

  Optional parameters:
    allow_blank, default true, from base class
      If true, allows the model attribute to be empty, aka not set

    message, default "must be an integer between #{@min_value} and #{@max_value}", from base class
      Error message to be added to the model_attribute if an error occurs

    min_second, default 0
      Minimum second value for the model_attribute

    max_second, default 59
      Maximum second value for the model_attribute
=end

class TimeSecondValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_second, 0)
    @max_value = options.fetch(:max_second, 59)
    super
  end
end