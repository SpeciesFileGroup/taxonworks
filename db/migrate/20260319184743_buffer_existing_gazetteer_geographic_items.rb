class BufferExistingGazetteerGeographicItems < ActiveRecord::Migration[8.1]
  def up
    # Apply a small outward buffer to all Gazetteer geographic items to fix a
    # floating-point precision bug in the original union/intersection code.
    #
    # When a Gazetteer was created from multiple GA shapes, adjacent shapes
    # encode their shared border vertices with ~1e-14° differences. GEOS must
    # compute intersections between these nearly-coincident edges to form the
    # union/intersection boundary; floating-point rounding places the result
    # slightly off, leaving a sliver where ST_CoveredBy(constituent_GA, Gaz)
    # returns false. This caused the OTU spatial filter to silently drop
    # asserted-distribution OTUs for affected GAs.
    #
    # The buffer of 1e-7° (~11 mm at the equator) absorbs the sliver and is
    # imperceptible for any biodiversity application. It is safe to apply to
    # all Gazetteer shapes regardless of how they were originally constructed.
    # See Gazetteer::COMBINE_BUFFER_DEGREES and combine_rgeo_shapes.
    execute <<~SQL
      UPDATE geographic_items gi
      SET geography = ST_Force3D(ST_Buffer(gi.geography::geometry, 1e-7))::geography
      FROM gazetteers gz
      WHERE gz.geographic_item_id = gi.id
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
