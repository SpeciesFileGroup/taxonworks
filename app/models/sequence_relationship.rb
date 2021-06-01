# A SequenceRelationship relates to strings of DNA/RNA/AA to one other in the form:
#  #subject is_a #type of #object 
#  subject ForwardPrimer of object
#
# In this case the subject is the primer, then object is the sequence using that primer.  
# Also use for deriving sequences from queries, etc.
#
# @!attribute subject_sequence_id 
#   @return [Integer]
#     the subject sequence 
#
# @!attribute object_sequence_id 
#   @return [Integer]
#     the subject sequence 
#
class SequenceRelationship < ApplicationRecord
  include Housekeeping

  # not sure we need these 3:
  # include Shared::Protocol
  # include Shared::Confidence
  # include Shared::Documentation
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData

  belongs_to :subject_sequence, class_name: 'Sequence', inverse_of: :sequence_relationships
  belongs_to :object_sequence, class_name: 'Sequence', inverse_of: :related_sequence_relationships

  validates_presence_of :subject_sequence
  validates_presence_of :object_sequence
  validates_presence_of :type

end

Dir[Rails.root.to_s + '/app/models/sequence_relationship/**/*.rb'].sort.each {|file| require_dependency file }
