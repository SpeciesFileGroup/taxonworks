require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for GeographicItem tests' # that's spec/support/shared_contexts/shared_basic_geo.rb

  # the pattern `before { [s1, s2, ...].each }` is to instantiate variables
  # that have been `let` (not `let!`) by referencing them using [...].each.
  # Shapes that were FactoryBot.created in `let`s will be saved to the
  # database at that time, so you can specify your shapes universe for a given
  # context by listing the shapes you want to exist in that universe.

  # !! Note that multi-shapes instantiate their constituent shapes, so for
  # example if you reference (and therefore instantiate)
  # donut_rectangle_multi_polygon, you've also instantiated donut and rectangle.

  # TODO add some geometry_collection specs
  # TODO add and comment out any ce, co, gr, ad specs that currently only need
  # to be tested against non-geography columns
  #TODO spec intersecting_radius_of_wkt

  let(:geographic_item) { GeographicItem.new }

  context 'can hold any' do
    specify 'point' do
      expect(simple_point.geo_object_type).to eq(:point)
    end

    specify 'line_string' do
      expect(simple_line_string.geo_object_type).to eq(:line_string)
    end

    specify 'polygon' do
      expect(simple_polygon.geo_object_type).to eq(:polygon)
    end

    specify 'multi_point' do
      expect(simple_multi_point.geo_object_type).to eq(:multi_point)
    end

    specify 'multi_line_string' do
      expect(simple_multi_line_string.geo_object_type).to eq(:multi_line_string)
    end

    specify 'multi_polygon' do
      expect(simple_multi_polygon.geo_object_type).to eq(:multi_polygon)
    end

    specify 'geometry_collection' do
      expect(simple_geometry_collection.geo_object_type)
        .to eq(:geometry_collection)
    end
  end

  context 'initialization hooks' do
    context 'winding' do
      let(:cw_polygon) do
        # exterior cw, interior ccw (both backwards)
        p = 'POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), ' \
          '(3 3, 6 3, 6 6, 3 6, 3 3))'

          FactoryBot.create(:geographic_item, geography: p)
      end

      let(:ccw_cw_m_p) do
        # First ccw, second cw
        m_p = 'MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0)),' \
                            '((20 0, 20 10, 30 10, 30 0, 20 0)))'

        FactoryBot.create(:geographic_item, geography: m_p)
      end

      specify 'polygon winding is ccw after save' do
        expect(cw_polygon.geo_object.exterior_ring.ccw?).to eq(false)
        expect(
          cw_polygon.geo_object.interior_rings.map(&:ccw?).uniq
        ).to eq([true])

        cw_polygon.save!
        cw_polygon.reload
        expect(cw_polygon.geo_object.exterior_ring.ccw?).to eq(true)
        expect(
          cw_polygon.geo_object.interior_rings.map(&:ccw?).uniq
        ).to eq([false])
      end

      specify 'multi_polygon winding is ccw after save' do
        expect(ccw_cw_m_p.geo_object[0].exterior_ring.ccw?).to eq(true)
        expect(ccw_cw_m_p.geo_object[1].exterior_ring.ccw?). to eq(false)

        ccw_cw_m_p.save!
        ccw_cw_m_p.reload
        expect(ccw_cw_m_p.geo_object[0].exterior_ring.ccw?).to eq(true)
        expect(ccw_cw_m_p.geo_object[1].exterior_ring.ccw?). to eq(true)
      end
    end

    context 'area' do
      specify 'area of a saved polygon is > 0' do
        expect(box.area).to be > 0
      end
    end
  end

  context 'scopes (GeographicItems can be found by searching with)' do
    before {
      [ce_box_centroid, ce_rectangle_point,
        gr_box_centroid, gr_rectangle_point, distant_point].each
    }

    specify '::geo_with_collecting_event includes' do
      expect(GeographicItem.geo_with_collecting_event.to_a)
        .to contain_exactly(box_centroid, box_rectangle_intersection_point)
    end

    specify '::geo_with_collecting_event does not include' do
      expect(GeographicItem.geo_with_collecting_event.to_a)
        .not_to include(distant_point)
    end

    specify '::err_with_collecting_event includes' do
      expect(GeographicItem.err_with_collecting_event.to_a)
        .to contain_exactly(box, rectangle_intersecting_box)
    end

    specify '::err_with_collecting_event does not include' do
      expect(GeographicItem.err_with_collecting_event.to_a)
        .not_to include(distant_point)
    end

    specify '::include_collecting_event' do
      # This is just all created GeographicItems (doesn't test preloading)
      expect(GeographicItem.include_collecting_event.to_a)
        .to contain_exactly(box_centroid, box, distant_point,
          rectangle_intersecting_box, box_rectangle_intersection_point)
    end

    specify '::with_collecting_event_through_georeferences includes' do
      expect(GeographicItem.with_collecting_event_through_georeferences.to_a)
        .to contain_exactly(box_centroid, box_rectangle_intersection_point,
          box, rectangle_intersecting_box)
    end

    specify '::with_collecting_event_through_georeferences does not contain' do
      expect(GeographicItem.with_collecting_event_through_georeferences.to_a)
        .not_to include(distant_point)
    end
  end

  context 'construction via #shape=' do
    let(:geo_json) {
      '{
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [10, 10]
        },
        "properties": {
          "name": "Sample Point",
          "description": "This is a sample point feature."
        }
      }'
    }

    let(:geo_json2) {
      '{
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [20, 20]
        },
        "properties": {
          "name": "Sample Point",
          "description": "This is a sample point feature."
        }
      }'
    }

    specify '#shape=' do
      g = GeographicItem.new(shape: geo_json)
      expect(g.save).to be_truthy
    end

    specify '#shape= 2' do
      g = GeographicItem.create!(shape: geo_json)
      g.update!(shape: geo_json2)
      expect(g.reload.geo_object.to_s).to match(/20/)
    end

    specify '#shape= bad linear ring' do
      bad = '{
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [-80.498221, 25.761437],
              [-80.498221, 25.761959],
              [-80.498221, 25.761959],
              [-80.498221, 25.761437]
            ]
          ]
        }
      }'

      g = GeographicItem.new(shape: bad)
      g.valid?
      expect(g.errors[:base]).to be_present
    end

    specify 'for polygon' do
      geographic_item.shape = '{"type":"Feature","geometry":{"type":"Polygon",' \
        '"coordinates":[[[-90.25122106075287,38.619731572825145],[-86.12036168575287,39.77758382625017],' \
        '[-87.62384042143822,41.89478088863241],[-90.25122106075287,38.619731572825145]]]}}'
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'for linestring' do
      geographic_item.shape =
        '{"type":"Feature","geometry":{"type":"LineString","coordinates":[' \
        '[-90.25122106075287,38.619731572825145],' \
        '[-86.12036168575287,39.77758382625017],' \
        '[-87.62384042143822,41.89478088863241]]}}'
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'for "circle"' do
      geographic_item.shape = '{"type":"Feature","geometry":{"type":"Point",' \
        '"coordinates":[-88.09681320155505,40.461195702960666]},' \
        '"properties":{"radius":1468.749413840412,' \
        '"name":"Paxton City Hall"}}'
      expect(geographic_item.valid?).to be_truthy
    end
  end

  context '#geo_object_type gives underlying shape' do
    specify '#geo_object_type' do
      expect(geographic_item).to respond_to(:geo_object_type)
    end

    specify '#geo_object_type when item not saved' do
      geographic_item.geography = simple_shapes[:point]
      expect(geographic_item.geo_object_type).to eq(:point)
    end
  end

  context 'validation' do
    specify 'some data must be provided' do
      geographic_item.valid?
      expect(geographic_item.errors[:base]).to be_present
    end

    specify 'invalid data for point is invalid' do
      geographic_item.geography = 'Some string'
      expect(geographic_item.valid?).to be_falsey
    end

    specify 'a valid point is valid' do
      expect(simple_point.valid?).to be_truthy
    end

    specify "a good point didn't change on creation" do
      expect(simple_point.geography.x).to eq 10
    end

    specify 'a point, when provided, has a legal geography' do
      geographic_item.geography = simple_point.geo_object
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'geography can change shape' do
      simple_point.geography = simple_polygon.geography
      expect(simple_point.valid?).to be_truthy
      expect(simple_point.geo_object_type).to eq(:polygon)
    end
  end

  context 'instance methods' do

    context 'rgeo through geo_object' do
      context '#geo_object' do
        before {
          geographic_item.geography = simple_point.geo_object
        }

        specify '#geo_object' do
          expect(geographic_item).to respond_to(:geo_object)
        end

        specify '#geo_object returns stored data' do
          geographic_item.save!
          expect(geographic_item.geo_object).to eq(simple_point.geo_object)
        end

        specify '#geo_object returns stored db data' do
          geographic_item.save!
          geo_id = geographic_item.id
          expect(GeographicItem.find(geo_id).geo_object)
            .to eq geographic_item.geo_object
        end
      end

      specify '#contains? - to see if one object is contained by another.' do
        expect(geographic_item).to respond_to(:contains?)
      end

      specify '#within? -  to see if one object is within another.' do
        expect(geographic_item).to respond_to(:within?)
      end

      specify '#contains? if one object is inside the area defined by the other' do
        expect(donut.contains?(donut_interior_point.geo_object)).to be_truthy
      end

      specify '#contains? if one object is outside the area defined by the other' do
        expect(donut.contains?(distant_point.geo_object)).to be_falsey
      end
    end

    context 'centroids' do
      context '#st_centroid' do
        specify '#st_centroid returns wkt of the centroid' do
          # geometric centroid
          expect(simple_polygon.st_centroid).to eq('POINT(5 5)')
        end
      end

      context '#centroid' do
        # geometric centroid
        specify '#centroid returns an rgeo centroid' do
          expect(box.centroid).to eq(box_centroid.geo_object)
        end
      end

      context '#center_coords' do
        specify 'works for a polygon' do
          lat, long = box.center_coords
          expect(lat.to_s).to eq(lat)
          expect(long.to_s).to eq(long)
          expect(lat.to_f).to be_within(0.01).of(box_centroid.geo_object.y)
          expect(long.to_f).to be_within(0.01).of(box_centroid.geo_object.x)
        end
      end
    end

    context '#st_distance_to_geographic_item' do
      specify 'works for distance beetween points on equator' do
        expect(
          equator_point_long_0
            .st_distance_to_geographic_item(equator_point_long_20)
        ).to be_within(0.01).of(20 * Utilities::Geo::ONE_WEST)
      end
    end

    context '#st_is_valid' do
      specify 'valid polygon is valid' do
        expect(simple_polygon.st_is_valid).to be_truthy
      end

      # TODO I don't think it's actually possible to save an invalid geometry
      # without validation failing, i.e. I think st_is_valid can only ever
      # return true.
      specify 'invalid line is invalid' do
        invalid_line = 'LINESTRING (0 0)'
        geographic_item.geography = invalid_line

        # Uhhhh...
        expect{ geographic_item.valid? }
          .to raise_error(RGeo::Error::InvalidGeometry)
      end
    end
  end

  context 'class methods' do

    context '::superset_of_union_of - return objects containing the union of the given objects' do
      before {
        [donut, donut_centroid, donut_interior_point,
         donut_left_interior_edge_point, donut_left_interior_edge,
         donut_bottom_interior_edge,
         donut_interior_bottom_left_multi_line].each
      }

      specify "doesn't return self" do
        expect(GeographicItem.superset_of_union_of(
          donut.id
        ).to_a).to eq([])
      end

      specify 'find the polygon containing the point' do
        expect(GeographicItem.superset_of_union_of(
          donut_interior_point.id
        ).to_a).to contain_exactly(donut)
      end

      specify 'tests against the *union* of its inputs' do
        expect(GeographicItem.superset_of_union_of(
          donut_interior_point.id, distant_point.id
        ).to_a).to eq([])
      end

      specify 'polygon containing two of its points is returned once' do
        expect(GeographicItem.superset_of_union_of(
          [donut_interior_point.id, donut_left_interior_edge_point.id]
        ).to_a).to contain_exactly(donut)
      end

      specify 'a polygon covers its edge' do
        expect(GeographicItem.superset_of_union_of(
          donut_interior_bottom_left_multi_line.id
        ).to_a).to contain_exactly(donut)
      end

      specify 'find that shapes contain their vertices' do
        vertex = FactoryBot.create(:geographic_item,
          geography: donut_left_interior_edge.geo_object.start_point)

        expect(GeographicItem.superset_of_union_of(
          vertex.id
        ).to_a).to contain_exactly(donut,
          donut_left_interior_edge, donut_bottom_interior_edge,
          donut_interior_bottom_left_multi_line
        )
      end
    end

    context '::within_union_of' do
      before { [donut_interior_bottom_left_multi_line,
        donut_interior_point, donut_centroid,
        donut_left_interior_edge, donut_bottom_interior_edge].each
      }

      specify 'a shape is within_union_of itself' do
        expect(
          GeographicItem.where(
            GeographicItem.subset_of_union_of_sql(donut.id)
          ).to_a
        ).to include(donut)
      end

      specify 'finds the shapes covered by a polygon' do
        expect(
          GeographicItem.where(
            GeographicItem.subset_of_union_of_sql(donut.id)
          ).to_a
        ).to contain_exactly(donut, donut_interior_bottom_left_multi_line,
          donut_left_interior_edge, donut_bottom_interior_edge,
          donut_interior_point)
      end

      specify 'returns duplicates' do
        duplicate_point = FactoryBot.create(:geographic_item,
          geography: box_centroid.geo_object)

        expect(
          GeographicItem.where(
            GeographicItem.subset_of_union_of_sql(box.id)
          ).to_a
        ).to contain_exactly(box_centroid, duplicate_point, box)
      end
    end

    context '::st_covers - returns objects of a given shape which contain one
             or more given objects' do
      before { [donut, donut_left_interior_edge,
                donut_interior_bottom_left_multi_line,
                donut_rectangle_multi_polygon,
                box, box_rectangle_union
              ].each }

      specify 'includes self when self is of the right shape' do
        expect(GeographicItem.st_covers('multi_line_string',
          [donut_interior_bottom_left_multi_line]).to_a)
        .to include(donut_interior_bottom_left_multi_line)
      end

      specify 'a shape that covers two input shapes is only returned once' do
        expect(GeographicItem.st_covers('polygon',
          [box_centroid, box_horizontal_bisect_line]).to_a)
        # box and box_rectangle_union contain both inputs
        .to contain_exactly(
          box, rectangle_intersecting_box, box_rectangle_union
        )
      end

      specify 'includes shapes that cover part of their boundary' do
        expect(GeographicItem.st_covers('any',
          [donut_left_interior_edge]).to_a)
        .to contain_exactly(donut_left_interior_edge,
          donut_interior_bottom_left_multi_line, donut,
          donut_rectangle_multi_polygon
        )
      end

      specify 'point covered by nothing is only covered by itself' do
        expect(GeographicItem.st_covers('any',
          distant_point).to_a)
        .to contain_exactly(distant_point)
      end

      # OR!
      specify 'disjoint polygons each containing an input' do
        expect(GeographicItem.st_covers('polygon',
          [donut_left_interior_edge, box_centroid]).to_a)
        .to contain_exactly(
          donut, box, rectangle_intersecting_box, box_rectangle_union
        )
      end

      specify 'works with any_line' do
        expect(GeographicItem.st_covers('any_line',
          donut_left_interior_edge_point, distant_point).to_a)
        .to contain_exactly(
          donut_left_interior_edge,
          donut_interior_bottom_left_multi_line
        )
      end

      specify 'works with any_poly' do
        expect(GeographicItem.st_covers('any_poly',
          box_centroid).to_a)
        .to contain_exactly(
          box, rectangle_intersecting_box, box_rectangle_union,
          donut_rectangle_multi_polygon
        )
      end

      specify 'works with any' do
        expect(GeographicItem.st_covers('any',
          donut_left_interior_edge_point).to_a)
        .to contain_exactly(donut_left_interior_edge_point,
          donut_left_interior_edge,
          donut_interior_bottom_left_multi_line,
          donut,
          donut_rectangle_multi_polygon
        )
      end
    end

    context '::st_covered_by - returns objects which are contained by given
             objects.' do
      before { [donut, donut_interior_point, donut_left_interior_edge_point,
                donut_left_interior_edge_point, donut_left_interior_edge,
                donut_bottom_interior_edge,
                donut_interior_bottom_left_multi_line,
                box, box_centroid, box_horizontal_bisect_line,
                rectangle_intersecting_box, box_rectangle_intersection_point,
                donut_rectangle_multi_polygon].each }

      specify 'object of the right shape is st_covered_by itself' do
        expect(GeographicItem.st_covered_by('multi_line_string',
            [donut_interior_bottom_left_multi_line]).to_a)
          .to include(donut_interior_bottom_left_multi_line)
      end

      specify 'includes shapes which are a boundary component of an input' do
        expect(GeographicItem.st_covered_by('line_string',
          donut).to_a)
        .to contain_exactly(donut_left_interior_edge,
          donut_bottom_interior_edge)
      end

      specify 'a point only covers itself' do
        expect(GeographicItem.st_covered_by('any',
          donut_left_interior_edge_point).to_a)
        .to eq([donut_left_interior_edge_point])
      end

      specify 'shapes contained by two shapes are only returned once' do
        expect(GeographicItem.st_covered_by('point',
          box, rectangle_intersecting_box).to_a)
        .to eq([box_centroid, box_rectangle_intersection_point])
      end

      specify 'points in separate polygons' do
        expect(GeographicItem.st_covered_by('point',
          donut, box).to_a)
        .to contain_exactly(donut_interior_point,
          donut_left_interior_edge_point, box_centroid,
          box_rectangle_intersection_point)
      end

      specify 'works with any_line' do
        expect(GeographicItem.st_covered_by('any_line',
          donut).to_a)
        .to contain_exactly(
          donut_left_interior_edge, donut_bottom_interior_edge,
          donut_interior_bottom_left_multi_line
        )
      end

      specify 'works with any_poly' do
        expect(GeographicItem.st_covered_by('any_poly',
          donut_rectangle_multi_polygon).to_a)
        .to contain_exactly(
           donut, rectangle_intersecting_box, donut_rectangle_multi_polygon
        )
      end

      specify 'does not work with arbitrary geometry collection' do
        pending 'ST_Covers fails when input GeometryCollection has a line intersecting a polygon\'s interior'
        # The same test as the previous only the geometry collection in the
        # first argument also contains a line intersecting the interior of
        # rectangle - if you remove the line from the collection the test
        # passes:
        # pass_g_c = FactoryBot.create(:geographic_item_geography, geography:
        #  RSPEC_GEO_FACTORY.collection(
        #    [
        #       donut.geo_object,
        #       rectangle_intersecting_box.geo_object,
        #    ]
        # )
        # If the line only intersects the boundary of rectangle, or the line
        # is interior to rectangle, or if it's instead an interior point of
        # rectangle, the test also passes.
        expect(GeographicItem.st_covered_by('any_poly',
          donut_box_bisector_rectangle_geometry_collection).to_a)
        .to contain_exactly(
          donut, rectangle_intersecting_box, donut_rectangle_multi_polygon
        )
      end

      specify 'works with any' do
        expect(GeographicItem.st_covered_by('any',
          box_rectangle_union).to_a)
        .to contain_exactly(box_rectangle_union,
          box, rectangle_intersecting_box, box_horizontal_bisect_line,
          box_centroid, box_rectangle_intersection_point
        )
      end
    end

    context '::within_radius_of_item' do
      before { [equator_point_long_0, equator_point_long_20,
        equator_point_long_30].each }
      specify 'returns objects within a specific distance of an object' do
        r = 15 * Utilities::Geo::ONE_WEST
        expect(
          GeographicItem.within_radius_of_item(equator_point_long_20.id, r)
        ).to contain_exactly(equator_point_long_20, equator_point_long_30)
      end

      specify "doesn't return objects outside a specific distance of an object" do
        r = 5 * Utilities::Geo::ONE_WEST
        expect(
          GeographicItem.within_radius_of_item(equator_point_long_20.id, r)
        ).to contain_exactly(equator_point_long_20)
      end

      # Intended?
      specify 'shape is within_radius_of itself' do
        expect(
          GeographicItem.within_radius_of_item(distant_point.id, 100)
        ).to include(distant_point)
      end
    end

    context '::intersecting' do
      before { [
        donut, donut_left_interior_edge,
        box, box_centroid, box_horizontal_bisect_line,
        rectangle_intersecting_box, box_rectangle_union
      ].each }

      # Intended?
      specify 'a geometry of the right shape intersects itself' do
        expect(GeographicItem.intersecting('any', distant_point.id).to_a)
          .to eq([distant_point])
      end

      specify 'works with a specific shape' do
        expect(GeographicItem.intersecting('polygon',
          box_rectangle_intersection_point.id).to_a)
          .to contain_exactly(
            box, rectangle_intersecting_box, box_rectangle_union
          )
      end

      specify 'works with multiple input shapes' do
        expect(GeographicItem.intersecting('line_string',
          [donut_left_interior_edge_point.id, box.id]).to_a)
        .to contain_exactly(
          donut_left_interior_edge, box_horizontal_bisect_line
        )
      end

      specify 'works with any' do
        expect(GeographicItem.intersecting('any',
          box_horizontal_bisect_line.id).to_a)
        .to contain_exactly(box_horizontal_bisect_line,
          # geographic intersects does not include box_centroid
          box, rectangle_intersecting_box, box_rectangle_union
        )
      end
    end

    context '::lat_long_sql' do
      specify 'returns latitude of a point' do
        expect(GeographicItem
          .where(id: distant_point.id)
          .select(GeographicItem.lat_long_sql(:latitude))
          .first['latitude'].to_f
        ).to be_within(0.01).of(distant_point.geo_object.y)
      end

      specify 'returns longitude of a point' do
        expect(GeographicItem
          .where(id: distant_point.id)
          .select(GeographicItem.lat_long_sql(:longitude))
          .first['longitude'].to_f
        ).to be_within(0.01).of(distant_point.geo_object.x)
      end
    end

    context '::within_radius_of_wkt_sql' do
      before { [equator_point_long_0, equator_point_long_20,
        equator_point_long_30].each }

      specify 'works for a wkt point' do
        wkt = equator_point_long_20.to_wkt
        r = 15 * Utilities::Geo::ONE_WEST
        expect(GeographicItem.where(
          GeographicItem.within_radius_of_wkt_sql(wkt, r))
        ).to contain_exactly(equator_point_long_20, equator_point_long_30)
      end
    end

    context '::covered_by_wkt_sql' do
      specify 'works for a wkt multipolygon' do
        wkt = donut_rectangle_multi_polygon.to_wkt
        expect(GeographicItem.where(
          GeographicItem.covered_by_wkt_sql(wkt))
        # Should contain all donut shapes and all rectangle shapes
        ).to contain_exactly(donut_rectangle_multi_polygon,
          donut, donut_interior_bottom_left_multi_line,
          donut_left_interior_edge, donut_bottom_interior_edge,
          donut_left_interior_edge_point, rectangle_intersecting_box
        )
      end
    end

    context '::st_buffer_st_within_sql' do
      before { [equator_point_long_0, equator_point_long_20,
        equator_point_long_30].each }

      specify 'buffer = 0, d = 0 is intersection' do
        expect(
          GeographicItem.where(
            GeographicItem.st_buffer_st_within_sql(box.id, 0, 0)
          )
        ).to include(box, rectangle_intersecting_box)
      end

      specify 'expanding target shapes works' do
        buffer = 15 * Utilities::Geo::ONE_WEST
        expect(
          GeographicItem.where(
            GeographicItem.st_buffer_st_within_sql(
              equator_point_long_20.id, 0, buffer
            )
          ).to_a
        ).to contain_exactly(equator_point_long_20, equator_point_long_30)
      end

      specify 'shrinking target shapes works' do
        # instantiate donut
        donut

        # control case
        buffer = 0
        expect(
          GeographicItem.where(
            GeographicItem.st_buffer_st_within_sql(
              donut_left_interior_edge_point.id, 0, buffer)
          ).to_a
        ).to eq([donut])

        buffer = -(1 * Utilities::Geo::ONE_WEST)
        expect(
          GeographicItem.where(
            GeographicItem.st_buffer_st_within_sql(
              donut_left_interior_edge_point.id, 0, buffer)
          ).to_a
        ).to eq([])
      end
    end

    context '#circle' do
      let(:origin) { Gis::FACTORY.point(0, 0) }
      specify 'buffer resolution determines # of sides of polygon' do
        expect(
          GeographicItem.circle(origin, 10, 3).exterior_ring.points.count
        ).to eq(13)

        expect(
          GeographicItem.circle(origin, 10, 10).exterior_ring.points.count
        ).to eq(41)
      end

      specify 'has approximate expected shape' do
        c = GeographicItem.circle(origin, 10)
        # Rough estimates
        # (buffer is 2d so all z-coordinates are NaN, but that seems to be okay
        # for our purposes)
        smaller_circle = origin.buffer(9.5 / Utilities::Geo::ONE_WEST_MEAN)
        larger_circle = origin.buffer(10.5 / Utilities::Geo::ONE_WEST_MEAN)

        expect(c.contains?(smaller_circle)).to be true
        expect(larger_circle.contains?(c)).to be true
      end
    end
  end

end
