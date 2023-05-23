module Otu::Maps

  extend ActiveSupport::Concern


  included do  
    has_many :cached_maps, dependent: :destroy
    has_many :cached_map_items, dependent: :destroy
  end

  def cached_map_json(cached_map_type = 'CachedMapItem::WebLevel1', force = false)

    # Check for existing map

    if force || m = cached_maps.where(cached_map_type:).select('ST_AsGeoJSON(geometry) geo_json').first
      # !! TODO: almost certainly very dumb dec/re/encoding going on here.
      JSON.parse( m['geo_json']) #  RGeo::GeoJSON.encode(m.geometry).to_json )
    else

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

      if gj = r[0]['geojson']

        g = RGeo::GeoJSON.decode(gj, json_parser: :json)

        # TODO: check synced?

        CachedMap.create!(
          otu: self,
          geometry: g,
          cached_map_type:,
          reference_count: CachedMapItem.where(otu: c).sum(:reference_count)
        )

        return JSON.parse(r[0]['geojson'])
      else
        false
      end
      
    end

  end


end



