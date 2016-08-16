class SequenceRelationship < ActiveRecord::Base
  include Housekeeping
  # include Shared::Protocol
  # include Shared::Confidence
  # include Shared::Documentation
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  belongs_to :subject_sequence, class_name: 'Sequence'
  belongs_to :object_sequence, class_name: 'Sequence'

  validates_presence_of :subject_sequence_id
  validates_presence_of :object_sequence_id
  validates_presence_of :type
  
end

require_dependency 'sequence_relationship/reverse_primer'
require_dependency 'sequence_relationship/forward_primer'
require_dependency 'sequence_relationship/blast_query_sequence'
require_dependency 'sequence_relationship/reference_sequence_for_assembly'