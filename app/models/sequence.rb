# A DNA, RNA, or Amino Acid, as defined by a string of letters.
# All other attributes are stored in related tables, the overal model is basically an graph with nodes having attributes.
#
class Sequence < ActiveRecord::Base

  include Housekeeping
  # include Shared::Protocol
  # include Shared::Confidence
  # include Shared::Documentation
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable
  include Shared::AlternateValues
  include Shared::OriginRelationship

  is_origin_for :sequences
  has_paper_trail
  
  ALTERNATE_VALUES_FOR = [:name]
  
  has_many :sequence_relationships, inverse_of: :subject_sequence
  has_many :related_sequence_relationships, inverse_of: :object_sequence
  has_many :gene_attributes, inverse_of: :sequences

  validates_presence_of :sequence
  validates_inclusion_of :sequence_type, in: ["DNA", "RNA", "AA"]
end
