module Shared::AlternateValues
  extend ActiveSupport::Concern

  included do
    has_many :alternate_values, as: :alternate_object, validate: false
  end

  def has_alternate_values?
    self.alternate_values.count > 0
  end

  module ClassMethods
    # Use
    #   Otu.with_alternate_value_on(:name, 'foo')
    def with_alternate_value_on(a, b)
      joins(:alternate_values).where(alternate_values: {alternate_object_attribute: a, value: b})  
    end
  end

end
