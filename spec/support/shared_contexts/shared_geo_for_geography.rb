require 'support/vendor/rspec_geo_helpers'

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
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:point]
    )
  }

  let(:simple_line_string) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:line_string]
    )
  }

  let(:simple_polygon) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:polygon]
    )
  }

  let(:simple_multi_point) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:multi_point]
    )
  }

  let(:simple_multi_line_string) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:multi_line_string]
    )
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

  ###### Specific shapes for testing relations between shapes
  #
  #    donut              box                    distant_point
  #  ---------         ---------                       #
  #  |       |         |       |
  #  | &---- |         |   %%%%%%%%%
  #  | &   | |         |   %   |   %
  #  | # # | |         &&&&#&&&&   %
  #  | &   | |         |   %   |   %  rectangle_intersecting_box
  #  | &&&&& |         |   % # |   %
  #  |#      |         |   %   |   %
  #  ---------         ----%%%%%%%%%
  #
  #  # = point, & = line
  #
  #  Donut shapes: donut, donut_left_interior_edge, donut_bottom_interior_edge
  #    donut_interior_bottom_left_multi_line,
  #    donut_centroid, donut_left_interior_edge_point, donut_interior_point
  #
  #  Box shapes: box, box_horizontal_bisect_line, box_centroid
  #
  #  Rectangle shapes: rectangle_intersecting_box,
  #    box_rectangle_intersection_point
  #
  #  box_rectangle_union is what it says as a single polygon
  #
  #  !! Note that multi-shapes instantiate their constituent shapes
  #  MultiPoint: donut_box_multi_point (donut_interior_point, box_centroid)
  #  MultiLine: donut_interior_bottom_left_multi_line
  #  MultiPolygon: donut_rectangle_multi_polygon
  #  GeometryCollection: donut_box_bisector_rectangle_geometry_collection
  #    (donut, box_horizontal_bisect_line, rectangle_intersecting_box)

  ### Point intended to be outside of any of the shapes defined below
  let(:distant_point) {
    FactoryBot.create(:geographic_item_geography, geography: 'POINT(80 170 0)')
  }

  ### A donut polygon and sub-shapes
  # donut = POLYGON((0 0 0, 20 0 0, 20 20 0, 0 20 0, 0 0 0),
  #                 (5 5 0, 15 5 0, 15 15 0, 5 15 0, 5 5 0))
  # !! we describe donut outside of the definition of donut so that we can also
  # describe its subshapes without instantiating donut in doing so
  let(:d_llc_x) { 0 }
  let(:d_llc_y) { 0 }
  # width == height, but that's not necessary
  let(:d_w) { 20 } # should be divisible by 4
  let(:d_h) { 20 } # should be divisible by 4
  # width of the ring == height of the ring, but that's not necessary
  let(:d_ring_w) { 5 }
  let(:d_ring_h) { 5 }
  # For convenience:
  # 'or' == outer ring
  let(:d_or_llc) { '0 0 0' }
  let(:d_or_lrc) { '20 0 0' }
  let(:d_or_urc) { '20 20 0' }
  let(:d_or_ulc) { '0 20 0' }
  # 'ir' == inner ring
  let(:d_ir_llc) { '5 5 0' }
  let(:d_ir_ulc) { '15 5 0' }
  let(:d_ir_urc) { '15 15 0' }
  let(:d_ir_lrc) { '5 15 0' }

  let(:donut) do
    p = "POLYGON((#{d_or_llc}, #{d_or_lrc}, #{d_or_urc}, #{d_or_ulc},
                  #{d_or_llc}),
                 (#{d_ir_llc}, #{d_ir_ulc}, #{d_ir_urc}, #{d_ir_lrc},
                  #{d_ir_llc}))"

    FactoryBot.create(:geographic_item_geography, geography: p)
  end

  # geometric centroid
  let(:donut_centroid) do
    c_x = d_llc_x + d_w / 2
    c_y = d_llc_y + d_h / 2
    c = "POINT (#{c_x} #{c_y} 0)"

    FactoryBot.create(:geographic_item_geography, geography: c)
  end

  let (:donut_interior_point) do
    interior_x = d_llc_x + d_ring_w / 2
    interior_y = d_llc_y + d_ring_h / 2
    i_p = "POINT(#{interior_x} #{interior_y} 0)"

    FactoryBot.create(:geographic_item_geography, geography: i_p)
  end

  let (:donut_left_interior_edge_point) {
    p_x = d_llc_x + d_ring_w
    p_y = d_llc_y + d_h / 2
    p = "POINT (#{p_x} #{p_y} 0)"

    FactoryBot.create(:geographic_item_geography, geography: p)
  }

  let (:donut_left_interior_edge) {
    l_x = d_llc_x + d_ring_w
    l_lower_y = d_llc_y + d_ring_h
    l_upper_y = d_llc_y + d_h - d_ring_h
    l = "LINESTRING (#{l_x} #{l_lower_y}, #{l_x} #{l_upper_y})"

    FactoryBot.create(:geographic_item_geography, geography: l)
  }

  let (:donut_bottom_interior_edge) {
    l_left_x = d_llc_x + d_ring_w
    l_right_x = d_llc_x + d_w - d_ring_w
    l_y = d_llc_y + d_ring_h
    l = "LINESTRING (#{l_left_x} #{l_y}, #{l_right_x} #{l_y})"

    FactoryBot.create(:geographic_item_geography, geography: l)
  }

  # A multi_line_string
  let (:donut_interior_bottom_left_multi_line) {
    m_l = RSPEC_GEO_FACTORY.multi_line_string([
      donut_left_interior_edge.geo_object,
      donut_bottom_interior_edge.geo_object
    ])

    FactoryBot.create(:geographic_item_geography, geography: m_l)
  }

  ### A box polygon and sub-shapes

  # box = POLYGON((40 0 0, 60 0 0, 60 20 0, 40 20 0, 40 0 0))
  let(:box_llc_x) {40}
  let(:box_llc_y) {0}
  # width == height, though that isn't necessary
  let(:box_w) {20} # should be divisible by 2
  let(:box_h) {20} # should be divisible by 2
  # For convenience:
  let(:box_llc) {'40 0 0'}
  let(:box_lrc) {'60 0 0'}
  let(:box_urc) {'60 20 0'}
  let(:box_ulc) {'40 20 0'}


  let(:box) do
    b = "POLYGON((#{box_llc}, #{box_lrc}, #{box_urc}, #{box_ulc}, #{box_llc}))"

    FactoryBot.create(:geographic_item_geography, geography: b)
  end

  # geometric centroid
  let(:box_centroid) {
    c_x = box_llc_x + box_w / 2
    c_y = box_llc_y + box_h / 2
    c = "POINT (#{c_x} #{c_y} 0)"

    FactoryBot.create(:geographic_item_geography, geography: c)
  }

  let(:box_horizontal_bisect_line) {
    left_x = box_llc_x
    right_x = left_x + box_w
    y = box_llc_y + box_h / 2
    line = "LINESTRING (#{left_x} #{y} 0, #{right_x} #{y} 0)"
    FactoryBot.create(:geographic_item_geography, geography: line)
  }

  ### A rectangle polygon intersecting the previous box; both start at the same
  # height, the rectangle is taller than box_centroid but shorter than box (is
  # that important?); box_centroid is in the left side of rectangle; the right
  # side of rectangle is beyond the right side of box

  # rectangle = POLYGON((50 0 0, 70 0 0, 70 15 0, 50 15 0, 50 0 0))
  let(:rect_w) { box_w }
  let(:rect_h) { 3 * box_h / 4 }
  let(:rectangle_intersecting_box) do
    llc_x = box_llc_x + box_w / 2
    llc_y = box_llc_y

    lrc_x = llc_x + rect_w
    lrc_y = llc_y

    urc_x = lrc_x
    urc_y = lrc_y + rect_h

    ulc_x = llc_x
    ulc_y = urc_y

    r = "POLYGON ((#{llc_x} #{llc_y} 0, #{lrc_x} #{lrc_y} 0, " \
                  "#{urc_x} #{urc_y} 0, #{ulc_x} #{ulc_y} 0, " \
                  "#{llc_x} #{llc_y} 0))"

    FactoryBot.create(:geographic_item_geography, geography: r)
  end

  ### A point in the interior of the intersection of box and rectangle
  let(:box_rectangle_intersection_point) {
    i_x = box_llc_x + 3 * box_w / 4
    i_y = box_llc_y + box_h / 4
    i = "POINT (#{i_x} #{i_y})"

    FactoryBot.create(:geographic_item_geography, geography: i)
  }

  ### The union of the box and rectangle polygons as a single polygon
  let(:box_rectangle_union) {
    m_p = box.geo_object.union(rectangle_intersecting_box.geo_object)

    FactoryBot.create(:geographic_item_geography, geography: m_p)}

  ###### Multi-shapes
  # !! Note these instantiate their constituent shapes
  ### A multi_point
  let(:donut_box_multi_point) do
    donut_point = donut_interior_point.geo_object
    box_point = box_centroid.geo_object
    m_p = RSPEC_GEO_FACTORY.multi_point([donut_point, box_point])

    FactoryBot.create(:geographic_item_geography, geography: m_p)
  end

  ### A mult_line_string
  # :donut_interior_bottom_left_multi_line is a multi_line_string

  ### A multi_polygon
  let(:donut_rectangle_multi_polygon) do
    m_poly = RSPEC_GEO_FACTORY.multi_polygon(
      [donut.geo_object, rectangle_intersecting_box.geo_object]
    )

    FactoryBot.create(:geographic_item_geography, geography: m_poly)
  end

  ### A geometry_collection
  let(:donut_box_bisector_rectangle_geometry_collection) do
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