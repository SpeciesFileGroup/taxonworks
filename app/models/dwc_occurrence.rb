# A Darwin Core Record for the Occurrence core.  Field generated from Ruby dwc-meta, which references
# the same spec that is used in the IPT, and the Dwc Assistant.  Each record
# references a specific CollectionObject or AssertedDistribution.
#
# Important: This is a cache/index, data here are periodically destroyed and regenerated from multiple tables in TW.
#
# DWC attributes are camelCase to facilitate matching
# dwcClass is a replacement for the Rails reserved 'Class'
#
# All DC attributes (attributes not in DwcOccurrence::TW_ATTRIBUTES) in this table are namespaced to dc ("http://purl.org/dc/terms/", "http://rs.tdwg.org/dwc/terms/")
#
# README:
#   There is a two part strategy to building the index. 1) An individual record will rebuild on request with `parameter to collection_objects/123/dwc*?build=true`.
#   2) Wipe, and rebuild on some schedule. It would in theory be possible to track and rebuild when a class of every property was created (or updated), however
#   this is a lot of overhead to inject/code for a lot of models. It would inject latency at numerous stages that would perhaps impact UI performance.
#
#  Notes -
#
#  This experiment isn't going to work at scale, too many preceding calls for big returns
#
#  after_find :refresh, if: -> { persisted? && is_stale? }
#
#  def refresh
#    dwc_occurrence_object.set_dwc_occurrence
#  end
#
# TODO: The basisOfRecord CVTs are not super informative.
#    We know collection object is definitely 1:1 with PreservedSpecimen, however
#    AssertedDistribution could be HumanObservation (if source is person), or ... what? if
#    its a published record.  Seems we need a 'PublishedAssertation', just like we model the data.
#
# Gotchas.
#   * updated_at is set by touching the record, not via housekeeping.
#
class DwcOccurrence < ApplicationRecord
  self.inheritance_column = nil

  include Housekeeping

  DC_NAMESPACE = 'http://rs.tdwg.org/dwc/terms/'.freeze

  # Not yet implemented, but likely needed (at an even higher level)
  # ? :id
  TW_ATTRIBUTES = [
    :id,
    :project_id,
    :created_at,
    :updated_at,
    :created_by_id,
    :updated_by_id,
    :dwc_occurrence_object_type,
    :dwc_occurence_object_id
  ].freeze

  HEADER_CONVERTERS = {
    'dwcClass' => 'class',
  }.freeze

  CSV::HeaderConverters[:dwc_headers] = lambda do |field|
    d = DwcOccurrence::HEADER_CONVERTERS[field]
    d ? d : field
  end

  # TODO: Consider using more broadly?
  # Strip nils when `to_json` used
  def as_json(options = {})
    super(options.merge(except: attributes.keys.select { |key| self[key].nil? }))
  end

  belongs_to :dwc_occurrence_object, polymorphic: true, inverse_of: :dwc_occurrence
  has_one :collecting_event, through: :dwc_occurrence_object, inverse_of: :dwc_occurrences

  before_validation :generate_uuid_if_required
  before_validation :set_metadata_attributes

  validates_presence_of :basisOfRecord

  validates :dwc_occurrence_object, presence: true
  validates :dwc_occurrence_object_id, uniqueness: { scope: [:dwc_occurrence_object_type,:project_id] }

  attr_accessor :occurrence_identifier

  def self.annotates?
    false
  end

  # TODO -
  #   these can be deprecated for integration with Queries::DwcOccurrence::Filter

  # that matches, consider moving to Shared
  # @return [ActiveRecord::Relation]
  def self.collection_objects_join
    a = arel_table
    b = ::CollectionObject.arel_table
    j = a.join(b).on(a[:dwc_occurrence_object_type].eq('CollectionObject').and(a[:dwc_occurrence_object_id].eq(b[:id])))
    joins(j.join_sources)
  end

  # that matches, consider moving to Shared
  # @return [ActiveRecord::Relation]
  def self.asserted_distributions_join
    a = arel_table
    b = ::AssertedDistribution.arel_table
    j = a.join(b).on(a[:dwc_occurrence_object_type].eq('AssertedDistribution').and(a[:dwc_occurrence_object_id].eq(b[:id])))
    joins(j.join_sources)
  end

  # ---

  # @return [Scope]
  #   all DwcOccurrences for the Otu
  #   * Includes synonymy (coordinate OTUs).
  def self.scoped_by_otu(otu)
    a,b = nil, nil

    if otu.taxon_name_id.present?
      a = ::Queries::DwcOccurrence::Filter.new(
        asserted_distribution_query: {
          taxon_name_query: {
            taxon_name_id: otu.taxon_name_id,
            descendants: false, # include self
            synonymify: true } })

      b = ::Queries::DwcOccurrence::Filter.new(
        collection_object_query: {
          taxon_name_query: {
            taxon_name_id: otu.taxon_name_id,
            descendants: false, # include self
            synonymify: true } })
    else
      a = ::Queries::DwcOccurrence::Filter.new(
        asserted_distribution_query: {
          otu_id: otu.id})

      b = ::Queries::DwcOccurrence::Filter.new(
        collection_object_query: {
          otu_query: { otu_id: otu.id}})
    end

    from("((#{a.all.to_sql}) UNION (#{b.all.to_sql})) as dwc_occurrences")
  end

  # Return scopes by a collection object filter
  def self.by_collection_object_filter(filter_scope: nil, project_id: nil)
    return DwcOccurrence.none if project_id.nil? || filter_scope.nil?

    c = ::CollectionObject.arel_table
    d = arel_table

    # TODO: hackish
    k = ::CollectionObject.select('coscope.id').from( '(' + filter_scope.to_sql + ') as coscope ' )

    a = self.collection_objects_join
      .where('dwc_occurrences.project_id = ?', project_id)
      .where(dwc_occurrence_object_id: k)
      .select(::DwcOccurrence.target_columns) # TODO !! Will have to change when AssertedDistribution and other types merge in
    a
  end

  # @return [Array]
  #   of column names as symbols that are blank in *ALL* projects (not just this one)
  def self.empty_fields
    empty_in_all_projects = ActiveRecord::Base.connection.execute("select attname
    from pg_stats
    where tablename = 'dwc_occurrences'
    and most_common_vals is null
    and most_common_freqs is null
    and histogram_bounds is null
    and correlation is null
    and null_frac = 1;").pluck('attname').map(&:to_sym)

    empty_in_all_projects #  - target_columns
  end

  # @return [Array]
  #   of symbols
  # !! TODO: When we come to adding AssertedDistributions, FieldOccurrnces, etc. we will have to
  # make this more flexible
  def self.target_columns
    [:id, # must be in position 0
     :occurrenceID,
     :basisOfRecord,
     :dwc_occurrence_object_id,   # !! We don't want this, but need it in joins, it is removed in trim via `.excluded_columns` below
     :dwc_occurrence_object_type, # !! ^
    ] + CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys
  end

  # @return [Array]
  #   of symbols
  def self.excluded_columns
    ::DwcOccurrence.columns.collect{|c| c.name.to_sym} - (self.target_columns - [:id, :dwc_occurrence_object_id, :dwc_occurrence_object_type])
  end

  # @return [Scope]
  #   the columns inferred to have data
  def self.computed_columns
    select(target_columns)
  end

  def basis
    case dwc_occurrence_object_type
    when 'CollectionObject'
      if dwc_occurrence_object.is_fossil?
        return 'FossilSpecimen'
      else
        return 'PreservedSpecimen'
      end
    when 'AssertedDistribution'
      # Used to fork b/b Source::Human and Source::Bibtex:
      case dwc_occurrence_object.source&.type || dwc_occurrence_object.sources.order(cached_nomenclature_date: :DESC).first.type
      when 'Source::Bibtex'
        return 'MaterialCitation'
      when 'Source::Human'
        return 'HumanObservation'
      else # Not recommended at this point
        return 'Occurrence'
      end
    end
    'Undefined'
  end

  def uuid_identifier_scope
    dwc_occurrence_object&.identifiers&.where('identifiers.type like ?', 'Identifier::Global::Uuid%')&.order(:position)
  end

  def occurrence_identifier
    @occurrence_identifier ||= uuid_identifier_scope&.first
  end

  # @param force [Boolean]
  #   true - only create identifier if identifier exists
  #   false - check if occurrenceID is present, if it is, assume identifier (still) exists
  # TODO: quick check if occurrenceID exists in table?! <-> locking sync !?
  def generate_uuid_if_required(force = false)
    if force # really make sure there is an object to work with
      create_object_uuid if !occurrence_identifier && !dwc_occurrence_object.nil? # TODO: can be simplified when inverse_of/validation added to identifiers
    else # assume if occurrenceID is not blank identifier is present
      if occurrenceID.blank?
        create_object_uuid if !occurrence_identifier && !dwc_occurrence_object.nil? # TODO: can be simplified when inverse_of/validation added to identifiers
      end
    end
  end

  # @return [Boolean]
  #   By looking at the data, determine if a related record
  #   has been updated since this record ws updated at.
  #
  # !! This a spot check, it's not (yet) coded to be comprehensive.
  # !! You should request a full rebuild (rebuild=true) at display time
  # !! to ensure an up-to-date individual record
  #
  def is_stale?
    case dwc_occurrence_object_type
    when 'CollectionObject'

      # Checks made on values, not time (necessary to handle lists)
      return true if taxon_determination_is_stale?

      # Order these roughgly by most probable/frequent changes, and/or fewest db calls required
      times = [
        dwc_occurrence_object.updated_at, # Shouldn't be neccessary since on_save rebuilds, but cheap here
        dwc_occurrence_object.collecting_event&.updated_at,
        dwc_occurrence_object.taxon_determinations.order(:position)&.first&.updated_at,
        dwc_occurrence_object.biocuration_classifications.order(:updated_at).first&.updated_at,
        dwc_occurrence_object.georeferences.order(:updated_at).first&.updated_at,
        dwc_occurrence_object.data_attributes.order(:updated_at).first&.updated_at,

        dwc_occurrence_object.collecting_event&.data_attributes&.order(:updated_at)&.first&.updated_at,
      ]

      n = read_attribute(:updated_at) # || Time.current <- if this then never stale!

      times.each do |v|
        next if v.nil?
        return true if v > n
      end

      return false
    else # AssertedDistribution
      dwc_occurrence_object.updated_at > updated_at
    end
  end

  # @return Boolean
  #   acts_as_list actions don't trigger updated_at changes, handle this by comparing current values
  def taxon_determination_is_stale?
    dwc_occurrence_object&.taxon_determinations.order(:position).first&.otu&.taxon_name&.cached_name_and_author_year != scientificName
  end

  protected

  def create_object_uuid
    @occurrence_identifier = Identifier::Global::Uuid::TaxonworksDwcOccurrence.create!(
      identifier_object: dwc_occurrence_object,
      by: dwc_occurrence_object&.creator, # revisit, why required?
      project_id: dwc_occurrence_object&.project_id, # Current.project_id,  # revisit, why required?
      is_generated: true)
  end

  def set_metadata_attributes
    write_attribute( :basisOfRecord, basis)
    write_attribute( :occurrenceID, occurrence_identifier&.identifier)
  end

end
