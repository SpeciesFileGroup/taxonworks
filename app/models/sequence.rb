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

  ALTERNATE_VALUES_FOR = [:name]
  
  has_paper_trail
  
  belongs_to :project

  has_many :sequence_relationships
  has_many :sequence_relationships

  validates_presence_of :sequence
  validates_inclusion_of :sequence_type, in: ["DNA", "RNA", "AA"]
end
