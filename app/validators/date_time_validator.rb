=begin
  Base validator class for the following validators:
    DateDayValidator
    DateMonthValidator
    DateYearValidator
    TimeSecondValidator
    TimeMinuteValidator
    TImeHourValidator

  This class should NOT be used directly for validating attribtues in models,
  instead you should be using one of the child classes listed above

  Child classes MUST create an instance variable named "min_value" and "max_value"

  Example on how to use one of the child classes:
    In the model file call
      validates :model_attribute, date_day: true

    To pass parameters to have custom min/max values
      validates :model_attribute, date_day: { min_day: 3, max_day: 29 }

  Description:
    This class and its children are custom validators for dates/times related attributes.
    Checks if the model_attribute is empty, an integer, and within min_value and max_value inclusive

  Optional parameters:
    allow_blank, default true
      If true, allows the model attribute to be empty, aka not set

    message, default "must be an integer between #{@min_value} and #{@max_value}" 
      Error message to be added to the model_attribute if an error occurs

    min_value, set in child class
      Minimum value for the model_attribute

    max_value, set in child class
      Maximum value for the model_attribute
=end

class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    @message ||= options.fetch(:message, "must be an integer between #{@min_value} and #{@max_value}")
    @allow_blank ||= options.fetch(:allow_blank, true)

    if !@allow_blank && value.nil?
      record.errors.add(attribute, "can't be blank")
    elsif !value.blank?
      if !value.is_a? Integer 
        record.errors.add(attribute, "is not an integer")
      elsif value < @min_value || value > @max_value
        record.errors.add(attribute, "not in range")
      end
    end

    record.errors.add(attribute, @message) if record.errors.key?(attribute)
  end
end