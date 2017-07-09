=begin
  Child class of DateTimeValidator class

  Example on how to use this class:
    In the model file call
      validates :model_attribute, time_hour: true

    To pass parameters to have custom min/max values
      validates :model_attribute, time_hour: { min_hour: 3, max_hour: 29 }

  Description:
    This class is a custom validators for date hour related attributes.
    Checks if the model_attribute is empty, an integer, and within min_hour and max_hour inclusive

  Optional parameters:
    allow_blank, default true, from base class
      If true, allows the model attribute to be empty, aka not set

    message, default "must be an integer between #{@min_value} and #{@max_value}", from base class
      Error message to be added to the model_attribute if an error occurs

    min_hour, default 0
      Minimum hour value for the model_attribute

    max_hour, default 23
      Maximum hour value for the model_attribute
=end

class TimeHourValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_hour, 0)
    @max_value = options.fetch(:max_hour, 23)
    super
  end
end