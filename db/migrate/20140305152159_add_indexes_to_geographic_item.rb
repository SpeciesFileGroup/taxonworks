class AddIndexesToGeographicItem < ActiveRecord::Migration
  def change

    GeographicItem.connection.execute('CREATE INDEX point_gix ON geographic_items USING GIST (point);')
    GeographicItem.connection.execute('CREATE INDEX line_string_gix ON geographic_items USING GIST (line_string);')
    # TODO: Fix this properly
    #GeographicItem.connection.execute('CREATE INDEX polygon_gix ON geographic_items USING GIST (polygon);')
    GeographicItem.connection.execute('CREATE INDEX multi_point_gix ON geographic_items USING GIST (multi_point);')
    GeographicItem.connection.execute('CREATE INDEX multi_line_string_gix ON geographic_items USING GIST (multi_line_string);')
    GeographicItem.connection.execute('CREATE INDEX multi_polygon_gix ON geographic_items USING GIST (multi_polygon);')
    GeographicItem.connection.execute('CREATE INDEX geometry_collection_gix ON geographic_items USING GIST (geometry_collection);')

  end
end
