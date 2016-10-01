=begin
  Child class of DateTimeValidator class

  Example on how to use this class:
    In the model file call
      validates :model_attribute, date_year: true

    To pass parameters to have custom min/max values
      validates :model_attribute, date_year: { min_year: 3, max_year: 29 }

  Description:
    This class is a custom validators for date year related attributes.
    Checks if the model_attribute is empty, an integer, and within min_year and max_year inclusive

  Optional parameters:
    allow_blank, default true, from base class
      If true, allows the model attribute to be empty, aka not set

    message, default "must be an integer between #{@min_value} and #{@max_value}", from base class
      Error message to be added to the model_attribute if an error occurs

    min_year, default 1000
      Minimum year value for the model_attribute

    max_year, default Time.now.year + 5
      Maximum year value for the model_attribute
=end

class DateYearValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_year, 1000)
    @max_value = options.fetch(:max_year, Time.now.year + 5)
    super
  end
end