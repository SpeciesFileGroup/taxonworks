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

  include Housekeeping
  include Shared::Identifiable
  include Shared::Containable
  include Shared::Citable

  # before_save :classify_based_on_total

  belongs_to :preparation_type
  belongs_to :repository, inverse_of: :collection_objects

  protected

  # def classify_based_on_total
  #   if total > 0
  #     self.type = 'Lot'
  #   end
  # end
  

end
