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