
# A CollectionObject is on or more physical things that have been collected.  Enumerating how many things (@!total) is a task of the curator.
#
# A CollectiongObjects immediate disposition is handled through its relation to containers.  Containers can be nested, labeled, and interally subdivided as necessary.
#
# @!attribute total
#   @return [Integer]
#   The enumerated number of things, as asserted by the person managing the record.  Different totals will default to different subclasses.  How you enumerate your collection objects is up to you.  If you want to call one chunk of coral 50 things, that's fine (total = 50), if you want to call one coral one thing (total = 1) that's fine too.  If not nil then ranged_lot_category_id must be nil.  When =1 the subclass is Specimen, when > 1 the subclass is Lot.
#
# @!attribute type
#   @return [String]
#     the subclass of collection object, e.g. Specimen, Lot, or RangedLot
#
# @!attribute preparation_type_id
#   @return [Integer]
#   How the collection object was prepared.  Draws from a controlled set of values shared by all projects.  For example "slide mounted".  See PreparationType.
#
# @!attribute respository_id
#   @return [Integer]
#   The id of the Repository.  This is an assertion of the "home" repository, i.e. where you would most reasonably find the ColletionObject when it is not "in use" by external parties. Repositories may indicate ownership, but this is inference, not an assetion. There is some notion of "custody" tied to this assertion. The assertion is only that "if this collection object was not being used, then it you can infer that it will be found in this Repository. In the absence of the assertion of a current repository it is reasonable to infer that this is also where the specimen can be currently found, however this inference will not always hold.  See current_repository_id for related issues vs. modeling localization in TaxonWorks and the use of Containers.
#
# @!attribute current_respository_id
#   @return [Integer]
#   The id of the current repository.  The current repository is the Repository that the specimen can be expected to be found at (i.e. "is localized to") at the present time.  See also respository_id.  This is a temporally bound assertion of location of the specimen, not ownership.  In the future this will need to be reconciled with concepts of "custody" (the agent responsible for the specimen) and a stricter modelling of localization (in TaxonWorks this really should be a Container::Collection or Container::Building, i.e. the attribute doesn't really belong here in the long term.
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
class CollectionObject < ApplicationRecord
  include GlobalID::Identification
  include Housekeeping

  include Shared::Citations
  include Shared::Containable
  include Shared::Conveyances
  include Shared::DataAttributes
  include Shared::Loanable
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

  include CollectionObject::DwcExtensions

  ignore_whitespace_on(:buffered_collecting_event, :buffered_determinations, :buffered_other_labels)

  # TODO: move to export
  CO_OTU_HEADERS = %w{OTU OTU\ name Family Genus Species Country State County Locality Latitude Longitude}.freeze

  BUFFERED_ATTRIBUTES = %i{buffered_collecting_event buffered_determinations buffered_other_labels}.freeze

  GRAPH_ENTRY_POINTS = [:biological_associations, :data_attributes, :taxon_determinations, :biocuration_classifications, :collecting_event, :origin_relationships, :extracts, :observation_matrices]

  # Identifier delegations
  # .catalog_number_cached
  delegate :cached, to: :preferred_catalog_number, prefix: :catalog_number, allow_nil: true
  # .catalog_number_namespace
  delegate :namespace, to: :preferred_catalog_number, prefix: :catalog_number, allow_nil: true

  # .record_number_cached
  delegate :cached, to: :preferred_record_number, prefix: :record_number, allow_nil: true
  # .record_number_namespace
  delegate :namespace, to: :preferred_record_number, prefix: :record_number, allow_nil: true

  # CollectingEvent delegations
  delegate :map_center, to: :collecting_event, prefix: :collecting_event, allow_nil: true
  delegate :collectors, to: :collecting_event, prefix: :collecting_event, allow_nil: true

  # Repository delegations
  delegate :acronym, to: :repository, prefix: :repository, allow_nil: true
  delegate :url, to: :repository, prefix: :repository, allow_nil: true
  delegate :institutional_LSID, to: :repository, prefix: :repository, allow_nil: true

  # Preparation delegations
  delegate :name, to: :preparation_type, prefix: :preparation_type, allow_nil: true

  has_one :accession_provider_role, class_name: 'AccessionProvider', as: :role_object, dependent: :destroy
  has_one :accession_provider, through: :accession_provider_role, source: :person
  has_one :deaccession_recipient_role, class_name: 'DeaccessionRecipient', as: :role_object, dependent: :destroy
  has_one :deaccession_recipient, through: :deaccession_recipient_role, source: :person

  # TODO: Deprecate these models.  Semantics also confuse with origin relationship.
  has_many :derived_collection_objects, inverse_of: :collection_object, dependent: :restrict_with_error
  has_many :collection_object_observations, through: :derived_collection_objects, inverse_of: :collection_objects

  has_many :sqed_depictions, through: :depictions, dependent: :restrict_with_error

  belongs_to :collecting_event, inverse_of: :collection_objects
  belongs_to :preparation_type, inverse_of: :collection_objects
  belongs_to :ranged_lot_category, inverse_of: :ranged_lots
  belongs_to :repository, inverse_of: :collection_objects
  belongs_to :current_repository, class_name: 'Repository', inverse_of: :collection_objects

  has_many :georeferences, through: :collecting_event
  has_many :geographic_items, through: :georeferences

  has_many :collectors, through: :collecting_event

  has_many :type_materials, inverse_of: :collection_object, dependent: :restrict_with_error

  accepts_nested_attributes_for :collecting_event, allow_destroy: true, reject_if: :reject_collecting_event

  before_validation :assign_type_if_total_or_ranged_lot_category_id_provided

  validates_presence_of :type
  validate :check_that_either_total_or_ranged_lot_category_id_is_present
  validate :check_that_both_of_category_and_total_are_not_present
  validate :collecting_event_belongs_to_project

  soft_validate(
    :sv_missing_accession_fields,
    set: :missing_accession_fields,
    name: 'Missing accession fields',
    description: 'Name or Provider are not selected')

  soft_validate(
    :sv_missing_deaccession_fields,
    set: :missing_deaccession_fields,
    name: 'Missing deaccesson fields',
    description: 'Date, recipient, or reason are not specified')

  scope :with_sequence_name, ->(name) { joins(sequence_join_hack_sql).where(sequences: {name:}) }
  scope :via_descriptor, ->(descriptor) { joins(sequence_join_hack_sql).where(sequences: {id: descriptor.sequences}) }

  has_many :extracts, through: :origin_relationships, source: :new_object, source_type: 'Extract'
  has_many :sequences, through: :extracts

  # This is a hack, maybe related to a Rails 5.1 bug.
  # It returns the SQL that works in 5.0/4.2 that
  # links CollectionObject to Sequences:
  # joins(derived_extracts: [:derived_sequences])
  def self.sequence_join_hack_sql
    %Q{INNER JOIN  "origin_relationships"
               ON  "origin_relationships"."old_object_id" = "collection_objects"."id"
                  AND  "origin_relationships"."new_object_type" = 'Extract'
                  AND  "origin_relationships"."old_object_type" = 'CollectionObject'
       INNER JOIN  "extracts"
               ON  "extracts"."id" =  "origin_relationships"."new_object_id"
       INNER JOIN  "origin_relationships" "origin_relationships_extracts_join"
               ON  "origin_relationships_extracts_join"."old_object_id" = "extracts"."id"
                  AND  "origin_relationships_extracts_join"."new_object_type" = 'Sequence'
                  AND  "origin_relationships_extracts_join"."old_object_type" = 'Extract'
       INNER JOIN  "sequences"
               ON  "sequences"."id" = "origin_relationships_extracts_join"."new_object_id"}
  end

  def self.batch_update(params)
    request = QueryBatchRequest.new(
      async_cutoff: params[:async_cutoff] || 50,
      klass: 'CollectionObject',
      object_filter_params: params[:collection_object_query],
      object_params: params[:collection_object],
      preview: params[:preview],
    )

    request.cap = 1000

    query_batch_update(request)
  end

  def self.batch_update_dwc_occurrence(params)
    q = Queries::CollectionObject::Filter.new(params).all

    r = BatchResponse.new
    r.method = 'batch_update_dwc_occurrence'
    r.klass = 'CollectionObject'

    c = q.all.count

    if c == 0 || c > 10000
      r.cap_reason = 'Too many (or no) collection objects (max 10k)'
      return r
    end

    if c < 51
      q.each do |co|
        co.set_dwc_occurrence
        r.updated.push co.id
      end
    else
      r.async = true
      q.each do |co|
        co.dwc_occurrence_update_query
      end
    end

    return r
  end

  def dwc_occurrence_update_query
    self.send(:set_dwc_occurrence)
  end

  handle_asynchronously :dwc_occurrence_update_query, run_at: Proc.new { 1.second.from_now }, queue: :query_batch_update

  # TODO: move to a helper
  def self.breakdown_status(collection_objects)
    collection_objects = [collection_objects] if collection_objects.class != Array

    breakdown = {
      total_objects:     collection_objects.length,
      collecting_events: {},
      determinations:    {},
      bio_overview:      []
    }

    breakdown.merge!(breakdown_buffered(collection_objects))

    collection_objects.each do |co|
      breakdown[:collecting_events].merge!(co => co.collecting_event) if co.collecting_event
      breakdown[:determinations].merge!(co => co.taxon_determinations) if co.taxon_determinations.load.any?
      breakdown[:bio_overview].push([co.total, co.biocuration_classes.collect { |a| a.name }])
    end

    breakdown
  end

  # @return [Hash]
  #   a unque list of buffered_ values observed in the collection objects passed
  def self.breakdown_buffered(collection_objects)
    collection_objects = [collection_objects] if collection_objects.class != Array
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

  # TODO: this should be refactored to be collection object centric AFTER
  # it is spec'd
  def self.earliest_date(project_id)
    a = CollectingEvent.joins(:collection_objects).where(project_id:).minimum(:start_date_year)
    b = CollectingEvent.joins(:collection_objects).where(project_id:).minimum(:end_date_year)

    return EARLIEST_DATE if a.nil? && b.nil?  # 1700-01-01

    d = nil

    if a && b
      if a < b
        d = a
      end
    else
      d = a || b
    end
    d.to_s + '-01-01'
  end

  # TODO: this should be refactored to be collection object centric AFTER
  # it is spec'd
  def self.latest_date(project_id)
    a = CollectingEvent.joins(:collection_objects).where(project_id:).maximum(:start_date_year)
    b = CollectingEvent.joins(:collection_objects).where(project_id:).maximum(:end_date_year)

    c = Time.now.strftime('%Y-%m-%d')

    return c if a.nil? && b.nil?

    d = nil

    if a && b
      if a > b
        d = a
      end
    else
      d = a || b
    end

    d.to_s + '/12/31'
  end

  # TODO: Clarify this.
  # CAREFULL - this isn't _in_, this is *with*, if it was in it would be spatial query, not a join(:geographic_items)
  #
  # Find all collection objects which have collecting events which have georeferences which have geographic_items which
  # are located within the geographic item supplied
  # @param [GeographicItem] geographic_item_id
  # @return [Scope] of CollectionObject
  def self.in_geographic_item(geographic_item, limit, steps = false)
    geographic_item_id = geographic_item.id
    if steps
      gi = GeographicItem.find(geographic_item_id)
      # find the geographic_items inside gi
      step_1 = GeographicItem.st_covered_by('any', gi) # .pluck(:id)
      # find the georeferences from the geographic_items
      step_2 = step_1.map(&:georeferences).uniq.flatten
      # find the collecting events connected to the georeferences
      step_3 = step_2.map(&:collecting_event).uniq.flatten
      # find the collection objects associated with the collecting events
      step_4 = step_3.map(&:collection_objects).flatten.map(&:id).uniq
      retval = CollectionObject.where(id: step_4.sort)
    else
      retval = CollectionObject.joins(:geographic_items)
        .where(GeographicItem.subset_of_union_of_sql(geographic_item.id))
        .limit(limit)
        .includes(:data_attributes, :collecting_event)
    end
    retval
  end

  # TODO: deprecate
  def self.selected_column_names
    @selected_column_names = {
      ce: {in: {}, im: {}},
      co: {in: {}, im: {}},
      bc: {in: {}, im: {}}
    } if @selected_column_names.nil?
    @selected_column_names
  end

  # @param [Integer] project_id
  # @return [Hash] of column names and types for collecting events
  # decode which headers to be displayed for collecting events
  def self.ce_headers(project_id)
    CollectionObject.selected_column_names
    cvt_list = InternalAttribute.where(project_id:, attribute_subject_type: 'CollectingEvent')
      .distinct
      .pluck(:controlled_vocabulary_term_id)
    # add selectable column names (unselected) to the column name list list
    ControlledVocabularyTerm.where(id: cvt_list).map(&:name).sort.each { |column_name|
      @selected_column_names[:ce][:in][column_name] = {checked: '0'}
    }
    ImportAttribute.where(project_id:, attribute_subject_type: 'CollectingEvent')
      .pluck(:import_predicate).uniq.sort.each { |column_name|
        @selected_column_names[:ce][:im][column_name] = {checked: '0'}
      }
    @selected_column_names
  end

  # @param [CollectionObject] collection_object from which to extract attributes
  # @param [Hash] col_defs - collection of selected headers, prefixes, and types
  # @return [Array] of attributes
  # Retrieve all the attributes associated with the column names (col_defs) for a specific collection_object
  def self.ce_attributes(collection_object, col_defs)
    retval = []; collection = col_defs
    unless collection.nil?
      # for this collection object, gather all the possible data_attributes
      all_internal_das = collection_object.collecting_event.internal_attributes
      all_import_das   = collection_object.collecting_event.import_attributes
      group            = collection[:ce]
      unless group.nil?
        group.each_key { |type_key|
          group[type_key.to_sym].each_key { |header|
            this_val = nil
            case type_key.to_sym
            when :in
              all_internal_das.each { |da|
                if da.predicate.name == header
                  this_val = da.value
                  break
                end
              }
              retval.push(this_val) # push one value (nil or not) for each selected header
            when :im
              all_import_das.each { |da|
                if da.import_predicate == header
                  this_val = da.value
                  break
                end
              }
              retval.push(this_val) # push one value (nil or not) for each selected header
            else
            end
          }
        }
      end
    end
    retval
  end

  # @param [Integer] project_id
  # @return [Hash] of column names and types for collection objects
  # decode which headers to be displayed for collection objects
  def self.co_headers(project_id)
    CollectionObject.selected_column_names
    cvt_list = InternalAttribute.where(project_id:, attribute_subject_type: 'CollectionObject')
      .distinct
      .pluck(:controlled_vocabulary_term_id)
    # add selectable column names (unselected) to the column name list list
    ControlledVocabularyTerm.where(id: cvt_list).map(&:name).sort.each { |column_name|
      @selected_column_names[:co][:in][column_name] = {checked: '0'}
    }
    ImportAttribute.where(project_id:, attribute_subject_type: 'CollectionObject')
      .pluck(:import_predicate).uniq.sort.each { |column_name|
        @selected_column_names[:co][:im][column_name] = {checked: '0'}
      }
    @selected_column_names
  end

  # @param [CollectionObject] collection_object from which to extract attributes
  # @param [Hash] col_defs - collection of selected headers, prefixes, and types
  # @return [Array] of attributes
  # Retrieve all the attributes associated with the column names (col_defs) for a specific collection_object
  def self.co_attributes(collection_object, col_defs)
    retval = []; collection = col_defs
    unless collection.nil?
      # for this collection object, gather all the possible data_attributes
      all_internal_das = collection_object.internal_attributes
      all_import_das   = collection_object.import_attributes
      group            = collection[:co]
      unless group.nil?
        unless group.empty?
          unless group[:in].empty?
            group[:in].each_key { |header|
              this_val = nil
              all_internal_das.each { |da|
                if da.predicate.name == header
                  this_val = da.value
                end
              }
              retval.push(this_val) # push one value (nil or not) for each selected header
            }
          end
        end
        unless group.empty?
          unless group[:im].empty?
            group[:im].each_key { |header|
              this_val = nil
              all_import_das.each { |da|
                if da.import_predicate == header
                  this_val = da.value
                end
              }
              retval.push(this_val) # push one value (nil or not) for each selected header
            }
          end
        end
      end
    end
    retval
  end

  # @param [Integer] project_id
  # @return [Hash] of column names and types for biocuration classifications
  # decode which headers to be displayed for biocuration classifications
  def self.bc_headers(project_id)
    CollectionObject.selected_column_names
    # add selectable column names (unselected) to the column name list list
    BiocurationClass.where(project_id:).map(&:name).each { |column_name|
      @selected_column_names[:bc][:in][column_name] = {checked: '0'}
    }
    @selected_column_names
  end

  # @param [CollectionObject] collection_object from which to extract attributes
  # @param [Hash] col_defs - collection of selected headers, prefixes, and types
  # @return [Array] of attributes
  # Retrieve all the attributes associated with the column names (col_defs) for a specific collection_object
  def self.bc_attributes(collection_object, col_defs)
    retval = []
    collection = col_defs
    unless collection.nil?
      group = collection[:bc]
      unless group.nil?
        unless group.empty?
          unless group[:in].empty?
            group[:in].each_key { |header|
              this_val = collection_object.biocuration_classes.map(&:name).include?(header) ? '1' : '0'
              retval.push(this_val) # push one value (nil or not) for each selected header
            }
          end
        end
      end
    end
    retval
  end

  # @param [Array] collecting_event_ids (e.g., from CollectingEvent.in_date_range)
  # @param [Array] area_object_ids (e.g., from GeographicItem.gather_selected_data())
  # @return [Scope] of intersection of collecting events (usually by date range)
  #   and collection objects (usually by inclusion in geographic areas/items)
  def self.from_collecting_events(collecting_event_ids, area_object_ids, area_set, project_id)
    collecting_events_clause = {collecting_event_id: collecting_event_ids, project: project_id}
    area_objects_clause      = {id: area_object_ids, project: project_id}

    if (collecting_event_ids.empty?)
      collecting_events_clause = {project: project_id}
    end

    if (area_object_ids.empty?)
      area_objects_clause = {}
      if (area_set)
        area_objects_clause = 'false'
      end
    end

    retval = CollectionObject.joins(:collecting_event)
      .where(collecting_events_clause)
      .where(area_objects_clause)
    retval
  end

  # TODO: move to filter
  # @param [Hash] search_start_date string in form 'yyyy-mm-dd'
  # @param [Hash] search_end_date string in form 'yyyy-mm-dd'
  # @param [Hash] partial_overlap 'on' or 'off'
  # @return [Scope] of selected collection objects through collecting events with georeferences, remember to scope to project!
  def self.in_date_range(search_start_date: nil, search_end_date: nil, partial_overlap: 'on')
    allow_partial = (partial_overlap.downcase == 'off' ? false : true) # TODO: Just get the correct values from the form!
    q = Queries::CollectingEvent::Filter.new(start_date: search_start_date, end_date: search_end_date, partial_overlap_dates: allow_partial)
    joins(:collecting_event).where(q.between_date_range_facet.to_sql)
  end

  # @param used_on [String] required, one of `TaxonDetermination`, `BiologicalAssociation`
  # @return [Scope]
  #    the max 10 most recently used collection_objects, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '')
    return [] if used_on != 'TaxonDetermination' && used_on != 'BiologicalAssociation'
    t = case used_on
        when 'TaxonDetermination'
          TaxonDetermination.arel_table
        when 'BiologicalAssociation'
          BiologicalAssociation.arel_table
        end

    p = CollectionObject.arel_table

    # i is a select manager
    i = case used_on
        when 'BiologicalAssociation'
          t.project(t['biological_association_subject_id'], t['updated_at']).from(t)
            .where(
              t['updated_at'].gt(1.week.ago).and(
                t['biological_association_subject_type'].eq('CollectionObject')
              )
            )
              .where(t['updated_by_id'].eq(user_id))
              .where(t['project_id'].eq(project_id))
              .order(t['updated_at'].desc)
        else
          # TODO: update to reference new TaxonDetermination
          t.project(t['taxon_determination_object_id'], t['taxon_determination_object_type'], t['updated_at']).from(t)
            .where(t['updated_at'].gt( 1.week.ago ))
            .where(t['updated_by_id'].eq(user_id))
            .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        end

    # z is a table alias
    z = i.as('recent_t')

    j = case used_on
        when 'BiologicalAssociation'
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z['biological_association_subject_id'].eq(p['id'])
          ))
        else
          # TODO: needs to be fixed to scope the taxon_determination_object_type
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['taxon_determination_object_id'].eq(p['id'])))
        end

    CollectionObject.joins(j).pluck(:id).uniq
  end

  # @params target [String] one of `TaxonDetermination`, `BiologicalAssociation` , nil
  # @return [Hash] otus optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: CollectionObject.pinned_by(user_id).where(project_id:).to_a,
      recent: []
    }

    if target && !r.empty?
      n = target.tableize.to_sym
      h[:recent] = CollectionObject.where('"collection_objects"."id" IN (?)', r.first(10) ).to_a
      h[:quick] = (CollectionObject.pinned_by(user_id).pinboard_inserted.where(project_id:).to_a  +
                   CollectionObject.where('"collection_objects"."id" IN (?)', r.first(4) ).to_a).uniq
    else
      h[:recent] = CollectionObject.where(project_id:, updated_by_id: user_id).order('updated_at DESC').limit(10).to_a
      h[:quick] = CollectionObject.pinned_by(user_id).pinboard_inserted.where(project_id:).to_a
    end

    h
  end

  # TODO: Unify with Extract in concern
  # @return [Identifier::Local::CatalogNumber, nil]
  #   the first (position) catalog number for this collection object, either on specimen, or container
  def preferred_catalog_number
    if i = Identifier::Local::CatalogNumber.where(identifier_object: self).order(:position).first
      i
    else
      if container
        container.identifiers.where(identifiers: {type: 'Identifier::Local::CatalogNumber'}).order(:position).first
      else
        nil
      end
    end
  end

  # @return [Identifier::Local::RecordNumber, nil]
  #   the first (position) record_Number, on a specimen
  #   !1 Doesn't presently support containers
  def preferred_record_number
    Identifier::Local::RecordNumber.where(identifier_object: self).order(:position).first
  end

  def geographic_name_classification
    # don't load the whole object, just the fields we need
    if a = DwcOccurrence.where(dwc_occurrence_object: self).select(:country, :stateProvince, :county).first

      c = a.country
      s = a.stateProvince
      y = a.county

      v = ::Utilities::Geo::DICTIONARY[c]
      c = v if v
      # s = v if v = ::Utilities::Geo::DICTIONARY[s] # None in there yet
      # y = v if v = ::Utilities::Geo::DICTIONARY[y] # None in there yet

      return {
        country: c,
        state: s,
        county: y
      }
    end
  end

  # return [Boolean]
  #    True if instance is a subclass of BiologicalCollectionObject
  def is_biological?
    self.class <= BiologicalCollectionObject ? true : false
  end

  def annotations
    h = annotations_hash
    (h['biocuration classifications'] = biocuration_classes) if is_biological? && biocuration_classifications.load.any?
    h
  end

  def sv_missing_accession_fields
    soft_validations.add(:accessioned_at, 'Date is not selected') if self.accessioned_at.nil? && !self.accession_provider.nil?
    soft_validations.add(:base, 'Provider is not selected') if !self.accessioned_at.nil? && self.accession_provider.nil?
  end

  def sv_missing_deaccession_fields
    soft_validations.add(:deaccessioned_at, 'Date is not selected') if self.deaccessioned_at.nil? && self.deaccession_reason.present?
    soft_validations.add(:base, 'Recipient is not selected') if self.deaccession_recipient.nil? && self.deaccession_reason && self.deaccessioned_at
    soft_validations.add(:deaccession_reason, 'Reason is is not defined') if self.deaccession_reason.blank? && self.deaccession_recipient && self.deaccessioned_at
  end

  def sv_missing_determination
    # see biological_collection_object
  end

  def sv_missing_collecting_event
    # see biological_collection_object
  end

  def sv_missing_preparation_type
    # see biological_collection_object
  end

  def sv_missing_repository
    # WHY? -  see biological_collection_object
  end

  def sv_missing_biocuration_classification
    # see biological_collection_object
  end

  # See Depiction#destroy_image_stub_collection_object
  # Used to determin if the CO can be
  # destroy after moving an image off
  # this object.
  def is_image_stub?
    r = [
      collecting_event_id.blank?,
      !depictions.reload.any?,
      identifiers.count <= 1,
      !taxon_determinations.any?,
      !type_materials.any?,
      !citations.any?,
      !data_attributes.any?,
      !notes.any?,
      !observations.any?
    ]

   !r.include?(false)

  end

  protected

  def collecting_event_belongs_to_project
    if collecting_event&.persisted? && (Current.project_id || project_id)
      errors.add(:base, 'collecting event is not from this project') if collecting_event.project_id != (Current.project_id || project_id)
    end
  end

  def check_that_both_of_category_and_total_are_not_present
    errors.add(:ranged_lot_category_id, 'Both ranged_lot_category and total can not be set') if ranged_lot_category_id.present? && total.present?
  end

  def check_that_either_total_or_ranged_lot_category_id_is_present
    errors.add(:base, 'Either total or a ranged lot category must be provided') if ranged_lot_category_id.blank? && total.blank?
  end

  def assign_type_if_total_or_ranged_lot_category_id_provided
    if self.total == 1
      self.type = 'Specimen'
    elsif self.total.to_i > 1
      self.type = 'Lot'
    elsif total.nil? && ranged_lot_category_id.present?
      self.type = 'RangedLot'
    end
    true
  end

  def reject_collecting_event(attributed)
    reject = true
    CollectingEvent.core_attributes.each do |a|
      if attributed[a].present?
        reject = false
        break
      end
    end
    # !! does not account for georeferences_attributes!
    reject
  end

end

require_dependency 'specimen'
require_dependency 'lot'
require_dependency 'ranged_lot'
