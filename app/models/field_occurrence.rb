class FieldOccurrence < ApplicationRecord
  belongs_to :collecting_event_id

  include GlobalID::Identification
  include Housekeeping

  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::Depictions

  include Shared::OriginRelationship
  include Shared::Confidences
  include Shared::ProtocolRelationships
  include Shared::HasPapertrail
  include Shared::Observations
  include Shared::IsData
  include Shared::QueryBatchUpdate
  include SoftValidation


  include Shared::BiologicalExtensions

  include Shared::Taxonomy # at present must be before IsDwcOccurence
  include Shared::IsDwcOccurrence
 


end
