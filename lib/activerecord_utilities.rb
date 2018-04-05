# Shared ApplicationRecord utilities, like string manipulation methods.
# See app/models/application_record.rb for inclusion.
module ActiverecordUtilities

  extend ActiveSupport::Concern

  included do
    before_validation :trim_attributes

    # @param [Array]
    #   a symbolized list of attributes to be trimmed automatically
    class_attribute :attributes_to_trim
  end

  module ClassMethods
    # any def inside here is a class method
    # @param [Symbol, Array] attributes
    # @return [Symbol]
    def nil_trim_attributes(*attributes) # this assigns the attributes to be trimmed
      raise('no attributes to trim') if (attributes.map(&:to_s) - self.column_names) != []
      self.attributes_to_trim = attributes
    end
  end

  protected

  # @return [Object]
  def trim_attributes
    if !self.attributes_to_trim.nil?
      self.attributes_to_trim.each do |a|
        self.send("#{a}=".to_sym, Utilities::Strings.nil_strip(self.send(a)))
      end
    end
  end

end

