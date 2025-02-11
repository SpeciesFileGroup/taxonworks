module Otu::Maps

  extend ActiveSupport::Concern

  included do
    has_many :cached_maps, dependent: :destroy, inverse_of: :otu
    has_many :cached_map_items, dependent: :destroy, inverse_of: :otu
  end

  # TODO: If:
  #   *All* children have OTUs, and all children have maps, combine those maps
  #       Should, in theory, speed-up higher level maps
  #
  def create_cached_map(cached_map_type = 'CachedMapItem::WebLevel1', force = false)
    if force
      cached_map = cached_maps.where(cached_map_type:)
      cached_map&.destroy_all
    end

    # All the OTUs feeding into this map.
    otu_scope = nil

    if self.taxon_name_id.present?
      otu_scope = Otu.select(:id).descendant_of_taxon_name(taxon_name_id)
    else
      otu_scope = Otu.select(:id).where(id:)
    end

    if gj = CachedMap.calculate_union(otu_scope, cached_map_type:)
      map = CachedMap.create!(
        otu: self,
        geo_json_string: gj, # Geometry conversion here
        cached_map_type:,
        reference_count: CachedMapItem.where(otu: otu_scope, type: cached_map_type).sum(:reference_count)
      )

      map
    else
      nil
    end
  end

  # @return CachedMap
  #   !! Geometry is included in these objects
  # If the CachedMap is not yet built it is built here.
  def cached_map(cached_map_type = 'CachedMapItem::WebLevel1')
    m = cached_maps.where(cached_map_type:).first
    m ||= create_cached_map(cached_map_type)
    m
  end

  # @return [id, nil]
  #   return only the id if availble (avoids loading geometry)
  def cached_map_id(cached_map_type = 'CachedMapItem::WebLevel1')
    cached_maps.where(cached_map_type:).select(:id).first&.id
  end

  # @return GeoJSON
  #   A hash (JSON) formated version of the geo-json
  def cached_map_geo_json(cached_map_type = 'CachedMapItem::WebLevel1')
    JSON.parse( cached_map_string(cached_map_type) )
  end

  # @return String
  #   A string representation of the geo json
  def cached_map_string(cached_map_type = 'CachedMapItem::WebLevel1')
    mid = cached_map_id # don't load the whole object

    # Takes a long time.
    mid ||= cached_map.id # need to create the object first

    CachedMap.select('ST_AsGeoJSON(geometry) geo_json').where(id: mid).first.geo_json
  end

  # Prioritize an existing version
  #   !! Always builds
  def quicker_cached_map(cached_map_type = 'CachedMapItem::WebLevel1')
    m = cached_maps.select('id, otu_id, reference_count, project_id, created_at, updated_at, cached_map_type, ST_AsGeoJSON(geometry) geo_json').where(cached_map_type:).first
    m ||= create_cached_map
    m
  end

  #  def png
  #  if ids = Otu.joins(:cached_map_items).first.cached_map_items.pluck(:geographic_item_id)

  #    sql = "SELECT ST_AsPNG(
  #      ST_AsRaster(
  #          ST_Buffer( multi_polygon::geometry, 0, 'join=bevel'),
  #              1024,
  #              768)
  #       ) png
  #  from geographic_items where id IN (" + ids.join(',') + ');'

  #  # hack, not the best way to unpack result
  #  result = ActiveRecord::Base.connection.execute(sql).first['png']
  #  r = ActiveRecord::Base.connection.unescape_bytea(result)

  #  send_data r, filename: 'foo.png', type: 'imnage/png'

  # else
  #   render json: {foo: false}
  #  end
  #end

end
