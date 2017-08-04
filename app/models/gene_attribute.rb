# A GeneAttribute defines an attribute that must be matched for a Sequence to be classified as a Descriptor::Gene. 
# There are two key attributes, sequence, and sequence relationship.  A GeneAttribute will return all sequences
# who are the object of a taxon name relationship whose subject is Sequence and whose Type is #sequence_relationship_type
# 
# @!attribute descriptor_id 
#   @return [Integer]
#      the descriptor id (Gene) that this attribute defines
#
# @!attribute sequence_id 
#   @return [Integer]
#      the sequence id (Gene), defines the nucleotides in the attribute
#
# @!attribute sequence_relationship_type
#   @return [String]
#      a SequenceRelationship#type, defines how the sequence was used in this attribute 
#
# ! Deprecated?
# @!attribute controlled_vocabulary_term_id
#   @return [Integer]
#      not yet implemented, intent/idea is to define a subclass of CVT that represents GO terms. 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#  
class GeneAttribute < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  belongs_to :descriptor, class_name: 'Descriptor::Gene', inverse_of: :gene_attributes
  belongs_to :sequence, inverse_of: :gene_attributes

  # Not yet implemented.
  # Deprecated: Use Tag/Keyword
  # belongs_to :controlled_vocabulary_term

  validates :descriptor, presence: true
  validates :sequence, presence: true
 
  validates_uniqueness_of :sequence, scope: [:descriptor, :sequence_relationship_type]

end
