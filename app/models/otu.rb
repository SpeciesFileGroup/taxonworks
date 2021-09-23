# An Otu (loosely, operational taxonomic unit) can be thought of as a unit of study.  In most cases an otu is a taxon.
#
# An Otu is defined by its underlying data and may be labeled with a name (TaxonName). Otus are used to represent rows
# in matrices, taxon eages, individuals or populations, or arbitrary clusters of organisms (e.g. 'unsorted specimens in this container').
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
  include Shared::BiologicalAssociations
  include Shared::HasPapertrail
  include Shared::OriginRelationship

  include Shared::Taxonomy

  include Shared::MatrixHooks::Member
  include Otu::MatrixHooks

  include Shared::IsData

  is_origin_for 'Sequence', 'Extract'

  GRAPH_ENTRY_POINTS = [:asserted_distributions, :biological_associations, :common_names, :contents, :data_attributes]

  belongs_to :taxon_name, inverse_of: :otus

  has_many :asserted_distributions, inverse_of: :otu, dependent: :restrict_with_error

  has_many :biological_associations, as: :biological_association_subject, inverse_of: :biological_association_subject, dependent: :restrict_with_error
  has_many :related_biological_associations, as: :biological_association_object, inverse_of: :biological_association_object, class_name: 'BiologicalAssociation', dependent: :restrict_with_error

  has_many :taxon_determinations, inverse_of: :otu, dependent: :destroy # TODO: change
  has_many :collection_objects, through: :taxon_determinations, source: :biological_collection_object, inverse_of: :otus

  has_many :extracts, through: :collection_objects, source: :extracts
  has_many :sequences, through: :extracts, source: :derived_sequences

  has_many :collecting_events, -> { distinct }, through: :collection_objects
  has_many :common_names, dependent: :destroy
  has_many :collection_profiles, dependent: :restrict_with_error  # @proceps dependent: what? DD: profile should never be update, a new profile should be created insted
  has_many :contents, inverse_of: :otu, dependent: :destroy
  has_many :geographic_areas_from_asserted_distributions, through: :asserted_distributions, source: :geographic_area
  has_many :geographic_areas_from_collecting_events, through: :collecting_events, source: :geographic_area
  has_many :georeferences, through: :collecting_events

  has_many :content_topics, through: :contents, source: :topic

  has_many :observation_matrix_row_items, inverse_of: :otu, dependent: :delete_all, class_name: 'ObservationMatrixRowItem::Single::Otu'
  has_many :observation_matrix_rows, inverse_of: :collection_object, dependent: :delete_all
  has_many :observation_matrices, through: :observation_matrix_rows

  has_many :observations, inverse_of: :otu, dependent: :restrict_with_error
  has_many :descriptors, through: :observations

  scope :with_taxon_name_id, -> (taxon_name_id) { where(taxon_name_id: taxon_name_id) }
  scope :with_name, -> (name) { where(name: name) }

  # @return Scope
  def self.alphabetically
    includes(:taxon_name).select('otus.*, taxon_names.cached').references(:taxon_names).order('taxon_names.cached ASC')
  end

  # @param [Integer] otu_id
  # @param [String] rank_class
  # @return [Scope]
  #    Otu.joins(:taxon_name).where(taxon_name: q).to_sql
  def self.self_and_descendants_of(otu_id, rank_class = nil)
    if o = Otu.joins(:taxon_name).find(otu_id)
      if rank_class.nil?
        joins(:taxon_name).
        where('cached_valid_taxon_name_id IN (?)', o.taxon_name.self_and_descendants.pluck(:id)) #this also covers synonyms of self
      else
        joins(:taxon_name).
        where('cached_valid_taxon_name_id IN (?)', o.taxon_name.self_and_descendants.pluck(:id)).
        where( 'taxon_names.rank_class = ?', rank_class)
      end
    else # no taxon name just return self in scope
      Otu.where(id: otu_id)
    end
  end

  # @return [Otu::ActiveRecordRelation]
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

  # @return [Otu::ActiveRecordRelation]
  #   if the Otu is a child, via synonymy or not, of the taxon name
  #   !! Invalid taxon_name_ids return nothing
  #   !! Taxon names with synonyms return the OTUs of their synonyms
  def self.descendant_of_taxon_name(taxon_name_id)
    o = Otu.arel_table
    t = TaxonName.arel_table
    h = TaxonNameHierarchy.arel_table

    q = o.join(t, Arel::Nodes::InnerJoin).on(
      o[:taxon_name_id].eq( t[:id]))
      .join(h, Arel::Nodes::InnerJoin).on(
        t[:cached_valid_taxon_name_id].eq(h[:descendant_id]))

    Otu.joins(q.join_sources).where(h[:ancestor_id].eq(taxon_name_id).to_sql)
  end

  def current_collection_objects
    collection_objects.where(taxon_determinations: {position: 1})
  end

  validate :check_required_fields

  soft_validate(:sv_taxon_name, set: :taxon_name)
  soft_validate(:sv_duplicate_otu, set: :duplicate_otu)

  accepts_nested_attributes_for :common_names, allow_destroy: true

  # @return [Otu#id, nil, false]
  #  nil - there is no OTU parent with a valid taxon name possible
  #  false - there is > 1 OTU parent with a valid taxon name possible
  #  id - the (unambiguous) id of the nearest parent OTU attached to a valid taoxn name
  #
  #  Note this is used CoLDP export. Do not change without considerations there.
  def parent_otu_id(skip_ranks: [], prefer_unlabelled_otus: false)
    return nil if taxon_name_id.nil?

    # TODO: Unify to a single query

    candidates = TaxonName.joins(:otus, :descendant_hierarchies)
      .that_is_valid
      .where.not(id: taxon_name_id)
      .where(taxon_name_hierarchies: {descendant_id: taxon_name_id})
      .where.not(rank_class: skip_ranks)
      .order('taxon_name_hierarchies.generations')
      .limit(1)
      .pluck(:id)

    if candidates.size == 1
      otus = Otu.where(taxon_name_id: candidates.first).to_a
      otus.select! { |o| o.name.nil? } if prefer_unlabelled_otus && otus.size > 1

      if otus.size == 1
        return otus.first.id
      elsif otus.size > 1
        return false
      else
        return nil
      end
    else
      return nil
    end
  end

  # @return [Array]
  #   of ancestral otu_ids
  # !! This method does not fork, as soon as 2 ancestors are
  # !! hit the list terminates.
  def ancestor_otu_ids(prefer_unlabelled_otus: true)
    ids =  []
    a = parent_otu_id(prefer_unlabelled_otus: true)
    while a
      ids.push a
      b = Otu.find(a)
      a = b.parent_otu_id(prefer_unlabelled_otus: true)
    end
    ids
  end

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
    core.taxonomicStatus          = (!taxon_name.is_valid? ? nil : 'accepted') # (taxon_name.unavailable_or_invalid? ? nil : 'accepted')
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

  # @param used_on [String] required, one of `AssertedDistribution`, `Content`, `BiologicalAssociation`, `TaxonDetermination`
  # @return [Scope]
  #   the max 10 most recently used otus, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '')
    t = case used_on
        when 'AssertedDistribution'
          AssertedDistribution.arel_table
        when 'Content'
          Content.arel_table
        when 'BiologicalAssociation'
          BiologicalAssociation.arel_table
        when 'TaxonDetermination'
          TaxonDetermination.arel_table
        else
          return Otu.none
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
              .where(t['created_by_id'].eq(user_id))
              .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        else
          t.project(t['otu_id'], t['updated_at']).from(t)
            .where(t['updated_at'].gt( 1.weeks.ago ))
              .where(t['created_by_id'].eq(user_id))
              .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        end

    z = i.as('recent_t')

    case used_on
        when 'BiologicalAssociation'
          j = Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z['biological_association_object_id'].eq(p['id'])
          ))
        else
          j = Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['otu_id'].eq(p['id'])))
        end

    Otu.joins(j).pluck(:id).uniq
  end

  # @params target [String] required, one of nil, `AssertedDistribution`, `Content`, `BiologicalAssociation`, 'TaxonDetermination'
  # @return [Hash] otus optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: Otu.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if target && !r.empty?
      h[:recent] = (Otu.where('"otus"."id" IN (?)', r.first(10) ).to_a +
          Otu.where(project_id: project_id, created_by_id: user_id, created_at: 3.hours.ago..Time.now)
              .order('updated_at DESC')
              .limit(3).to_a
              ).uniq.sort{|a,b| a.otu_name <=> b.otu_name}
      h[:quick] = (Otu.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          Otu.where('"otus"."id" IN (?)', r.first(4) ).to_a).uniq.sort{|a,b| a.otu_name <=> b.otu_name}
    else
      h[:recent] = Otu.where(project_id: project_id).order('updated_at DESC').limit(10).to_a.sort{|a,b| a.otu_name <=> b.otu_name}
      h[:quick] = Otu.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id: project_id}).to_a.sort{|a,b| a.otu_name <=> b.otu_name}
    end

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
      soft_validations.add(:base, m )
    end
  end

end



