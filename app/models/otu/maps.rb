module Otu::Maps

  extend ActiveSupport::Concern


  included do  
    has_many :cached_maps, dependent: :destroy
    has_many :cached_map_items, dependent: :destroy
  end

  def create_cached_map(cached_map_type = 'CachedMapItem::WebLevel1', force = false)
    if force
      cached_map = cached_maps.where(cached_map_type:)
      cached_map&.destroy
    end

    # TODO: a,b,c is just Otu.descendant_of_taxon_name probably.

    a = ::Queries::Otu::Filter.new(taxon_name_id: taxon_name_id, descendants: true).all.select(:id).to_sql
    b = ::Queries::Otu::Filter.new(taxon_name_id: taxon_name_id).all.select(:id).to_sql

    c = Otu.from("((#{a}) UNION (#{b})) as otus").select('id')

    i = ::GeographicItem.select("#{GeographicItem::GEOMETRY_SQL.to_sql}")
      .joins('JOIN cached_map_items cmi on cmi.geographic_item_id = geographic_items.id')
      .joins('JOIN otu_scope AS otu_scope1 on otu_scope1.id = cmi.otu_id').distinct

    s = "WITH otu_scope AS (#{c.to_sql}) " + i.to_sql

    sql = "SELECT ST_AsGeoJSON(ST_Union(geom_array)) AS geojson
      FROM (
        SELECT ARRAY(
          #{s}
        ) AS geom_array
      ) AS subquery;"

    r = ActiveRecord::Base.connection.execute(sql)

    # TODO: maybe we don't have to decode before write
    gj = r[0]['geojson']
    g = RGeo::GeoJSON.decode(gj, json_parser: :json)

    map = CachedMap.create!(
      otu: self,
      geometry: g,
      cached_map_type:,
      reference_count: CachedMapItem.where(otu: c).sum(:reference_count)
    )

    map
  end

  # @return CachedMap
  def cached_map(cached_map_type = 'CachedMapItem::WebLevel1')
    m = cached_maps.where(cached_map_type:).first
    m ||= create_cached_map 
    m
  end

  # @return [id, nil]
  #   return only the id if availble (avoids loading geometry)
  def cached_map_id(cached_map_type = 'CachedMapItem::WebLevel1')
    cached_maps.where(cached_map_type:).select(:id).first&.id
  end

  # @return GeoJSON
  #   A hash (JSON) formmated version of the geo-json
  def cached_map_geo_json(cached_map_type = 'CachedMapItem::WebLevel1')
    JSON.parse( cached_map_string(cached_map_type) )
  end

  # @return String
  #   A string representation of the geo json
  def cached_map_string(cached_map_type = 'CachedMapItem::WebLevel1')
    mid = cached_map_id # don't load the whole object
    mid ||= cached_map.id # cneed to create the object first

    CachedMap.select('ST_AsGeoJSON(geometry) geo_json').where(id: mid).first.geo_json
  end

end

