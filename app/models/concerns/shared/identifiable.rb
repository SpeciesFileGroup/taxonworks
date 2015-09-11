module Shared::Identifiable

  extend ActiveSupport::Concern
  included do
    # Validation happens on the parent side!
    has_many :identifiers, as: :identifier_object, validate: true, dependent: :destroy
    accepts_nested_attributes_for :identifiers, reject_if: :reject_identifiers 
  end

  module ClassMethods

    def of_type(id_type)
      where(type: id_type)
    end

    # Exact match on identifier + namespace, return an Array, not Arel
    # @param [String, String]  namespace_name is either the long or short namespace name.
    # @return [Scope]
    def with_namespaced_identifier(namespace_name, identifier)
      i = Identifier.arel_table
      n = Namespace.arel_table
      s = self.arel_table

      # conditions
      c1 = n[:name].eq(namespace_name).or(n[:short_name].eq(namespace_name))
      c2 = i[:identifier].eq(identifier)

      # join identifiers to namespaces
      j = i.join(n).on(i[:namespace_id].eq(n[:id]))

      # join self to identifiers
      l = s.join(i).on(s[:id].eq(i[:identifier_object_id]).and(i[:identifier_object_type].eq(self.base_class.name)))

      self.joins(l.join_sources, j.join_sources).where(c1.and(c2).to_sql)
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

  def reject_identifiers(attributed)
    attributed['identifier'].blank? || attributed['type'].blank?
  end

  def identified?
    self.identifiers.any?
  end

end
