# @!attribute buffered_collecting_event 
#   @return [String]
#   An incoming, typically verbatim, block of data typically as seens as a locality/method/etc. label.  All buffered_ attributes are written but not intended 
#   to be deleted or otherwise updated.  Buffered_ attributes are typically only used in rapid data capture, primarily in historical situations.
# @!attribute buffered_determinations
#   @return [String]
#   An incoming, typically verbatim, block of data typically as seen a taxonomic determination label.  All buffered_ attributes are written but not intended 
#   to be deleted or otherwise updated.  Buffered_ attributes are typically only used in rapid data capture, primarily in historical situations.
# @!attribute buffered_other_labels
#   @return [String]
#   An incoming, typically verbatim, block of data, as typically found on label that is unrelated to determinations or collecting events.  All buffered_ attributes are written but not intended to be deleted or otherwise updated.  Buffered_ attributes are typically only used in rapid data capture, primarily in historical situations.
class CollectionObject < ActiveRecord::Base
  #TODO: DDA: may be buffered_accession_number should be added

  include Housekeeping
  include Shared::Identifiable
  include Shared::Containable
  include Shared::Citable
  include Shared::Notable
  include Shared::DataAttributes
  include Shared::Taggable
  include SoftValidation

  belongs_to :preparation_type, inverse_of: :collection_objects
  belongs_to :repository, inverse_of: :collection_objects
  belongs_to :collecting_event, inverse_of: :collection_objects

  validates_presence_of :type
  before_validation :check_that_both_of_category_and_total_are_not_present

  def check_that_both_of_category_and_total_are_not_present
    errors.add(:ranged_lot_category_id, 'Both ranged_lot_category and total can not be set') if !ranged_lot_category_id.blank? && !total.blank?
  end

  def missing_determination
    # see biological_collection_object
  end

end
