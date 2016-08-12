class Sequence < ActiveRecord::Base
  include Housekeeping
  # include Shared::Protocol
  # include Shared::Confidence
  # include Shared::Documentation
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  has_paper_trail
  
  belongs_to :project

  has_many :sequence_relationships, as: :subject_sequence
  has_many :sequence_relationships, as: :object_sequence

  validates_presence_of :sequence
  validates_inclusion_of :sequence_type, in: ["DNA", "RNA", "AA"]
end
