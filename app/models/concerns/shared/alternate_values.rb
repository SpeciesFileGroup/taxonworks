module Shared::AlternateValues
  extend ActiveSupport::Concern

  included do
    has_many :alternate_values, as: :alternate_value_object, validate: false, dependent: :destroy
  end

  def alternate_valued?
    self.alternate_values.any?
  end


  #returns a sorted Array of associated values
  # @param attr [Symbol]
  def all_values_for(attr)
  # eg. returns self.name from otu.all_values_for(name)
    values = [self.send(attr)]
    if alternate_valued?
      alternate_values.each do |v|
        values.push(v.value) if v.alternate_value_object_attribute == attr.to_s
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


    def with_any_value_for(attribute, value)
      self_table  = Arel::Table.new(self.table_name)
      alternate_value_table = Arel::Table.new(:alternate_values)

#      query = self_table.project(Arel.sql('*'))
#      query.to_sql

    #      with_alternate_value_on(attribute, value).or

 #    self_table.join(alternate_value_table, Arel::Nodes::OuterJoin).on(self_table[:id].eq(alternate_value_table[:alternate_value_object_id])).
 #      where( alternate_value_table[:alternate_value_object_type].eq('foo').and(self_table[attribute].eq(value).or(alternate_value_table[:value].eq(value)) )
    end

  end

end
