module Shared::Identifiable
  extend ActiveSupport::Concern
  included do
    # Validation happens on the parent side!
    has_many :identifiers, as: :identified_object, validate: true 
    accepts_nested_attributes_for :identifiers
  end

  module ClassMethods

    # Exact match on identifier + namespace, return an Array, not Arel
    def with_namespaced_identifier(namespace_name, identifier)
      i = Identifier.arel_table
      n = Namespace.arel_table
      s = self.arel_table

      # conditions
      c1 = n[:name].eq(namespace_name)
      c2 = i[:identifier].eq(identifier)

      # join identifiers to namespaces
      j = i.join(n).on(i[:namespace_id].eq(n[:id]))

      # join self to identifiers
      l = s.join(i).on(s[:id].eq(i[:identified_object_id]).and(i[:identified_object_type].eq(self.base_class.name)))

      self.joins(l.join_sql, j.join_sql).where(c1.and(c2).to_sql)
    end

    # Exact match on the full identifier (use for any class of identifiers)
    # 'value' is the cached value with includes the namespace (see spec)
    # example Serial.with_identifier('MX serial ID 8740')
    def with_identifier(value)
      value = [value] if value.class == String
      t = Identifier.arel_table
      a = t[:cached].eq_any(value)
      self.joins(:identifiers).where(a.to_sql).references(:identifiers)
    end
  end

  def identified?
    self.identifiers.size > 0
  end

  protected

  def build_identifier(params)
    byebug
    foo = 1
  end

end
