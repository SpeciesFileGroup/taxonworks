# A CachedMapItem is a summary of data from Georeferences and AssertedDistributions for mapping/visualization purposes.
#
# All data are `cached` sensu TaxonWorks, i.e. derived from underlying data elsewhere.  The intent is *not*
# to preserve the origin of the data, but rather provide a tool to summarize in (at present) a *simple* visualization.
#
## @!attribute otu_id
#   @return [Otu#id],
#     the id of OTU, required
#
# @!attribute geographic_item_id
#   @return [GeographicItem#id],
#     the id of GeographicItem, required
#
# @!attribute type
#   @return [String]
#     Rails STI
#
# @!attribute reference_count
#   @return [Integer]
#      the number of Georeferences + AssertedDistributions that
#   reference this OTU/shape combination. . . . .
#
# @!attribute untranslated
#   @return [Boolean, nil]
#     if True then the the shape could not be mapped, by any translation method, to a shape allowable
#     for this CachedMapItemType
#
# @!attribute is_absent
#   @return [Boolean, nil]
#     if True then the corresponding AssertedDistributions have is_absent true
#
# @!attribute level0_geographic_name
#   @return [String, nil]
#      the level 0 name
#
# @!attribute level1_geographic_name
#   @return [String, nil]
#      the level 1 name
#
# @!attribute level2_geographic_name
#   @return [String, nil]
#      the level 2 name. !! Not presently used. !!
#
class CachedMapItem < ApplicationRecord
  include Housekeeping::Projects
  include Housekeeping::Timestamps
  include Shared::IsData

  belongs_to :otu, inverse_of: :cached_map_items
  belongs_to :geographic_item, inverse_of: :cached_map_items

  validates_uniqueness_of :otu_id, scope: [:type, :geographic_item_id]
  validates_presence_of :otu, :geographic_item, :type

  # @return Hash
  #   {country:, state:, county: }
  #  Check to see if a record is already present rather than-recalculate spatially
  #  CONSIDER: Use Reddis store to cache these results and look them up from there.
  #
  def self.cached_map_name_hierarchy(geographic_item_id)
    h = CachedMapItem
      .select('level0_geographic_name country, level1_geographic_name state, level2_geographic_name county')
      .where('level0_geographic_name IS NOT NULL OR level1_geographic_name IS NOT NULL OR level2_geographic_name IS NOT NULL')
      .find_by(geographic_item_id:) # finds first
      &.attributes
      &.compact!

    return h.symbolize_keys if h.present?

    GeographicItem.find(geographic_item_id).quick_geographic_name_hierarchy
  end

  def self.cached_map_geographic_items_by_otu(otu_scope = nil)
    return GeographicItem.none if otu_scope.nil?

    s = 'WITH otu_scope AS (' + otu_scope.all.to_sql + ') ' +
      ::GeographicItem
      .joins('JOIN cached_maps on cached_maps.geographic_item_id = geographic_items.id')
      .joins( 'JOIN otu_scope as otu_scope1 on otu_scope1.id = cached_maps.otu_id').to_sql

    ::GeographicItem.from('(' + s + ') as geographic_items').distinct
  end

  # @return Array
  def self.types_by_data_origin(data_origin = [])
    types = []
    data_origin.each do |o|
      CachedMapItem.descendants.each do |d|
        types.push d.name if d::SOURCE_GAZETEERS.include?(o)
      end
    end

    types.uniq!
    types
  end

  # Check CachedMapItemTranslation for previous translations and use
  #   that if possible
  def self.translate_by_geographic_item_translation(geographic_item_id, cached_map_type)
    a = CachedMapItemTranslation.where(
      cached_map_type:,
      geographic_item_id:
    ).pluck(:translated_geographic_item_id)
      .uniq # Just in case we duplicate the index, hopefully not needed

    (a.presence || [])
  end

  # @return [Array]
  #   Return the geographic_item_id if it is already of the requested origin
  def self.translate_by_data_origin(geographic_item_id, data_origin)
    if ::GeographicAreasGeographicItem.where(
        geographic_item_id:,
        data_origin:
    ).any?
      return [geographic_item_id]
    else
      []
    end
  end

  # @return [Array]
  # Return the geographic_item_id if it is already used in a CachedMapItem of the right type
  #   !! Probably redundant with translate_by_data_origin !!
  def self.translate_by_cached_map_usage(geographic_item_id, cached_map_type)
    if ::CachedMapItem.where(geographic_item_id:, type: cached_map_type).any?
      return [geographic_item_id]
    else
      []
    end
  end

  def self.translate_by_alternate_shape(geographic_item_id, data_origin)
    # GeographicItem is an alternate shape to a GeographicArea that *also* has a target gazeteer type
    if a = GeographicItem.find(geographic_item_id)
      .geographic_areas
      .joins(:geographic_items)
      .where(geographic_areas: { data_origin: })
      .order(cached_total_area: :ASC) # smallest first
      .first
      &.id
      return [a]
    else
      []
    end
  end

  # Given a  set of target shapes, return those that intersect with the provided shape
  #
  # @param geographic_item_id [id]
  #   the shape we are translating *from*
  #
  # @param data_origin
  #    defines the shapes we are translating to
  #
  # #param buffer [nil, Decimal] in meters
  #    shrink, (or grow) the shape we are translating from
  #    Typical use is to shrink, so that differences in spatial resolution
  #    are minimized (low res shapes intersect with high res in undesireable ways)
  #
  # @return [Array] of GeographicItem ids
  #
  def self.translate_by_spatial_overlap(geographic_item_id, data_origin, buffer)
    return [] if geographic_item_id.blank?

    # !! Assumes all GeographicArea shapes were loaded to multi_polygon
    # (pre-adapts us to a single geometry field type), however be
    # aware of this assumption

    # This is a fast first pass, pure intersection
    a = GeographicItem
      .joins(:geographic_areas_geographic_items)
      .where(geographic_areas_geographic_items: { data_origin: })
      .merge(GeographicItem.intersecting(:multi_polygon, geographic_item_id))
      .pluck(:id)

    return a if buffer.nil?

    # Refine the pass by smoothing using buffer/st_within
    return GeographicItem
      .where(id: a)
      .where(
        GeographicItem.st_buffer_st_within_sql(geographic_item_id, 0.0, buffer)
      )
      .pluck(:id)
  end

  # @return [Array]
  # @param origin_type
  #   'AssertedDistribution' or 'Georeference'
  #
  # @param data_origin Array, String
  #   like `ne_states` or ['ne_states, 'ne_countries']
  #
  # @param buffer [nil, Decimal]
  #   shr,ink (or grow) the size of the target shape, in meters
  #   Typical use, do not apply for Georeferences, apply -10km for AssertedDistributions
  #
  def self.translate_geographic_item_id(geographic_item_id, origin_type = nil, data_origin = nil, buffer = nil)
    return nil if data_origin.blank?

    cached_map_type = types_by_data_origin(data_origin)

    a = nil

    b = buffer

    # All these methods depend on "prior knowledge" (not spatial calculations)
    if origin_type == 'AssertedDistribution'
      a = translate_by_geographic_item_translation(geographic_item_id, cached_map_type)
      return a if a.present?

      a = translate_by_data_origin(geographic_item_id, data_origin)
      return a if a.present?

      a = translate_by_alternate_shape(geographic_item_id, data_origin)
      return a if a.present?

      a = translate_by_cached_map_usage(geographic_item_id, cached_map_type)
      return a if a.present?

      b = dynamic_buffer(geographic_item_id) # -1000.0 # Monaco
    end

    translate_by_spatial_overlap(geographic_item_id, data_origin, b)
  end

  def self.dynamic_buffer(geographic_item_id)
    v = GeographicItem.select(:id, :cached_total_area).find(geographic_item_id).cached_total_area
    return 0 if v.nil? || v.to_i == 0
    case Math.log10(v).to_i
    when 0..2 # 3786
      0.0
    when 3..6 # Perhaps no GeographicAreas hit here
      -100.0
    when 7 # e.g. Monaco 122
      -1000
    when 8
      -2000 # e.g. Calhoun Co. 27490
    when 9
      -4000 # 3786 Cooma-Monaro
    when 10..12
      -12000.0  # e.g. Brazil 33794; Canada 37 !! Seems to be a sweet spot, remainder untested
    else #(max is 13)
      -20000.0 # Antarctic, 10
    end
  end

  # @return [Hash, nil]
  def self.stubs(source_object, cached_map_type)
    # return nil unless source_object.persisted?
    o = source_object

    h = {
      origin_object: o,
      cached_map_type:,
      otu_id: [],
      geographic_item_id: [],
      origin_geographic_item_id: nil
    }

    geographic_item_id = nil
    name_hierarchy = nil
    otu_id = nil

    base_class_name = o.class.base_class.name

    case base_class_name
    when 'AssertedDistribution'
      geographic_item_id = o.geographic_area.default_geographic_item_id
      otu_id = [o.otu_id]
    when 'Georeference'
      geographic_item_id = o.geographic_item_id
      otu_id = o.otus.joins('LEFT JOIN taxon_determinations td on otus.id = td.otu_id').where(taxon_determinations: { position: 1 }).distinct.pluck(:id)
    end

    # Some AssertedDistribution don't have shapes
    if geographic_item_id
      h[:origin_geographic_item_id] = geographic_item_id

      h[:geographic_item_id] = translate_geographic_item_id(
        geographic_item_id,
        base_class_name,
        cached_map_type.safe_constantize::SOURCE_GAZETEERS
      )

      if h[:geographic_item_id].blank?
        h[:geographic_item_id] = [geographic_item_id]
        h[:untranslated] = true
      end
    end

    h[:otu_id] = otu_id
    h
  end


  # Create breadth-first CachedMapItems
  #   Only applicable to Georeferences.
  #
  # @params batch_stubs [Hash]
  # {
  #  map_type: ,
  #  geographic_item_id: []
  #  otu_id: [ [otu_id, :project_id], ... [] ],
  #  georeference_id: [ [geoference_id, :project_id] ],
  # }
  #
  #
  def self.batch_create_georeference_cached_map_items(batch_stubs)
    map_type = batch_stubs[:map_type]
    j = batch_stubs[:geographic_item_id]
    k = batch_stubs[:otu_id]

    j.each do |geographic_item_id|
      k.each do |otu_id|
        otu_id = otu_id.first
        project_id = otu_id.second

        begin
          a = CachedMapItem.find_or_initialize_by(
            type: map_type,
            otu_id:,
            geographic_item_id:,
            project_id:,
          )

          if a.persisted?
            a.increment!(:reference_count)
          else
            a.reference_count = 1
            a.save!
          end

        rescue ActiveRecord::RecordInvalid => e
          logger.debug e
        rescue PG::UniqueViolation
          logger.debug 'pg unique violation'
        end
      end
    end

    # Register the Georeferences
    registrations = []

    batch_stubs[:georeference_id].each do |georeference_id, project_id|
      registrations.push({
        cached_map_register_object_type: 'Georeference',
        cached_map_register_object_id: georeference_id,
        project_id:,
        created_at: Time.current,
        updated_at: Time.current,
      })
    end

    begin
      CachedMapRegister.insert_all(registrations) if registrations.present?
    rescue
      puts '!! Failed to register Georeferences in batch_create_georeference_cached_map_items.'
    end

    true
  end

end
