class DataMigrateSyncronizePolygonWinding < ActiveRecord::Migration[6.1]
  def change

    # Executes in 38.5601s on production data in development
    
    ApplicationRecord.connection.execute(
      "UPDATE geographic_items set multi_polygon = ST_ForcePolygonCCW(multi_polygon::geometry) WHERE multi_polygon IS NOT NULl;"
    )

   ApplicationRecord.connection.execute(
      "UPDATE geographic_items set polygon = ST_ForcePolygonCCW(polygon::geometry) WHERE polygon IS NOT NULl;"
    )

  end
end
