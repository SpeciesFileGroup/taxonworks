module ActiverecordUtilities
  # this is for shared utilies, like string manipulation methods.

  extend ActiveSupport::Concern

  included do
    # these are the extensions (like has_many)
    before_validation :trim_attributes
    class_attribute :attributes_to_trim
  end

  module ClassMethods
    # any def inside here is a class method
    def nil_trim_attributes(*attributes) # this assigns the attributes to be trimmed
      raise('no attributes to trim') if (attributes.map(&:to_s) - self.column_names) != []
      self.attributes_to_trim = attributes
    end
  end

  protected
  # any def below this is an instance method
  def trim_attributes
    if !self.attributes_to_trim.nil?
      self.attributes_to_trim.each do |a|
        self.send("#{a}=".to_sym, Utilities::Strings.nil_strip(self.send(a)))
      end
    end
  end

end

class ActiveRecord::Base
  include ActiverecordUtilities
end


