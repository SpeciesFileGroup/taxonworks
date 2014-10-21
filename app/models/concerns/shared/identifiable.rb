module Shared::Identifiable
  extend ActiveSupport::Concern
  included do
    has_many :identifiers, as: :identified_object, validate: false
    accepts_nested_attributes_for :identifiers
  end

  module ClassMethods
    # Exact match on identifier + namespace (only use for Identifier::Local subclasses 
    def with_namespaced_identifier(namespace_name, identifier)
      includes(:identifiers).where(namespace: {name: namespace_name}, identifier: identifier).references(:identifiers)
    end

    # Exact match on the full identifier (use for any class of identifiers)
    def with_identifier(value)
      value = [value] if value.class == String
      t = Identifier.arel_table
      a = t[:cached].eq_any(value)
      includes(:identifiers).where(a.to_sql).references(:identifiers) 
    end
  end

  def identified?
    self.identifiers.size > 0
  end

  protected

end
