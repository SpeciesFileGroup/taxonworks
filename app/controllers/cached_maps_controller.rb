class CachedMapsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def index
  end

  def png

    if ids = Otu.joins(:cached_map_items).first.cached_map_items.pluck(:geographic_item_id)

      sql = "SELECT ST_AsPNG(
        ST_AsRaster(
            ST_Buffer( multi_polygon::geometry, 0, 'join=bevel'),
                1024,
                768)
         ) png
    from geographic_items where id IN (" + ids.join(',') + ');'

    # hack, not the best way to unpack result
    result = ActiveRecord::Base.connection.execute(sql).first['png']
    r = ActiveRecord::Base.connection.unescape_bytea(result)

    send_data r, filename: 'foo.png', type: 'imnage/png'

   else
     render json: {foo: false}
    end
  end

  def geo_json

    a = 191974 # CachedMap.firs.otu_id

    sql = "SELECT ST_AsGeoJSON(ST_Union(geom_array)) AS geojson
    FROM (
      SELECT ARRAY(
        SELECT #{GeographicItem::GEOMETRY_SQL.to_sql}
        FROM geographic_items
        JOIN cached_map_items cm on cm.geographic_item_id = geographic_items.id
        WHERE cm.otu_id = #{a}
      ) AS geom_array
    ) AS subquery;"

    result = ActiveRecord::Base.connection.execute(sql) # .first['geo_json']

    render json: result[0]['geojson']
  end



end
