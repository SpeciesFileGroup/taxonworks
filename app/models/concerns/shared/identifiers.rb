# Shared code for objects that have Identifiers.
#
module Shared::Identifiers

  extend ActiveSupport::Concern
  included do
    Identifier.related_foreign_keys.push self.name.foreign_key

    # Validation happens on the parent side!
    has_many :identifiers, as: :identifier_object, validate: true, dependent: :destroy
    accepts_nested_attributes_for :identifiers, reject_if: :reject_identifiers, allow_destroy: true
    scope :with_identifier_type, ->(id_type) { includes(:identifiers).where('identifiers.type = ?', id_type).references(:identifiers) }
    scope :with_identifier_namespace, ->(id_namespace) { joins(:identifiers).where('identifiers.namespace_id = ?', id_namespace.id).references(:identifiers) }

    # Careful, a potential security issue here
    scope :with_identifiers_sorted, -> (o = 'ASC') { includes(:identifiers)
      .where("identifiers.identifier ~ '\^\\d\+\$'")
      .order(Arel.sql("identifiers.type, identifiers.namespace_id, CAST(identifiers.identifier AS integer) #{o}"))
      .references(:identifiers) }

 #  scope :with_identifiers_sorted_desc, -> { includes(:identifiers)
 #    .where("identifiers.identifier ~ '\^\\d\+\$'")
 #    .order(Arel.sql('identifiers.type, identifiers.namespace_id, CAST(identifiers.identifier AS integer) DESC'))
 #    .references(:identifiers) }

    scope :with_identifier_type_and_namespace, ->(id_type, id_namespace = nil, sorted = true) { with_identifier_type_and_namespace_method(id_type, id_namespace, sorted) }

  end

  module ClassMethods

    def of_type(type_name)
      where(type: type_name)
    end

    # Exact match on identifier + namespace, return an Array, not Arel
    # @param [String, String] namespace_name is either the long or short namespace name.
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

    def with_identifier_type_and_namespace_method(id_type, namespace, sorted)
      if namespace.present?
        if sorted
          with_identifier_type(id_type)
            .with_identifier_namespace(namespace)
            .with_identifiers_sorted
        else
          with_identifier_type(id_type)
            .with_identifier_namespace(namespace)
        end
      else
        if sorted
          with_identifier_type(id_type)
            .with_identifiers_sorted
        else
          with_identifier_type(id_type)
        end
      end
    end
  end

  def identified?
    self.identifiers.any?
  end

  protected

  def reject_identifiers(attributed)
    attributed['identifier'].blank? || attributed['type'].blank?
  end

end
