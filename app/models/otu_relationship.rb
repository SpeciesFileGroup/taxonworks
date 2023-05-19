# TODO: controller spec refactor 
#   
#
# An OtuRelationhip links two OTUs in a euler/rcc5 relatinship.
#
# # @!attribute subject_otu_id
#   @return [integer]
#   the OTU on the left side of the relationhip
#
# @!attribute object_otu_id
#   @return [integer]
#   the OTU on the right side of the relationhip
#
# @!attribute type
#   @return [String]
#     The rails STI name for the relationship type, e.g. OtuRelationship::Disjoint
#     See also http://api.checklistbank.org/vocab/taxonconceptreltype, https://github.com/tdwg/tcs2/blob/9eebd904001baab61476852bda53851317161186/master/tcs.yaml#L207
#
class OtuRelationship < ApplicationRecord
  include Housekeeping
  # include SoftValidation
  include Shared::Citations
  # include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  #  include Shared::Depictions
  include Shared::Confidences
  # include Shared::OriginRelationship
  # TODO:  the conscensus names for our new things
  # include Shared::Taxonomy
  include Shared::IsData

  belongs_to :subject_otu , class_name: 'Otu', inverse_of: :otu_relationships
  belongs_to :object_otu , class_name: 'Otu', inverse_of: :related_otu_relationships

  validates_presence_of :subject_otu
  validates_presence_of :object_otu


end
