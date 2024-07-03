require 'support/vendor/rspec_geo_helpers'

RSPEC_GEO_FACTORY = Gis::FACTORY

shared_context 'stuff for geography tests' do

  ###### Simple shapes - no intended relation to each other
  let(:simple_shapes) { {
    point: 'POINT(10 -10 0)',
    line_string: 'LINESTRING(0.0 0.0 0.0, 10.0 0.0 0.0)',
    polygon:'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))',
    multi_point: 'MULTIPOINT((10.0 10.0 0.0), (20.0 20.0 0.0))',
    multi_line_string: 'MULTILINESTRING((0.0 0.0 0.0, 10.0 0.0 0.0), (20.0 0.0 0.0, 30.0 0.0 0.0))',
    multi_polygon: 'MULTIPOLYGON(((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, ' \
    '0.0 0.0 0.0)),((10.0 10.0 0.0, 20.0 10.0 0.0, 20.0 20.0 0.0, 10.0 20.0 0.0, 10.0 10.0 0.0)))',
    geometry_collection: 'GEOMETRYCOLLECTION( POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, ' \
    '0.0 10.0 0.0, 0.0 0.0 0.0)), POINT(10 10 0)) ',
    geography:'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))'
  }.freeze }

  let(:simple_point) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:point])
  }

  let(:simple_line_string) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:line_string])
  }

  let(:simple_polygon) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:polygon])
  }

  let(:simple_multi_point) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:multi_point])
  }

  let(:simple_multi_line_string) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:multi_line_string])
  }

  let(:simple_multi_polygon) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:multi_polygon]
    )
  }

  let(:simple_geometry_collection) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:geometry_collection]
    )
  }

  let(:simple_rgeo_point) { RSPEC_GEO_FACTORY.point(10, -10, 0) }

  ###### Specific shapes testing relations between shapes

  ### Point intended to be outside of any of the shapes defined below
  let(:distant_point) {
    FactoryBot.create(:geographic_item_geography, geography: 'POINT(1000 1000 0)')
  }

  ### A donut polygon and sub-shapes
  let(:donut) do
    # Definitions below assume both interior and exterior are squares starting
    # at the lower left corner; exterior ccw, interior cw
    d = 'POLYGON((0 0 0, 20 0 0, 20 20 0, 0 20 0, 0 0 0),
                 (5 5 0, 15 5 0, 15 15 0, 5 15 0, 5 5 0))'

    FactoryBot.create(:geographic_item_geography, geography: d)
  end

  let(:donut_hole_point) {
    FactoryBot.create(:geographic_item_geography, geography: donut.centroid)
  }

  let (:donut_interior_point) do
    # Both corners are lower left
    exterior_ring_corner = donut.geo_object.exterior_ring.start_point
    interior_ring_corner = donut.geo_object.interior_rings.first.start_point
    interior_x = (interior_ring_corner.x - exterior_ring_corner.x) / 2
    interior_y = (interior_ring_corner.y - exterior_ring_corner.y) / 2

    FactoryBot.create(:geographic_item_point,
      point: "POINT(#{interior_x} #{interior_y} 0)")
  end

  let (:donut_left_interior_edge_point) {
    # lower left corner of interior ring
    interior_llc = donut.geo_object.interior_rings.first.start_point
    # upper left corner of interior ring
    interior_ulc = donut.geo_object.interior_rings.first.points.fourth
    x = interior_llc.x
    y = interior_llc.y + (interior_ulc.y - interior_llc.y) / 2

    FactoryBot.create(:geographic_item_geography,
      geography: "POINT(#{x} #{y} 0)")
  }

  let (:donut_left_interior_edge) {
    start_point = donut.geo_object.interior_rings.first.points.first
    end_point = donut.geo_object.interior_rings.first.points.fourth

    FactoryBot.create(:geographic_item_geography,
      geography: RSPEC_GEO_FACTORY.line_string([start_point, end_point]))
  }

  # A multi_line_string
  let (:donut_bottom_and_left_interior_edges) {
    # lower left corner
    llc = donut.geo_object.interior_rings.first.points.first
    # lower right corner
    lrc = donut.geo_object.interior_rings.first.points.second
    #upper left corner
    ulc = donut.geo_object.interior_rings.first.points.fourth
    lower_edge = RSPEC_GEO_FACTORY.line_string([llc, lrc])
    left_edge = RSPEC_GEO_FACTORY.line_string([ulc, llc])

    FactoryBot.create(:geographic_item_geography,
      geography: RSPEC_GEO_FACTORY.multi_line_string([left_edge, lower_edge]))
  }

  ### A box polygon and sub-shapes
  let(:box) do
    b = 'POLYGON((40 0 0, 60 0 0, 60 20 0, 40 20 0, 40 0 0))'

    FactoryBot.create(:geographic_item_geography, geography: b)
  end

  let(:box_centroid) {
    FactoryBot.create(:geographic_item_geography, geography: box.centroid)
  }

  let(:box_horizontal_bisect_line) {
    points = box.geo_object.exterior_ring.points
    left_x = points.first.x
    right_x = points.second.x
    y = points.first.y + (points.fourth.y - points.first.y) / 2
    line = "LINESTRING (#{left_x} #{y} 0, #{right_x} #{y} 0)"
    FactoryBot.create(:geographic_item_geography, geography: line)
  }

  ### A rectangle polygon intersecting the previous box; both start at y=0,
  # the rectangle is taller than box_centroid but shorter than box;
  # box_centroid is in the left side of rectangle
  let(:rectangle_intersecting_box) do
    b = 'POLYGON((50 0 0, 70 0 0, 70 15 0, 50 15 0, 50 0 0))'

    FactoryBot.create(:geographic_item_geography, geography: b)
  end

  ### A point in the interior of the intersection of box and rectangle
  let(:box_rectangle_intersection_point) {
    FactoryBot.create(:geographic_item_geography, geography: 'POINT (55 5 0)')
  }

  ### The union of the box and rectangle polygons as a single polygon
  let(:box_rectangle_union) {
    FactoryBot.create(:geographic_item_geography,
      geography: box.geo_object.union(rectangle_intersecting_box.geo_object)
  )}

  ###### Multi-shapes
  ### A multi_point
  let(:donut_box_multi_point) do
    donut_point = donut_interior_point.geo_object
    box_point = box_centroid
    m_p = RSPEC_GEO_FACTORY.multi_point([donut_point, box_point])

    FactoryBot.create(:geographic_item_geography, geography: m_p)
  end

  ### A mult_line_string
  # :donut_bottom_and_left_interior_edges is a multi_line_string

  ### A multi_polygon
  let(:donut_rectangle_multi_polygon) do
    m_poly = RSPEC_GEO_FACTORY.multi_polygon(
      [donut.geo_object, rectangle_intersecting_box.geo_object]
    )

    FactoryBot.create(:geographic_item_geography, geography: m_poly)
  end

  ### A geometry_collection
  let(:donut_and_rectangle_geometry_collection) do
    g_c = RSPEC_GEO_FACTORY.collection(
      [
        donut.geo_object,
        rectangle_intersecting_box.geo_object
      ]
    )

    FactoryBot.create(:geographic_item_geography, geography: g_c)
  end

  # Same as :donut_and_rectangle_geometry_collection but including a line
  # intersecting the interior of rectangle (adding a point in the interior of
  # rectangle seems fine) - st_cover fails with this collection as its first
  # argument.
  let(:fail_multi_dimen_geometry_collection) do
    g_c = RSPEC_GEO_FACTORY.collection(
      [
        donut.geo_object,
        rectangle_intersecting_box.geo_object,
        box_horizontal_bisect_line.geo_object
      ]
    )

    FactoryBot.create(:geographic_item_geography, geography: g_c)
  end
end