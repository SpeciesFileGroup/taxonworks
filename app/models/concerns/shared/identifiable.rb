module Shared::Identifiable
  extend ActiveSupport::Concern
  included do
    has_many :identifiers, as: :identified_object, validate: false
    accepts_nested_attributes_for :identifiers
  end

  module ClassMethods
    def with_identifier(namespace, identifier)
      t = Identifier.arel_table
      joins(:alternate_values).where(alternate_values: {alternate_object_attribute: a, value: b})
    end
  end

  def identified?
    self.identifiers.size > 0
  end

  protected

end
