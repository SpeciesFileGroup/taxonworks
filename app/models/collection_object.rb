# A CollectionObject is on or more physical things that have been collected.  Ennumerating how many things (@!total) is a task of the curator.
#
# A CollectiongObjects immediate disposition is handled through its relation to containers.  Containers can be nested, labeled, and interally subdivided as necessary.
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
#
#
class CollectionObject < ActiveRecord::Base
  # TODO: DDA: may be buffered_accession_number should be added.  MJY: This would promote non-"barcoded" data capture, I'm not sure we want to do this?!

  include Housekeeping
  include Shared::Citable
  include Shared::Containable
  include Shared::DataAttributes
  include Shared::HasRoles
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include Shared::Depictions
  include SoftValidation

  has_paper_trail

  BUFFERED_ATTRIBUTES = %i{buffered_collecting_event buffered_determinations buffered_other_labels}

  has_one :accession_provider_role, class_name: 'AccessionProvider', as: :role_object
  has_one :accession_provider, through: :accession_provider_role, source: :person
  has_one :deaccession_recipient_role, class_name: 'DeaccessionRecipient', as: :role_object
  has_one :deaccession_recipient, through: :deaccession_recipient_role, source: :person

  has_many :derived_collection_objects, inverse_of: :collection_object
  has_many :collection_object_observations, through: :derived_collection_objects, inverse_of: :collection_objects


  belongs_to :collecting_event, inverse_of: :collection_objects
  belongs_to :preparation_type, inverse_of: :collection_objects
  belongs_to :ranged_lot_category, inverse_of: :ranged_lots
  belongs_to :repository, inverse_of: :collection_objects

  validates_presence_of :type
  validate :check_that_either_total_or_ranged_lot_category_id_is_present
  validate :check_that_both_of_category_and_total_are_not_present

  before_validation :assign_type_if_total_or_ranged_lot_category_id_provided

  soft_validate(:sv_missing_accession_fields, set: :missing_accession_fields)
  soft_validate(:sv_missing_deaccession_fields, set: :missing_deaccession_fields)

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
    Queries::BiologicalCollectionObjectAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

  def self.breakdown_status(collection_objects)
    collection_objects = [collection_objects] if !(collection_objects.class == Array)

    breakdown = {
      total_objects: collection_objects.length,
      collecting_events: {},
      determinations: {},
      bio_overview: []
    }

    breakdown.merge!(breakdown_buffered(collection_objects))

    collection_objects.each do |co|
      breakdown[:collecting_events].merge!(co => co.collecting_event) if co.collecting_event 
      breakdown[:determinations].merge!(co => co.taxon_determinations)  if co.taxon_determinations.any?
      breakdown[:bio_overview].push([co.total, co.biocuration_classes.collect{|a| a.name}])
    end

    breakdown
  end

  # @return [Hash]
  #   a unque list of buffered_ values observed in the collection objects passed
  def self.breakdown_buffered(collection_objects)
    collection_objects = [collection_objects] if !(collection_objects.class == Array)
    breakdown = {}
    categories = BUFFERED_ATTRIBUTES 
    
    categories.each do |c| 
      breakdown[c] = []
    end 

    categories.each do |c|
      collection_objects.each do |co|
        breakdown[c].push co.send(c)
      end
    end

    categories.each do |c| 
      breakdown[c].uniq!
    end

    breakdown
  end

  # return [Boolean]
  #    true if instance is a subclass of BiologicalCollectionObject
  def biological?
    self.class <= BiologicalCollectionObject ? true : false
  end

  def annotations
    h = annotations_hash 
    h.merge!('biocuration classifications' => self.biocuration_classes) if self.biological? && self.biocuration_classifications.any?
    h 
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  def check_that_both_of_category_and_total_are_not_present
    errors.add(:ranged_lot_category_id, 'Both ranged_lot_category and total can not be set') if !ranged_lot_category_id.blank? && !total.blank?
  end

  def check_that_either_total_or_ranged_lot_category_id_is_present
    errors.add(:base, 'Either total or a ranged lot category must be provided') if ranged_lot_category_id.blank? && total.blank?
  end

  def assign_type_if_total_or_ranged_lot_category_id_provided
      if self.total == 1
        self.type = 'Specimen'
      elsif self.total.to_i > 1
        self.type = 'Lot'
      elsif total.nil? && !ranged_lot_category_id.blank?
        self.type = 'RangedLot'
      end
    true
  end



  # # TODO: Write this. Changing from one type to another is ONLY allowed via this method, not by updating attributes
  # def transmogrify_to(new_type)
  # end


end
