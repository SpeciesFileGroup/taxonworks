class CopyGicolumnsToGeographyColumn < ActiveRecord::Migration[7.1]
  def change

    ApplicationRecord.connection.execute(
      "UPDATE geographic_items SET geography=(
        CASE geographic_items.type
          WHEN 'GeographicItem::MultiPolygon' THEN multi_polygon
          WHEN 'GeographicItem::Point' THEN point
          WHEN 'GeographicItem::LineString' THEN line_string
          WHEN 'GeographicItem::Polygon' THEN polygon
          WHEN 'GeographicItem::MultiLineString' THEN multi_line_string
          WHEN 'GeographicItem::MultiPoint' THEN multi_point
          WHEN 'GeographicItem::GeometryCollection' THEN geometry_collection
        END
      ) WHERE geography IS NULL;"
    )

  end
end
