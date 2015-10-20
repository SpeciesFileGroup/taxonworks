CO_OTU_Strings = 'OTU,OTU name,Family,Genus,Species,Country,State,County,Locality,Latitude,Longitude'
CO_OTU_Headers = CO_OTU_Strings.split(',')

# A CollectionObject is on or more physical things that have been collected.  Enumerating how many things (@!total) is a task of the curator.
#
# A CollectiongObjects immediate disposition is handled through its relation to containers.  Containers can be nested, labeled, and interally subdivided as necessary.
# 
# @!attribute total
#   @return [Integer]
#   The enumerated number of things, as asserted by the person managing the record.  Different totals will default to different subclasses.  How you enumerate your collection objects is up to you.  If you want to call one chunk of coral 50 things, that's fine (total = 50), if you want to call one coral one thing (total = 1) that's fine too.  If not nil then ranged_lot_category_id must be nil.  When =1 the subclass is Specimen, when > 1 the subclass is Lot.
# 
# @!attribute type
#   @return [Integer]
#   @todo
#
# @!attribute preparation_type_id
#   @return [Integer]
#   How the collection object was prepared.  Draws from a controlled set of values shared by all projects.  For example "slide mounted".  See PreparationType.
#
# @!attribute respository_id
#   @return [Integer]
#   The id of the Repository.  This is the "home" repository, *not* where the specimen currently is located.  Repositories may indicate ownership BUT NOT ALWAYS. The assertion is only that "if this collection object was not being used, then it should be in this repository".
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
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
# @!attribute ranged_lot_category_id
#   @return [Integer]
#   The id of the user-defined ranged lot category.  See RangedLotCategory.  When present the subclass is "RangedLot".
#
# @!attribute collecting_event_id
#   @return [Integer]
#   The id of the collecting event from whence this object came.  See CollectingEvent. 
#
# @!attribute accessioned_at
#   @return [Date]
#   The date when the object was accessioned to the Repository (not necessarily it's current disposition!). If present Repository must be present.
#
# @!attribute deaccession_reason
#   @return [String]
#   A free text explanation of why the object was removed from tracking.
#
# @!attribute deaccessioned_at
#   @return [Date]
#   The date when the object was removed from tracking.  If provide then Repository must be null?! TODO: resolve
#
class CollectionObject < ActiveRecord::Base
  # @todo DDA: may be buffered_accession_number should be added.  MJY: This would promote non-"barcoded" data capture, I'm not sure we want to do this?!

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
  has_many :otus, through: :taxon_determinations, inverse_of: :collection_objects

  # This is a problem
  has_many :taxon_determinations, foreign_key: :biological_collection_object_id, inverse_of: :biological_collection_object

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
    soft_validations.add(:base, 'Recipient is not selected') if self.deaccession_recipient.nil? && self.deaccession_reason && self.deaccessioned_at
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
      total_objects:     collection_objects.length,
      collecting_events: {},
      determinations:    {},
      bio_overview:      []
    }

    breakdown.merge!(breakdown_buffered(collection_objects))

    collection_objects.each do |co|
      breakdown[:collecting_events].merge!(co => co.collecting_event) if co.collecting_event
      breakdown[:determinations].merge!(co => co.taxon_determinations) if co.taxon_determinations.any?
      breakdown[:bio_overview].push([co.total, co.biocuration_classes.collect { |a| a.name }])
    end

    breakdown
  end

  # @return [Hash]
  #   a unque list of buffered_ values observed in the collection objects passed
  def self.breakdown_buffered(collection_objects)
    collection_objects = [collection_objects] if !(collection_objects.class == Array)
    breakdown          = {}
    categories         = BUFFERED_ATTRIBUTES

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

  def parse_names(collection_object)
    @geo_names = collection_object.collecting_event.names
  end

  def get_otu
    self.otus.first unless self.otus.empty?
  end

  def get_otu_id
    otu = get_otu
    otu.id unless otu.nil?
  end

  def get_otu_name
    otu = get_otu
    otu.name unless otu.nil?
  end

  def get_otu_taxon_name
    otu = get_otu
    otu.taxon_name unless otu.nil?
  end

  def name_at_rank_string(rank)
    retval = nil
    otu    = get_otu_taxon_name
    retval = otu.ancestor_at_rank(rank) unless otu.nil?
    retval.cached_html unless retval.nil?
  end

  # @param [Hash] of selected column names and types
  # @return [None] sets global variables for later use
  def self.collect_selected_headers(col_defs)
    @ce_col_defs = cull_headers('ce', col_defs)
    @co_col_defs = cull_headers('co', col_defs)
    @bc_col_defs = cull_headers('bc', col_defs)
  end

  # @param [String] selection 'ce', 'co', 'bc'
  # @param [Hash] col_defs selected headers and types
  def self.cull_headers(selection, col_defs)
    retval = {prefixes: [], headers: [], types: []}
    col_defs[:prefixes].each_with_index { |prefix, index|
      if prefix == selection
        retval[:prefixes].push(prefix)
        retval[:headers].push(col_defs[:headers][index])
        retval[:types].push(col_defs[:types][index])
      end
    }
    retval
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

  # @param [Scope] selected of CollectionObject
  # @param [Hash] col_defs selected headers and types
  def self.generate_report_download(scope, col_defs)
    # CollectionObject.ce_headers(scope)
    # CollectionObject.co_headers(scope)
    # CollectionObject.bc_headers(scope)
    CollectionObject.collect_selected_headers(col_defs)
    CSV.generate do |csv|
      row = CO_OTU_Headers
      row += @ce_col_defs[:headers]
      row += @co_col_defs[:headers]
      row += @bc_col_defs[:headers]
      csv << row
      scope.order(id: :asc).each do |c_o|
        row = [c_o.get_otu_id,
               c_o.get_otu_name,
               c_o.name_at_rank_string(:family),
               c_o.name_at_rank_string(:genus),
               c_o.name_at_rank_string(:species),
               c_o.collecting_event.country,
               c_o.collecting_event.state,
               c_o.collecting_event.county,
               c_o.collecting_event.verbatim_locality,
               c_o.collecting_event.georeference_latitude.to_s,
               c_o.collecting_event.georeference_longitude.to_s
        ]
        row += ce_attributes(c_o, col_defs)
        row += co_attributes(c_o, col_defs)
        row += bc_attributes(c_o, col_defs)
        csv << row.collect { |item|
          item.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

=begin
Find all collection objects which have collecting events which have georeferences which have geographic_items which
are located within the geographic item supplied
=end
  # @param [GeographicItem] geographic_item_id
  # @return [Scope] of CollectionObject
  def self.in_geographic_item(geographic_item, steps = false)
    geographic_item_id =geographic_item.id
    if steps
      gi     = GeographicItem.find(geographic_item_id)
      # find the geographic_items inside gi
      step_1 = GeographicItem.is_contained_by('any', gi) # .pluck(:id)
      # find the georeferences from the geographic_items
      step_2 = step_1.map(&:georeferences).uniq.flatten
      # find the collecting events connected to the georeferences
      step_3 = step_2.map(&:collecting_event).uniq.flatten
      # find the collection objects associated with the collecting events
      step_4 = step_3.map(&:collection_objects).flatten.map(&:id).uniq
      retval = CollectionObject.where(id: step_4)
    else
      retval = CollectionObject.joins(:collecting_event => [{:georeferences => :geographic_item}]).where(GeographicItem.sql_for_is_contained_by('any', geographic_item)).includes(:data_attributes, :collecting_event => [{:georeferences => :geographic_item}])
    end

    retval
  end

  # @param [Integer] project_id
  # @return [Hash] of column names and types for collecting events
  # decode which headers to be displayed for collecting events
  def self.ce_headers(project_id)
    # @ce_headers = collection_objects.map(&:collecting_event).map(&:data_attributes).flatten.map(&:predicate).map(&:name).uniq.sort
    retval               = {}
    retval[:ce_internal] = InternalAttribute.where(project_id: project_id, attribute_subject_type: 'CollectingEvent').map(&:predicate).map(&:name).uniq.sort
    retval[:ce_import]   = ImportAttribute.where(project_id: project_id, attribute_subject_type: 'CollectingEvent').pluck(:import_predicate).uniq.sort
    @ce_headers          = retval
  end

  # @param [CollectionObject] from which to extract attributes
  # @param [Hash] collection of selected headers, prefixes, and types
  # @return [Array] of attributes
  def self.ce_attributes(collection_object, col_defs)
    retval = []; collection = col_defs
    unless collection.nil?
      ce_header_strings = []; ce_header_types = []
      prefixes          = collection[:prefixes]
      headers           = collection[:headers]
      types             = collection[:types]
      prefixes.each_with_index { |p_type, index|
        if p_type == 'ce'
          ce_header_strings.push(headers[index])
          ce_header_types.push(types[index])
        end
      }
      ce_header_strings.each_with_index { |header, index|
        # collect all of the strings which match the predicate name with the header for this collection object
        attribute_type = ''
        case ce_header_types[index]
          when 'int'
            attribute_type = 'InternalAttribute'
          when 'imp'
            attribute_type = 'ImportAttribute'
          else
            # do nothing
        end
        retval.push(collection_object.collecting_event.data_attributes.where(type: attribute_type).select { |d| d.predicate_name == header }.map(&:value).join('; '))
      }
    end
    retval
  end

  # @param [Integer] project_id
  # @return [Hash] of column names and types for collection objects
  # decode which headers to be displayed for collection objects
  def self.co_headers(project_id)
    # @co_headers = collection_objects.map(&:data_attributes).flatten.map(&:predicate).map(&:name).uniq.sort
    retval               = {}
    retval[:co_internal] = InternalAttribute.where(project_id: project_id, attribute_subject_type: 'CollectionObject').map(&:predicate).map(&:name).uniq.sort
    retval[:co_import]   = ImportAttribute.where(project_id: project_id, attribute_subject_type: 'CollectionObject').pluck(:import_predicate).uniq.sort
    @co_headers          = retval
  end

  # @param [CollectionObject] from which to extract attributes
  # @param [Hash] collection of selected headers, prefixes, and types
  # @return [Array] of attributes
  def self.co_attributes(collection_object, col_defs)
    retval = []; collection = col_defs
    unless collection.nil?
      co_header_strings = []; co_header_types = []
      prefixes          = collection[:prefixes]
      headers           = collection[:headers]
      types             = collection[:types]
      prefixes.each_with_index { |p_type, p_index|
        if p_type == 'co'
          co_header_strings.push(headers[p_index])
          co_header_types.push(types[p_index])
        end
      }

      # collect all of the strings which match the predicate name with the header for this collection object
      co_header_strings.each_with_index { |header, index|
        attribute_type = ''
        case co_header_types[index]
          when 'int'
            attribute_type = 'InternalAttribute'
          when 'imp'
            attribute_type = 'ImportAttribute'
          else
            # do nothing
        end
        retval.push(collection_object.data_attributes.where(type: attribute_type).select { |d| d.predicate_name == header }.map(&:value).join('; '))
      }
    end
    retval
  end

  # @param [Integer] project_id
  # @return [Hash] of column names and types for biocuration classifications
  # decode which headers to be displayed for biocuration classifications
  def self.bc_headers(project_id)
    # @bc_headers = collection_objects.map(&:biocuration_classifications).flatten.map(&:biocuration_class).map(&:name).uniq.sort
    retval      = {}
    retval[:bc] = BiocurationClass.where(project_id: project_id).map(&:name)
    @bc_headers = retval
  end

  # @param [CollectionObject] from which to extract attributes
  # @param [Hash] collection of selected headers, prefixes, and types
  # @return [Array] of attributes
  def self.bc_attributes(collection_object, col_defs)
    retval = []; collection = col_defs
    unless collection.nil?
      bc_header_strings = []
      prefixes          = collection[:prefixes]
      headers           = collection[:headers]
      prefixes.each_with_index { |p_type, index|
        if p_type == 'bc'
          bc_header_strings.push(headers[index])
        end
      }
      bc_header_strings.each { |header|
        retval.push(collection_object.biocuration_classes.map(&:name).include?(header) ? '1' : '0')
      }
      retval
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


  # @todo Write this. Changing from one type to another is ONLY allowed via this method, not by updating attributes
  # def transmogrify_to(new_type)
  # end


end
