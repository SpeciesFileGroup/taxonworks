# Shared code for providing alternate values for individual columns.
#
module Shared::AlternateValues
  extend ActiveSupport::Concern

  included do
    AlternateValue.related_foreign_keys.push self.name.foreign_key

    has_many :alternate_values, as: :alternate_value_object, validate: true, dependent: :destroy
    has_many :alternate_value_languages, source: :language, through: :alternate_values
    
    # has_many :alternate_value_languages, through: :alternate_values, > {where(type: 'AlternateValue::Translation')}

    accepts_nested_attributes_for :alternate_values
  end

  def alternate_valued?
    self.alternate_values.any?
  end

  # @return [Array]
  #   a sorted Array of associated values
  #   eg. returns self.name from otu.all_values_for(name)
  # @param attr [Symbol]
  def all_values_for(attr)
    values = [self.send(attr)]
    if alternate_valued?
      alternate_values.each do |v|
        values.push(v.value) if v.alternate_value_object_attribute == attr.to_s
      end
    end
    return values.sort
  end

  module ClassMethods
    
    # @return [Scope]
    # @param [:symbol] the column name/attribute
    # @param [String, Integer, etc] the value to look for
    # Use
    #   Source.with_alternate_value_on(:title, 'foo')
    def with_alternate_value_on(a, b)
      joins(:alternate_values).where(alternate_values: {alternate_value_object_attribute: a, value: b})
    end

    # @return [Scope]
    # @param [:symbol] the column name/attribute
    # @param [String, Integer, etc] the value to look for
    # Use
    #   Source.with_any_value_for(:title, 'foo')
    def with_any_value_for(attribute, value)
      self_table = self.arel_table
      alternate_value_table = AlternateValue.arel_table

      a = alternate_value_table[:value].eq(value).and(alternate_value_table[:alternate_value_object_attribute].eq(attribute))
      b = self_table[attribute].eq(value)

      self.includes(:alternate_values).where(a.or(b).to_sql).references(:alternate_values)
    end

  end
end
