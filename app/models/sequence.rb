require_dependency 'sequence_relationship'

# A DNA, RNA, or Amino Acid, as defined by a string of letters.
# All other attributes are stored in related tables, the overal model is basically an graph with nodes having attributes.
#
class Sequence < ApplicationRecord

  include Housekeeping

  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Confidence
  include Shared::Documentation
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::OriginRelationship
  include Shared::Protocols
  include Shared::Taggable

  is_origin_for 'Sequence'
  has_paper_trail

  ALTERNATE_VALUES_FOR = [:name]

  has_many :sequence_relationships, foreign_key: :subject_sequence_id, inverse_of: :subject_sequence
  has_many :sequences, through: :sequence_relationships, source: :object_sequence

  has_many :related_sequence_relationships, class_name: 'SequenceRelationship', foreign_key: :object_sequence_id, inverse_of: :object_sequence
  has_many :related_sequences, through: :related_sequence_relationships, source: :subject_sequence

  has_many :gene_attributes, inverse_of: :sequences

  SequenceRelationship.descendants.each do |d|
    t = d.name.demodulize.tableize.singularize
    relationships = "#{t}_relationships".to_sym
    sequences = "#{t}_sequences".to_sym

    has_many relationships, class_name: d.name.to_s, foreign_key: :object_sequence_id, inverse_of: :object_sequence
    has_many sequences, class_name: 'Sequence', through: relationships, source: :subject_sequence, inverse_of: :sequences

    accepts_nested_attributes_for sequences
    accepts_nested_attributes_for relationships
  end

  validates_presence_of :sequence
  validates_inclusion_of :sequence_type, in: ["DNA", "RNA", "AA"]

end


