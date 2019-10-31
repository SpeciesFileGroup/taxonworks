# An Otu (loosely, operational taxonomic unit) can be thought of as a unit of study.  In most cases an otu is a taxon.
#
# An Otu is defined by its underlying data and may be labeled with a name (TaxonName). Otus are used to represent rows
# in matrices, taxon pages, individuals or populations, or arbitrary clusters of organisms (e.g. 'unsorted specimens in this container').
# Otus are a primary unit of work in TaxonWorks.
#
# OTU is labeled with a name, either arbitrarily given or specifically linked to a taxon_name_id.
#
# @!attribute name
#   @return [String]
#   A label for the OTU.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute taxon_name_id
#   @return [Integer]
#   The id of the nomenclatural name for this OTU.  The presence of a nomenclatural name carries no biological meaning, it is
#   simply a means to organize concepts within a nomenclatural system.
#
# TODO Semantics vs. taxon_name_id
#
class Otu < ApplicationRecord
  include Housekeeping
  include SoftValidation
  #include Shared::AlternateValues   # No alternate values on Name!! 
  include Shared::Citations          # TODO: have to think hard about this vs. using Nico's framework
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::Depictions
  include Shared::Loanable
  include Shared::Confidences
  include Shared::Observations 
  include Shared::HasPapertrail
  include Shared::IsData

  GRAPH_ENTRY_POINTS = [:asserted_distributions, :biological_associations, :common_names, :contents, :data_attributes]

  belongs_to :taxon_name, inverse_of: :otus

  has_many :asserted_distributions, inverse_of: :otu

  has_many :biological_associations, as: :biological_association_subject, inverse_of: :biological_association_subject 
  has_many :related_biological_associations, as: :biological_association_object, inverse_of: :biological_association_object, class_name: 'BiologicalAssociation'

  has_many :taxon_determinations, inverse_of: :otu, dependent: :destroy
  has_many :collection_objects, through: :taxon_determinations, source: :biological_collection_object, inverse_of: :otus

  has_many :extracts, through: :collection_objects, source: :derived_extracts

  has_many :sequences, through: :extracts, source: :derived_sequences

  has_many :collecting_events, -> { distinct }, through: :collection_objects

  has_many :common_names, dependent: :destroy
  has_many :collection_profiles # @proceps dependent: what?
  has_many :contents, inverse_of: :otu, dependent: :destroy
  has_many :geographic_areas_from_asserted_distributions, through: :asserted_distributions, source: :geographic_area
  has_many :geographic_areas_from_collecting_events, through: :collecting_events, source: :geographic_area
  has_many :georeferences, through: :collecting_events

  has_many :content_topics, through: :contents, source: :topic

  has_many :observations, inverse_of: :otu
  has_many :descriptors, through: :observations

  scope :with_taxon_name_id, -> (taxon_name_id) { where(taxon_name_id: taxon_name_id) }
  scope :with_name, -> (name) { where(name: name) }

  scope :with_biological_associations, -> {
    joins("LEFT OUTER JOIN biological_associations tnr1 ON otus.id = tnr1.biological_association_subject_id AND tnr1.biological_association_object_type = 'Otu'").
    joins("LEFT OUTER JOIN biological_associations tnr2 ON otus.id = tnr2.biological_association_object_id AND tnr2.biological_association_object_type = 'Otu'").
    where('tnr1.biological_association_object_id IS NOT NULL OR tnr2.biological_association_object_id IS NOT NULL')
  }


  # @return [Otu, nil, false]
  def parent_otu
    return nil if taxon_name_id.blank?
    taxon_name.ancestors.each do |a|
      if a.otus.load.count == 1
        return a.otus.first
      elsif a.otus.count > 1
        return false 
      else
        return nil
      end
    end
    nil
  end

    # @param [Integer] otu_id
  # @param [String] rank_class
  # @return [Scope]
  #    Otu.joins(:taxon_name).where(taxon_name: q).to_sql
  def self.self_and_descendants_of(otu_id, rank_class = nil)
    if o = Otu.joins(:taxon_name).find(otu_id)
      if rank_class.nil?
        joins(:taxon_name).where(taxon_name: o.taxon_name.self_and_descendants)
      else
        joins(:taxon_name).where(taxon_name: o.taxon_name.self_and_descendants.where( rank_class: rank_class))
      end
    else # no taxon name just return self in scope
      Otu.where(id: otu_id)
    end
  end
 
  # @return [Otu::ActiveRecord_Relation]
  # 
  # All OTUs that are synonymous/same/matching target, for either 
  #    historical and pragmatic (i.e. share the same `taxon_name_id`), or 
  #    nomenclatural reasons (are synonyms of the taxon name). Includes self.
  #
  def self.coordinate_otus(otu_id)
    begin
      i = Otu.joins(:taxon_name).find(otu_id)
      j = i.taxon_name.cached_valid_taxon_name_id
      o = Otu.arel_table
      t = TaxonName.arel_table

      q = o.join(t, Arel::Nodes::InnerJoin).on(
        o[:taxon_name_id].eq( t[:id] ).and(t[:cached_valid_taxon_name_id].eq(j))
      )

      Otu.joins(q.join_sources) 
    rescue ActiveRecord::RecordNotFound
      Otu.where(id: otu_id)
    end
  end

  def current_collection_objects
    collection_objects.where(taxon_determinations: {position: 1})
  end

  validate :check_required_fields

  soft_validate(:sv_taxon_name, set: :taxon_name)
  soft_validate(:sv_duplicate_otu, set: :duplicate_otu)

  accepts_nested_attributes_for :common_names, allow_destroy: true

  # @return [Array]
  #   all bilogical associations this Otu is part of
  def all_biological_associations
    # !! If self relationships are ever made possible this needs a DISTINCT clause
    BiologicalAssociation.find_by_sql(
      "SELECT biological_associations.*
         FROM biological_associations
         WHERE biological_associations.biological_association_subject_id = #{self.id} 
           AND biological_associations.biological_association_subject_type = 'Otu'
       UNION
       SELECT biological_associations.*
         FROM biological_associations
         WHERE biological_associations.biological_association_object_id = #{self.id}
           AND biological_associations.biological_association_object_type = 'Otu' ")
  end

  # return [Scope] the Otus bound to that taxon name and its descendants
  def self.for_taxon_name(taxon_name)
    if taxon_name.kind_of?(String) || taxon_name.kind_of?(Integer)
      tn = TaxonName.find(taxon_name)
    else
      tn = taxon_name
    end
    Otu.joins(taxon_name: [:ancestor_hierarchies]).where(taxon_name_hierarchies: {ancestor_id: tn.id})
  end

  # TODO: This need to be renamed to reflect "simple" association
  def self.batch_preview(file: nil, ** args)
    # f     = CSV.read(file, headers: true, col_sep: "\t", skip_blanks: true, header_converters: :symbol)
    @otus = []
    File.open(file).each do |row|
      name = row.strip
      next if name.blank?
      @otus.push(Otu.new(name: row.strip))
    end
    @otus
  end

  def self.batch_create(otus: {}, ** args)
    new_otus = []
    begin
      Otu.transaction do
        otus.each_key do |k|
          o = Otu.new(otus[k])
          o.save!
          new_otus.push(o)
        end
      end
    rescue
      return false
    end
    new_otus
  end

  # @return [Boolean]
  #   whether or not this otu is coordinate (see coordinate_otus) with this otu
  def coordinate_with?(otu_id)
    Otu.coordinate_otus(otu_id).where(otus: {id: id}).any?
  end

  # Hernán - this is extremely hacky, I'd like to
  # map core keys to procs, use yield:, use cached values,
  # add logic for has_many handling (e.g. identifiers) etc.
  # ultmately, each key maps to a proc that returns a value
  #
  # deprecated for new approach in CollectionObject, AssertedDistribution
  def dwca_core
    core = Dwca::GbifProfile::CoreTaxon.new

    core.nomenclaturalCode        = (taxon_name.rank_class.nomenclatural_code.to_s.upcase)
    core.taxonomicStatus          = (taxon_name.unavailable_or_invalid? ? nil : 'accepted')
    core.nomenclaturalStatus      = (taxon_name.classification_invalid_or_unavailable? ? nil : 'available') # needs tweaking
    core.scientificName           = taxon_name.cached
    core.scientificNameAuthorship = taxon_name.cached_author_year
    core.scientificNameID         = taxon_name.identifiers.first.identifier
    core.taxonRank                = taxon_name.rank
    core.namePublishedIn          = taxon_name.source.cached
    core
  end

  # TODO: Deprecate for helper method, HTML does not belong here
  def otu_name
    if !name.blank?
      name
    elsif !taxon_name_id.nil?
      taxon_name.cached_html_name_and_author_year
    else
      nil
    end
  end

  # TODO: move to helper method likely
  def distribution_geoJSON
    a_ds = Gis::GeoJSON.feature_collection(geographic_areas_from_asserted_distributions, :asserted_distributions)
    c_os = Gis::GeoJSON.feature_collection(collecting_events, :collecting_events_georeferences)
    c_es = Gis::GeoJSON.feature_collection(geographic_areas_from_collecting_events, :collecting_events_geographic_area)
    Gis::GeoJSON.aggregation([a_ds, c_os, c_es], :distribution)
  end

  # @param used_on [String] required, one of `AssertedDistribution`, `Content`, `BiologicalAssociation`
  # @return [Scope]
  #   the max 10 most recently used otus, as `used_on`
  def self.used_recently(used_on = '')
    t = case used_on 
        when 'AssertedDistribution'
          AssertedDistribution.arel_table
        when 'Content'
          Content.arel_table
        when 'BiologicalAssociation'
          BiologicalAssociation.arel_table
        when 'TaxonDetermination'
          TaxonDetermination.arel_table
        end

    p = Otu.arel_table 

    # i is a select manager
    i = case used_on 
        when 'BiologicalAssociation'
          t.project(t['biological_association_object_id'], t['updated_at']).from(t)
            .where(
              t['updated_at'].gt(1.weeks.ago).and(
                t['biological_association_object_type'].eq('Otu')
              )
          )
            .order(t['updated_at'])
        else
          t.project(t['otu_id'], t['updated_at']).from(t)
            .where(t['updated_at'].gt( 1.weeks.ago ))
            .order(t['updated_at'])
        end

    z = i.as('recent_t')

    j = case used_on
        when 'BiologicalAssociation' 
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z['biological_association_object_id'].eq(p['id'])
          ))
        else
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['otu_id'].eq(p['id'])))
        end

    Otu.joins(j).distinct.limit(10)
  end

  # @params target [String] one of nil, `AssertedDistribution`, `Content`, `BiologicalAssociation`, 'TaxonDetermination'
  # @return [Hash] otus optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    h = {
      quick: [],
      pinboard: Otu.pinned_by(user_id).where(project_id: project_id).to_a
    }

    if target
      h[:recent] = Otu.where(project_id: project_id).used_recently(target).limit(10).to_a
    else
      h[:recent] = Otu.where(project_id: project_id).order('updated_at DESC').limit(10).to_a
    end

    h[:quick] = (Otu.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  + h[:recent][0..3]).uniq 
    h
  end

  protected

  def check_required_fields
    if taxon_name_id.blank? && name.blank?
      errors.add(:taxon_name_id, 'and/or name should be selected')
      errors.add(:name, 'and/or taxon name should be selected')
    end
  end

  def sv_taxon_name
    soft_validations.add(:taxon_name_id, 'Nomenclature (taxon name) is not assigned') if taxon_name_id.nil?
  end

  def sv_duplicate_otu
    unless Otu.with_taxon_name_id(taxon_name_id).with_name(name).not_self(self).with_project_id(project_id).empty?
      m = "Another OTU with an identical nomenclature (taxon name) and name exists in this project"
      soft_validations.add(:taxon_name_id, m)
      soft_validations.add(:name, m )
    end
  end

end



