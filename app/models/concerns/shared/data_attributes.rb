# Shared code for...
#
module Shared::DataAttributes
  extend ActiveSupport::Concern

  included do
    has_many :data_attributes, as: :attribute_subject, validate: true, dependent: :destroy
    accepts_nested_attributes_for :data_attributes
  end

  def internal_attributes
    data_attributes.where(type: 'InternalAttribute')
  end

  def import_attributes
    data_attributes.where(type: 'ImportAttribute')
  end

  # to find if a record has attributes associated with it do  object.data_attributes.any?

  def keyword_value_hash
    self.data_attributes.inject({}) do |hsh, a|
      if a.class == ImportAttribute
        hsh.merge!(a.import_predicate => a.value)
      else # there are only two
        hsh.merge!(a.predicate.name => a.value)
      end
    end
  end

=begin

  # all data attributes with type, predicate or predicate.name, value
  # if type == InternalAttribute, then pred ==  ControlledVocabularyID
  # if type == ImportAttribute, then pred == import_predicate (char(255))
  # value is always a string
  def all_data_attr(type, pred, value)

  end



foo.data_attributes.includes(:predicate).where(type: a, value: b,
    controlled_vocabulary_terms: {name: c})

def foo(a, b)
    .includes(:predicate).where('controlled_vocabulary_terms.name =
? or import_predicate = ?', a, b)
 end


=end


end
