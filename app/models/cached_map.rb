# A CachedMap is a OTU specific map derived from AssertedDistribution and Georeference data via
# aggregation of the intermediate CachedMapItem level.
#
class CachedMap < ApplicationRecord
  include Housekeeping::Projects
  include Housekeeping::Timestamps
  include Shared::IsData

  # @param GeoJSON in string form
  attr_writer :geo_json_string

  # @return Boolean, nil
  attr_accessor :force_rebuild

  before_validation :rebuild, if: :force_rebuild, on: [ :update ]

  # TODO:
  # Current production strategy is to present "out of date" when
  # visualizing a CacheMap, then do complete rebuilds.
  #
  # This strategy can change when if/when
  # we manage to get a comprehensive number of hooks into models
  # such that state can be maintained.
  #
  # Since all hooks are syncronized through a change in a CachedMapItem
  # we can trigger syncronizations that Update CachedMaps with callback hooks here, in theory.

  def rebuild
    if !synced?
      self.geo_json_string = CachedMap.calculate_union(otu, cached_map_type: )
    end
  end

  belongs_to :otu, inverse_of: :cached_maps

  # All cached_map items used to compose this cached_map.
  def cached_map_items
    CachedMapItem.where(type: cached_map_type, otu: otu_scope)
  end

  validates_presence_of :otu
  validates_presence_of :geometry
  validates_presence_of :reference_count

  def geo_json_string=(value)
    # Would be nice to write as string and convert in a hook after save so that
    # we don't have to decode Ruby side.
    # self.foo = "ST_GeomFromGeoJSON('#{value}')"
    self.geometry = RGeo::GeoJSON.decode(value, json_parser: :json)
  end

  def synced?
    cached_map_items_reference_total == reference_count && latest_cached_map_item.created_at <= created_at
  end

  def latest_cached_map_item
    cached_map_items.order(:updated_at).first
  end

  def cached_map_items_reference_total
    CachedMapItem.where(otu: otu_scope).sum(:reference_count)
  end

  def otu_scope
    if otu.taxon_name
      Otu.descendant_of_taxon_name(otu.taxon_name_id)
    else
      Otu.coordinate_otus(otu.id)
    end
  end

  def geo_json_to_s
    if respond_to?(:geo_json) # loaded as string in query
      geo_json
    else
      CachedMap.select('ST_AsGeoJSON(geometry) geo_json').find(id).geo_json
    end
  end

  def self.calculate_union(otu_scope, cached_map_type = 'CachedMapItem::WebLevel1')
    i = ::GeographicItem.select("#{GeographicItem::GEOMETRY_SQL.to_sql}")
      .joins('JOIN cached_map_items cmi on cmi.geographic_item_id = geographic_items.id')
      .joins('JOIN otu_scope AS otu_scope1 on otu_scope1.id = cmi.otu_id')
      .where('cmi.untranslated IS NULL OR cmi.untranslated <> true')
      .distinct

    s = "WITH otu_scope AS (#{otu_scope.to_sql}) " + i.to_sql

    # TODO: with untranslated handled we probable don't need Homogenize?
    # TODO: explore simplification optimization
    #   - 0.01 drops the number of points by > 5x

    sql = "SELECT
             ST_AsGeoJSON(
              ST_SimplifyPreserveTopology(
                 ST_CollectionHomogenize (
                   ST_CollectionExtract(
                     ST_Union(geom_array)
                   )
                 ),
                 0.01
               )
            ) AS geojson
          FROM (
            SELECT ARRAY(
              #{s}
            ) AS geom_array
          ) AS subquery;"


    begin
      r = ActiveRecord::Base.connection.execute(sql)
    rescue ActiveRecord::StatementInvalid => e
      if e.message.include?("GEOSUnaryUnion")
        return nil 
      else
        raise
      end
    end
    r[0]['geojson']
  end

end
