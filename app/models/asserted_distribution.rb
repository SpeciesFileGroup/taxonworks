# An AssertedDistribution is the Source-backed assertion that a record (e.g. Otu, BiologicalAssociation, etc.) is present in some *spatial area*. It requires a Citation indicating where/who made the assertion.
# In TaxonWorks the areas are drawn from GeographicAreas and Gazetteers.
#
# AssertedDistributions can be asserts that the source indicates that a taxon is NOT present in an area.  This is a "positive negative" in , i.e. the Source can be thought of recording evidence that a taxon is not present. TaxonWorks does not differentiate between types of negative evidence.
#
# @!attribute asserted_distribution_object_type
#   @return [String]
#   polymorphic object type
#
# @!attribute asserted_distribution_object_id
#   @return [Integer]
#   polymorphic object ID
#
# @!attribute asserted_distribution_shape_type
#   @return [String]
#   polymorphic spatial shape type
#
# @!attribute asserted_distribution_shape_id
#   @return [Integer]
#   polymorphic spatial shape ID
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute is_absent
#   @return [Boolean]
#     a positive negative, when true then there exists an assertion that the taxon is not present in the spatial area
#
class AssertedDistribution < ApplicationRecord
  include Housekeeping
  include SoftValidation
  include Shared::Notes
  include Shared::Tags
  include Shared::DataAttributes # Why?
  include Shared::CitationRequired # !! must preceed Shared::Citations
  include Shared::Citations
  include Shared::Confidences
  include Shared::OriginRelationship
  include Shared::Identifiers
  include Shared::HasPapertrail
  include Shared::Taxonomy # at present must preceed DwcExtensions

  include AssertedDistribution::DwcExtensions
  include Shared::IsData

  include Shared::Maps
  include Shared::QueryBatchUpdate
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('asserted_distribution_shape')
  polymorphic_annotates('asserted_distribution_object')

  originates_from 'Specimen', 'Lot', 'FieldOccurrence'

  # @return [Hash]
  #   of known country/state/county values
  attr_accessor :geographic_names

  delegate :geo_object, to: :asserted_distribution_shape

  # This only asserts when the asserted distribution object is polymorphic and
  # has a restriction on its type in order to be an AD.
  ASSERTED_DISTRIBUTION_OBJECT_RELATED_TYPES = {
    conveyance: ['Otu'],
    depiction: ['Otu'],
    observation: ['Otu']
  }.freeze

  # TODO use asserted_distribution_object unless you really need these
  #belongs_to :biological_association, class_name: :BiologicalAssociation, foreign_key: :asserted_distribution_object_id, inverse_of: :asserted_distributions
  #has_one :taxon_name, through: :otu

  before_validation :unify_is_absent
  before_save do
    # TODO: handle non-otu types.
    self.no_dwc_occurrence = asserted_distribution_object_type != 'Otu'
  end

  validate :new_records_include_citation
  validate :object_shape_absence_triple_is_unique

  validate :asserted_distribution_object_has_allowed_type

  # TODO: deprecate scopes referencing single parameter where()
  scope :with_is_absent, -> { where('is_absent = true') }
  scope :with_geographic_area_array, -> (geographic_area_array) { where("asserted_distribution_shape_type = 'GeographicArea' AND asserted_distribution_shape_id IN (?)", geographic_area_array) }
  scope :without_is_absent, -> { where('is_absent = false OR is_absent is Null') }
  # Includes a `geographic_item_id` column.
  scope :associated_with_geographic_items, -> {
    a = AssertedDistribution
      .where(asserted_distribution_shape_type: 'GeographicArea')
      .joins('JOIN geographic_areas ON asserted_distribution_shape_id = geographic_areas.id')
      .joins('JOIN geographic_areas_geographic_items on geographic_areas.id = geographic_areas_geographic_items.geographic_area_id')
      .joins('JOIN geographic_items on geographic_items.id = geographic_areas_geographic_items.geographic_item_id')
      .select('asserted_distributions.*, geographic_items.id geographic_item_id')

    b = AssertedDistribution
      .where(asserted_distribution_shape_type: 'Gazetteer')
      .joins('JOIN gazetteers ON asserted_distribution_shape_id = gazetteers.id')
      .joins('JOIN geographic_items on gazetteers.geographic_item_id = geographic_items.id')
      .select('asserted_distributions.*, geographic_items.id geographic_item_id')

    ::Queries.union(AssertedDistribution, [a, b])
  }
  scope :with_otus, -> {
    joins("JOIN otus ON otus.id = asserted_distributions.asserted_distribution_object_id AND asserted_distributions.asserted_distribution_object_type = 'Otu'")
  }

  # TODO: revive as needed
  #accepts_nested_attributes_for :otu, allow_destroy: false, reject_if: proc { |attributes| attributes['name'].blank? && attributes['taxon_name_id'].blank? }

  soft_validate(:sv_conflicting_geographic_area, set: :conflicting_geographic_area, name: 'conflicting geographic area', description: 'conflicting geographic area')

  # getter for attr :geographic_names
  def geographic_names
    return @geographic_names if !@geographic_names.nil?
    # TODO: Possibly provide a2/a3 info from gazetteers??
    @geographic_names ||=
      asserted_distribution_shape.geographic_name_classification
        .delete_if{|k,v| v.nil?}
    @geographic_names ||= {}
  end

  # rubocop:disable Style/StringHashKeys
  # TODO: DRY with helper methods
  # @return [Hash] GeoJSON feature
  def to_geo_json_feature
    retval = {
      'type' => 'Feature',
      'geometry' => RGeo::GeoJSON.encode(geo_object),
      'properties' => {'asserted_distribution' => {'id' => self.id}}
    }
    retval
  end

  # rubocop:enable Style/StringHashKeys

  # @return [True]
  #   see citable.rb
  def requires_citation?
    true
  end

  def geographic_item
    asserted_distribution_shape.default_geographic_item
  end

  def otu
    return nil if asserted_distribution_object_type != 'Otu'

    asserted_distribution_object
  end

  def has_shape?
    asserted_distribution_shape.geographic_items.any?
  end

  def self.batch_update(params)
    request = QueryBatchRequest.new(
      async_cutoff: params[:async_cutoff] || 26,
      klass: 'AssertedDistribution',
      object_filter_params: params[:asserted_distribution_query],
      object_params: params[:asserted_distribution],
      preview: params[:preview],
    )

    a = request.filter

    v1 = a.all.distinct.limit(2)
      .pluck(:asserted_distribution_shape_id, :asserted_distribution_shape_type)
      .uniq.count
    v2 = a.all.distinct.limit(2).pluck(:asserted_distribution_object_id).uniq.count

    cap = 0

    if v1 > 1 && v2 > 1 # many objects, many geographic areas
      cap = 0
      request.cap_reason = 'Records include multiple asserted distribution objects *and* multiple asserted distribution shapes.'
    elsif v1 > 1
      cap = 0
      request.cap_reason = 'May not update multiple shapes to one.' # TODO: revist constraint
    else
      cap = 2000
    end

    request.cap = cap

    query_batch_update(request)
  end

  def self.batch_template_create(params)
    async_cutoff = params[:async_cutoff] || 26
    klass = params[:object_type]
    a = "Queries::#{klass}::Filter".constantize.new(params[:object_query])

    r = BatchResponse.new({
      async: a.all.count > async_cutoff,
      preview: params[:preview],
      total_attempted: a.all.count,
      method: 'batch_template_create'
    })

    max_allowed = 250
    if r.total_attempted > max_allowed
      r.errors["Max #{max_allowed} query records allowed"] = 1
      return r
    end

    return r if r.async && r.preview

    if r.async
      object_ids = a.all.pluck(:id)
      user_id = params[:user_id]
      project_id = params[:project_id]
      AssertedDistribution
        .delay(run_at: 1.second.from_now, queue: :query_batch_update)
        .batch_create_from_params(
          params[:template_asserted_distribution], object_ids, klass,
          user_id, project_id
        )
    else
      self.transaction do
        template_params = params[:template_asserted_distribution]
        a.all.select(:id).find_each do |o|
          begin
            ad = update_or_create_by_template(template_params, o.id, klass)
            r.updated.push ad.id
          rescue ActiveRecord::RecordInvalid => e
            r.not_updated.push e.record.id

            r.errors[e.message] = 0 unless r.errors[e.message]

            r.errors[e.message] += 1
          end
        end
        raise ActiveRecord::Rollback if r.preview
      end
    end

    r
  end

  # Intended to be run in a background job.
  def self.batch_create_from_params(
    params, object_ids, object_type, user_id, project_id
  )
    Current.user_id = user_id
    Current.project_id = project_id

    object_ids.each do |object_id|
      begin
        update_or_create_by_template(params, object_id, object_type)
      rescue ActiveRecord::RecordInvalid => e
        # Just continue
      end
    end
  end

  # Raises on error.
  def self.update_or_create_by_template(template_params, object_id, object_type)
    ad = ::AssertedDistribution.find_by(
      asserted_distribution_object_id: object_id,
      asserted_distribution_object_type: object_type,
      asserted_distribution_shape_id:
        template_params[:asserted_distribution_shape_id],
      asserted_distribution_shape_type:
        template_params[:asserted_distribution_shape_type],
      is_absent: template_params[:is_absent]
    )

    if ad
      # Create/add the citation.
      # TODO: this can create a duplicate citation.
      ad.update!(template_params)
    else
      ad = ::AssertedDistribution.create!(
        template_params.merge({
          asserted_distribution_object_id: object_id,
          asserted_distribution_object_type: object_type
        })
      )
    end

    ad
  end

  def self.asserted_distributions_for_api_index(params, project_id)
    a = ::Queries::AssertedDistribution::Filter.new(params)
      .all
      .where(project_id: project_id)
      .includes(:citations, origin_citation: [:source])
      .includes(asserted_distribution_shape: :parent)
      .includes(:asserted_distribution_object)
      .order('asserted_distributions.id')
      .page(params[:page])
      .per(params[:per])

    if a.all.count > 50
      params['extend']&.delete('geo_json')
    end

    a
  end

  protected

  # Never record "false" in the datase, only true
  def unify_is_absent
    self.is_absent = nil if self.is_absent != true
  end

  # @return [Boolean]
  def new_records_include_citation
    if new_record? && source.blank? && origin_citation.blank? && !citations.any?
      errors.add(:base, 'required citation is not provided')
    end
  end

  # @return [Boolean]
  def sv_conflicting_geographic_area
    # TODO: more expensive for gazetteers, which would require a spatial check.
    geographic_area = asserted_distribution_shape if asserted_distribution_shape_type == 'GeographicArea'
    return if geographic_area.nil?

    areas = [geographic_area.level0_id, geographic_area.level1_id, geographic_area.level2_id].compact
    if is_absent # this returns an array, not a single GA so test below is not right
      presence = AssertedDistribution
        .without_is_absent
        .with_geographic_area_array(areas)
        .where(asserted_distribution_object:)
      soft_validations.add(:geographic_area_id, "Taxon is reported as present in #{presence.first.asserted_distribution_shape.name}") unless presence.empty?
    else
      presence = AssertedDistribution
        .with_is_absent
        .where(asserted_distribution_object:)
        .with_geographic_area_array(areas)
      soft_validations.add(:geographic_area_id, "Taxon is reported as missing in #{presence.first.asserted_distribution_shape.name}") unless presence.empty?
    end
  end

  # DEPRECATED, unused (maybe)
  # @param [Hash] defaults
  # @return [AssertedDistribution]
  #   used to also stub an #origin_citation, as required
  def self.stub(defaults: {})
    a = AssertedDistribution.new(
      asserted_distribution_object_id:
        defaults[:asserted_distribution_object_id],
      asserted_distribution_object_type:
        defaults[:asserted_distribution_object_type],
      origin_citation_attributes: {source_id: defaults[:source_id]})
    a.origin_citation = Citation.new if defaults[:source_id].blank?
    a
  end

  # Currently only used in specs
  # @param [Hash] options of e.g., {asserted_distribution_object_id: 5, asserted_distribution_object_type: 'Otu' source_id: 5, geographic_areas: Array of {GeographicArea}}
  # @return [Array] an array of AssertedDistributions
  def self.stub_new(options = {})
    options.symbolize_keys!
    result = []
    options[:geographic_areas].each do |ga|
      result.push(
        AssertedDistribution.new(
          asserted_distribution_object_id: options[:otu_id],
          asserted_distribution_object_type: 'Otu',
          asserted_distribution_shape: ga,
          origin_citation_attributes: {source_id: options[:source_id]})
      )
    end
    result
  end

  def object_shape_absence_triple_is_unique
    if AssertedDistribution
        .where(
          asserted_distribution_object_type:, asserted_distribution_object_id:,
          asserted_distribution_shape_type:, asserted_distribution_shape_id:,
          is_absent:
        )
        .where.not(id:)
        .exists?

      errors.add(:base,
        'this shape, object, and present/absent combination already exists'
      )
    end
  end

  def asserted_distribution_object_has_allowed_type
    t = asserted_distribution_object_type
    if (
      (a = ASSERTED_DISTRIBUTION_OBJECT_RELATED_TYPES[t]) &&
      !a.include?(asserted_distribution_object&.send("#{t}_object_type"))
    )
     errors.add(t,
       "object type for an asserted distribution can only be in #{a}")
    end
  end
end
