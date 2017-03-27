# Shared code extending data classes with data-attributes (predicate->value tags).
#
module Shared::DataAttributes
  extend ActiveSupport::Concern

  included do
    has_many :data_attributes, as: :attribute_subject, validate: true, dependent: :destroy
    accepts_nested_attributes_for :data_attributes
  end

  # TODO: move these scopes to has_many relationships

  # @return [Scope]
  def internal_attributes
    data_attributes.where(type: 'InternalAttribute')
  end

  # @return [Scope]
  def import_attributes
    data_attributes.where(type: 'ImportAttribute')
  end

  # @return [Hash]
  #   all data attributes in String (name) -> value format
  def keyword_value_hash
    self.data_attributes.inject({}) do |hsh, a|
      if a.kind_of?(ImportAttribute)
        hsh[a.import_predicate] = a.value
      else # If not an ImportAttribute then it's an InternalAttribute
        hsh[a.predicate.name] = a.value
      end
      hsh
    end
  end

end
