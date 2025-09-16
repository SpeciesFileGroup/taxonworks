# A lightweight but extensible reference to anatomy. It refers to physical
# objects as instances or concepts (see is_material) The concept is a data node,
# with inference happening if/when linkages to an Ontology exist. I.e. we are
# storing only very light-weight data.
# Use cases:
#     Collector goes to field, takes a punch of a fish fin, and returns it ->
#     AnatomicalPart has_origin FieldOccurrence A wing is dissected from a
#     specimen -> AnatomicalPart has_origin Specimen A feather is removed from a
#     bird, and a punch from the feather -> AnatomicalPart has_origin
#     AnatomicalPart has_origin FieldOccurrence A louse is collected from the
#     Ear of a bat, the louse is collected, the Bat is not - AnatomicalPart
#     (ear) has_origin FieldOCcurrence (bat) -> BiologicalAssociation <-
#     CollectionObject (louse)
#
# @!attribute name
#   @return [String]
#   Name of the anatomical part.
#
# @!attribute uri
#   @return [String]
#   Ontology uri of the anatomical part.
#
# @!attribute uri_label
#   @return [String]
#   Uri label of the uri for the anatomical part.
#
# @!attribute is_material
#   @return [Boolean]
#   Whether or not the anatomical part is based on a physical object - *a* head
#   vs. *some* head.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID

class AnatomicalPart < ApplicationRecord
  include Housekeeping
  # ... others
  include Shared::IsData

end
