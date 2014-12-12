module Shared::AlternateValues
  extend ActiveSupport::Concern

  included do
    has_many :alternate_values, as: :alternate_value_object, validate: false
  end

  def alternate_valued?
    self.alternate_values.count > 0
  end

  #returns a sorted Array of associated values
  def all_values_for(attr)
  # eg. returns self.name from otu.all_values_for(name)
    values = [self.send(attr)]
    if has_alternate_values?
      alternate_values.each do |v|
        values.push(v.value) if v.alternate_value_object_attribute == attr
      end
    end
    return values.sort
  end

  module ClassMethods
    # Use
    #   Otu.with_alternate_value_on(:name, 'foo')
    def with_alternate_value_on(a, b)
      joins(:alternate_values).where(alternate_values: {alternate_value_object_attribute: a, value: b})
    end
  end

end
