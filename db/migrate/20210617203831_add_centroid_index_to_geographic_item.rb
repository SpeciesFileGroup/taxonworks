class AddCentroidIndexToGeographicItem < ActiveRecord::Migration[6.0]
  def change
    execute 'CREATE INDEX idx_centroid on geographic_items USING GIST(ST_Centroid(CASE "geographic_items"."type" WHEN \'GeographicItem::MultiPolygon\' THEN CAST("geographic_items"."multi_polygon" AS geometry) WHEN \'GeographicItem::Point\' THEN CAST("geographic_items"."point" AS geometry) WHEN \'GeographicItem::LineString\' THEN CAST("geographic_items"."line_string" AS geometry) WHEN \'GeographicItem::Polygon\' THEN CAST("geographic_items"."polygon" AS geometry) WHEN \'GeographicItem::MultiLineString\' THEN CAST("geographic_items"."multi_line_string" AS geometry) WHEN \'GeographicItem::MultiPoint\' THEN CAST("geographic_items"."multi_point" AS geometry) WHEN \'GeographicItem::GeometryCollection\' THEN CAST("geographic_items"."geometry_collection" AS geometry) END));'
  end
end
