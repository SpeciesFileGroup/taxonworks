# A CollectionObject is on or more physical things that have been collected.  Ennumerating how many things (@!total) is a 
# 
## @!attribute total 
#   @return [Integer]
#   The enumerated number of things, as asserted by the person managing the record.  Different totals will default to different subclasses.  How you enumerate your collection objects is up to you.  If you want to call one chunk of coral 50 things, that's fine (total = 50), if you want to call one coral one thing (total = 1) that's fine too.  If not nil then ranged_lot_category_id must be nil.  When =1 the subclass is Specimen, when > 1 the subclass is Lot.
# 
## @!attribute ranged_lot_category_id 
#   @return [Integer]
#   The id of the user-defined ranged lot category.  See RangedLotCategory.  When present the subclass is "RangedLot". 
#
# @!attribute collecting_event_id 
#   @return [Integer]
#   The id of the collecting event from whence this object came.  See CollectingEvent. 
#
# @!attribute respository_id
#   @return [Integer]
#   The id of the Repository.  This is the "home" repository, *not* where the specimen currently is located.  Repositories may indicate ownership BUT NOT ALWAYS. The assertion is only that "if this collection object was not being used, then it should be in this repository".
#
# @!attribute preparation_type_id 
#   @return [Integer]
#   How the collection object was prepared.  Draws from a controlled set of values shared by all projects.  For example "slide mounted".  See PreparationType. 
# 
# @!attribute buffered_collecting_event 
#   @return [String]
#   An incoming, typically verbatim, block of data typically as seens as a locality/method/etc. label.  All buffered_ attributes are written but not intended 
#   to be deleted or otherwise updated.  Buffered_ attributes are typically only used in rapid data capture, primarily in historical situations.
#
# @!attribute buffered_determinations
#   @return [String]
#   An incoming, typically verbatim, block of data typically as seen a taxonomic determination label.  All buffered_ attributes are written but not intended 
#   to be deleted or otherwise updated.  Buffered_ attributes are typically only used in rapid data capture, primarily in historical situations.
#
# @!attribute buffered_other_labels
#   @return [String]
#   An incoming, typically verbatim, block of data, as typically found on label that is unrelated to determinations or collecting events.  All buffered_ attributes are written but not intended to be deleted or otherwise updated.  Buffered_ attributes are typically only used in rapid data capture, primarily in historical situations.
#  
# @!attribute accessioned_at
#   @return [Date]
#   The date when the object was accessioned to the Repository (not necessarily it's current disposition!). If present Repository must be present.
#
# @!attribute deaccessioned_at
#   @return [Date]
#   The date when the object was removed from tracking.  If provide then Repository must be null?! TODO: resolve
#
# @!attribute deaccession_reason
#   @return [String]
#   A free text explanation of why the object was removed from tracking. 
#
class CollectionObject < ActiveRecord::Base
  # TODO: DDA: may be buffered_accession_number should be added.  MJY: This would promote non-"barcoded" data capture, I'm not sure we want to do this?!

  include Housekeeping
  include Shared::Identifiable
  include Shared::Containable
  include Shared::Citable
  include Shared::Notable
  include Shared::DataAttributes
  include Shared::Taggable
  include SoftValidation
  include Shared::HasRoles

  has_one :accession_provider_role, class_name: 'AccessionProvider', as: :role_object
  has_one :accession_provider, through: :accession_provider_role, source: :person
  has_one :deaccession_recipient_role, class_name: 'DeaccessionRecipient', as: :role_object
  has_one :deaccession_recipient, through: :deaccession_recipient_role, source: :person

  belongs_to :collecting_event, inverse_of: :collection_objects
  belongs_to :preparation_type, inverse_of: :collection_objects
  belongs_to :ranged_lot_category, inverse_of: :ranged_lots
  belongs_to :repository, inverse_of: :collection_objects

  validates_presence_of :type
  before_validation :default_to_biological_collection_object_if_type_not_provided
  before_validation :check_that_either_total_or_ranged_lot_category_id_is_present, unless: 'type == "Specimen" || type == "Lot"'
  before_validation :check_that_both_of_category_and_total_are_not_present, unless: 'type == "Specimen" || type == "Lot"'
  before_validation :reassign_type_if_total_or_ranged_lot_category_id_provided

  soft_validate(:sv_missing_accession_fields, set: :missing_accession_fields)
  soft_validate(:sv_missing_deaccession_fields, set: :missing_deaccession_fields)

  #region Soft Validation

  def sv_missing_accession_fields
    soft_validations.add(:accessioned_at, 'Date is not selected') if self.accessioned_at.nil? && !self.accession_provider.nil?
    soft_validations.add(:base, 'Provider is not selected') if !self.accessioned_at.nil? && self.accession_provider.nil?
  end

  def sv_missing_deaccession_fields
    soft_validations.add(:deaccessioned_at, 'Date is not selected') if self.deaccessioned_at.nil? && !self.deaccession_reason.blank? 
    soft_validations.add(:base, 'Recipient is not selected')  if self.deaccession_recipient.nil? && self.deaccession_reason && self.deaccessioned_at
    soft_validations.add(:deaccession_reason, 'Reason is is not defined') if self.deaccession_reason.blank? && self.deaccession_recipient && self.deaccessioned_at
  end

  def missing_determination
    # see biological_collection_object
  end

  def sv_missing_collecting_event
    # see biological_collection_object
  end

  def sv_missing_preparation_type
    # see biological_collection_object
  end

  def sv_missing_repository
    # see biological_collection_object
  end

  def self.find_for_autocomplete(params)
    # add identifiers
    # add determinations
    where('type LIKE ?', "#{params[:term]}%") 
  end

  #endregion

  protected

  def default_to_biological_collection_object_if_type_not_provided
    self.type ||= 'CollectionObject::BiologicalCollectionObject'
  end

  def check_that_both_of_category_and_total_are_not_present
    errors.add(:ranged_lot_category_id, 'Both ranged_lot_category and total can not be set') if !ranged_lot_category_id.blank? && !total.blank?
  end

  def check_that_either_total_or_ranged_lot_category_id_is_present
    errors.add(:base, 'Either total or a ranged lot category must be provided') if ranged_lot_category_id.blank? && total.blank?
  end

  def reassign_type_if_total_or_ranged_lot_category_id_provided
    return true if ['Specimen', 'Lot', 'RangedLot'].include?(self.type) # handle validation in subclasses
    return true if self.total.nil? && ranged_lot_category_id.blank?
    if self.total == 1
      self.type = 'Specimen'
    elsif self.total.to_i > 1
      self.type = 'Lot'
    elsif total.nil? && !ranged_lot_category_id.blank?
      self.type = 'RangedLot'
    end
    true
  end

end
