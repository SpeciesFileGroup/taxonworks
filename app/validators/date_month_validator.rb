=begin
  Child class of DateTimeValidator class

  Example on how to use this class:
    In the model file call
      validates :model_attribute, date_month: true

    To pass parameters to have custom min/max values
      validates :model_attribute, date_month: { min_month: 3, max_month: 29 }

  Description:
    This class is a custom validators for date month related attributes.
    Checks if the model_attribute is empty, an integer, and within min_month and max_month inclusive

  Optional parameters:
    allow_blank, default true, from base class
      If true, allows the model attribute to be empty, aka not set

    message, default "must be an integer between #{@min_value} and #{@max_value}", from base class
      Error message to be added to the model_attribute if an error occurs

    min_month, default 1
      Minimum month value for the model_attribute

    max_month, default 12
      Maximum month value for the model_attribute
=end

class DateMonthValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_month, 1)
    @max_value = options.fetch(:max_month, 12)
    super
  end
end