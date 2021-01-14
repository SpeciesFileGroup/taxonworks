require 'rails_helper'

describe GeographicItem, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'

  let(:geographic_item) { GeographicItem.new }

  context 'using ce_test_objects' do

    let(:geographic_item) { FactoryBot.build(:geographic_item) }
    let(:geographic_item_with_point_a) { FactoryBot.build(:geographic_item_with_point_a) }
    let(:geographic_item_with_point_b) { FactoryBot.build(:geographic_item_with_point_b) }
    let(:geographic_item_with_point_c) { FactoryBot.build(:geographic_item_with_point_c) }
    let(:geographic_item_with_line_string) { FactoryBot.build(:geographic_item_with_line_string) }
    let(:geographic_item_with_polygon) { FactoryBot.build(:geographic_item_with_polygon) }
    let(:geographic_item_with_multi_polygon) { FactoryBot.build(:geographic_item_with_multi_polygon) }

=begin
  context 'database functions' do

    specify 'ST_Geometry_Same' do
      skip
      #expect(GeographicItem.same(geographic_item_with_line_string.geo_object,
      #                           geographic_item_with_line_string.geo_object)).to be_truthy
      #expect(GeographicItem.same(geographic_item_with_line_string.geo_object,
      #                           geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_Area' do
      skip
      #expect(GeographicItem.area(geographic_item_with_polygon.geo_object)).to eq 0.123
    end

    specify 'ST_Azimuth' do
      skip
      #expect(GeographicItem.azimuth(geographic_item_with_point_a.geo_object,
      #                              geographic_item_with_point_b.geo_object)).to eq 44.5
      #expect(GeographicItem.azimuth(geographic_item_with_point_b.geo_object,
      #                              geographic_item_with_point_a.geo_object)).to eq 44.5
      #expect(GeographicItem.azimuth(geographic_item_with_point_a.geo_object,
      #                              geographic_item_with_point_a.geo_object)).to eq 44.5
    end

    specify 'ST_Centroid' do
      skip
      #expect(GeographicItem.centroid(geographic_item_with_polygon.polygon)).to eq geographic_item_with_point_c
    end

    specify 'ST_Contains' do
      skip
      #expect(GeographicItem.contains(geographic_item_with_polygon.geo_object,
      #                               geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.contains(geographic_item_with_point_c.geo_object,
      #                               geographic_item_with_polygon.geo_object)).to be_falsey
      #expect(GeographicItem.contains(geographic_item_with_polygon.geo_object,
      #                               geographic_item_with_polygon.geo_object)).to be_truthy
    end

    specify 'self.find_contains ' do
      skip 'building a City of Champaign shape, and a point inside it'
    end

    specify 'ST_ContainsProperly ' do
      skip
      #expect(GeographicItem.contains_properly(geographic_item_with_polygon.geo_object,
      #                                        geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.contains_properly(geographic_item_with_point_c.geo_object,
      #                                        geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_Covers' do
      skip
      #expect(GeographicItem.covers(geographic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_CoveredBy' do
      skip
      #expect(GeographicItem.covers(geographic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_Crosses' do
      skip
      #expect(GeographicItem.covers(geographic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_LineCrossingDirection' do
      skip
      #expect(GeographicItem.covers(geographic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_Disjoint' do
      skip
      #expect(GeographicItem.covers(geographic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_falsey
    end

    specify 'ST_Distance' do
      skip
      #expect(GeographicItem.covers(geographic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_truthy
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_falsey
    end

  end
=end

    context 'STI' do
      context 'type is set before validation when column is provided (assumes type is null)' do
        GeographicItem::DATA_TYPES.each do |t|
          specify "for #{t}" do
            geographic_item.send("#{t}=", simple_shapes[t])
            expect(geographic_item.valid?).to be_truthy
            expect(geographic_item.type).to eq("GeographicItem::#{t.to_s.camelize}")
          end
        end
      end

      context 'subclasses have a SHAPE_COLUMN set' do
        GeographicItem.descendants.each do |d|
          specify "for #{d}" do
            expect(d::SHAPE_COLUMN).to be_truthy
          end
        end
      end

      specify '#geo_object_type' do
        expect(geographic_item).to respond_to(:geo_object_type)
      end

      specify '#geo_object_type when item not saved' do
        geographic_item.point = simple_shapes[:point]
        expect(geographic_item.geo_object_type).to eq(:point)
      end
    end

    context 'validation' do
      before(:each) {
        geographic_item.valid?
      }

      specify 'some data must be provided' do
        expect(geographic_item.errors.keys).to include(:base)
      end

      specify 'invalid data for point is invalid' do
        geographic_item.point = 'Some string'
        expect(geographic_item.valid?).to be_falsey
      end

      specify 'a valid point is valid' do
        expect(geographic_item_with_point_a.valid?).to be_truthy
      end

      specify 'A good point that didn\'t change.' do
        expect(geographic_item_with_point_a.point.x).to eq -88.241413
      end

      specify 'a point, when provided, has a legal geography' do
        geographic_item.point = RSPEC_GEO_FACTORY.point(180.0, 85.0)
        expect(geographic_item.valid?).to be_truthy
      end

      specify 'One and only one of point, line_string, etc. is set.' do
        geographic_item_with_point_a.polygon = geographic_item_with_point_a.point.buffer(10)
        expect(geographic_item_with_point_a.valid?).to be_falsey
      end
    end

    context 'geo_object interactions (Geographical attribute of GeographicItem)' do

      context 'Any line_string can be made into polygons.' do
        specify 'non-closed line string' do
          expect(RSPEC_GEO_FACTORY.polygon(list_k).to_s).to eq('POLYGON ((-33.0 -11.0 0.0, -33.0 -23.0 0.0, -21.0 -23.0 0.0, -21.0 -11.0 0.0, -27.0 -13.0 0.0, -33.0 -11.0 0.0))')
        end

        specify 'closed line string' do
          expect(RSPEC_GEO_FACTORY.polygon(d.geo_object).to_s).to eq('POLYGON ((-33.0 11.0 0.0, -24.0 4.0 0.0, -26.0 13.0 0.0, -38.0 14.0 0.0, -33.0 11.0 0.0))')
        end
      end

      specify 'That one object contains another, or not.' do
        expect(k.contains?(p1.geo_object)).to be_truthy
      end

      specify 'That one object contains another, or not.' do
        expect(k.contains?(p17.geo_object)).to be_falsey
      end

      specify 'That one object contains another, or not.' do
        expect(p17.within?(k.geo_object)).to be_falsey
      end

      specify 'That one object contains another, or not.' do
        expect(p17.within?(k.geo_object)).to be_falsey
      end

      specify 'That one object intersects another, or not.' do # using geographic_item.intersects?
        expect(e1.intersects?(e2.geo_object)).to be_truthy
      end

      specify 'That one object intersects another, or not.' do # using geographic_item.intersects?
        expect(e1.intersects?(e3.geo_object)).to be_falsey
      end

      specify 'That one object intersects another, or not.' do # using geographic_item.intersects?
        expect(p1.intersects?(k.geo_object)).to be_truthy
      end

      specify 'That one object intersects another, or not.' do # using geographic_item.intersects?
        expect(p17.intersects?(k.geo_object)).to be_falsey
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.intersects?(shapeE2)).to be_truthy
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.intersects?(shapeE3)).to be_falsey
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.overlaps?(shapeE2)).to be_truthy
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.overlaps?(shapeE3)).to be_falsey
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.intersection(shapeE2)).to eq(e1_and_e2)
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.intersection(shapeE4)).to eq(e1_and_e4)
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.union(shapeE2)).to eq(e1_or_e2)
      end

      specify 'Two polygons may have various intersections.' do
        expect(shapeE1.union(shapeE5)).to eq(e1_or_e5)
      end

      specify 'Two polygons may have various adjacencies.' do
        expect(shapeE1.touches?(shapeE5)).to be_falsey
      end

      specify 'Two polygons may have various adjacencies.' do
        expect(shapeE2.touches?(shapeE3)).to be_truthy
      end

      specify 'Two polygons may have various adjacencies.' do
        expect(shapeE2.touches?(shapeE5)).to be_falsey
      end

      specify 'Two polygons may have various adjacencies.' do
        expect(shapeE1.disjoint?(shapeE5)).to be_truthy
      end

      specify 'Two polygons may have various adjacencies.' do
        expect(shapeE2.disjoint?(shapeE5)).to be_truthy
      end

      specify 'Two polygons may have various adjacencies.' do
        expect(shapeE2.disjoint?(shapeE4)).to be_falsey
      end

      specify 'Two different object types have various intersections.' do
        expect(r.factory.projection_factory).to eq(p16_on_a.factory.projection_factory)
      end

      specify 'Two different object types have various intersections.' do
        # Now that these are the same factory the equivalence is the "same"
        expect(r).to eq(p16_on_a)
      end

      specify 'Two different object types have various intersections.' do
        expect(l.geo_object.intersects?(k.geo_object)).to be_truthy
      end

      specify 'Two different object types have various intersections.' do
        expect(l.geo_object.intersects?(e.geo_object)).to be_falsey
      end

      specify 'Two different object types have various intersections.' do
        expect(f.geo_object.geometry_n(0).intersection(f.geo_object.geometry_n(1))).to be_truthy
      end

      specify 'Objects can be related by distance' do
        expect(p17.geo_object.distance(k.geo_object)).to be < p10.geo_object.distance(k.geo_object)
      end

      specify 'Objects can be related by distance' do
        expect(k.near(p1.geo_object, 0)).to be_truthy
      end

      specify 'Objects can be related by distance' do
        expect(k.near(p17.geo_object, 2)).to be_truthy
      end

      specify 'Objects can be related by distance' do
        expect(k.near(p10.geo_object, 5)).to be_falsey
      end

      specify 'Objects can be related by distance' do
        expect(k.far(p1.geo_object, 0)).to be_falsey
      end

      specify 'Objects can be related by distance' do
        expect(k.far(p17.geo_object, 1)).to be_truthy
      end

      specify 'Objects can be related by distance' do
        expect(k.far(p10.geo_object, 5)).to be_truthy
      end

      specify 'Outer Limits' do
        expect(all_items.geo_object.convex_hull()).to eq(convex_hull)
      end
    end

    context 'That GeographicItems provide certain methods.' do
      before {
        geographic_item.point = room2024
        geographic_item.valid?
      }
      specify 'self.geo_object returns stored data' do
        expect(geographic_item.save!).to be_truthy
      end

      specify 'self.geo_object returns stored data' do
        geographic_item.save!
        _geo_id = geographic_item.id
        expect(geographic_item.geo_object).to eq(room2024)
      end

      specify 'self.geo_object returns stored data' do
        geographic_item.save!
        geo_id = geographic_item.id
        expect(GeographicItem.find(geo_id).geo_object).to eq geographic_item.geo_object
      end
    end

    context 'instance methods' do
      specify '#geo_object' do
        expect(geographic_item).to respond_to(:geo_object)
      end

      specify '#contains? - to see if one object is contained by another.' do
        expect(geographic_item).to respond_to(:contains?)
      end

      specify '#within? -  to see if one object is within another.' do
        expect(geographic_item).to respond_to(:within?)
      end

      specify '#distance? - to see how far one object is from another.' do
        expect(geographic_item).to respond_to(:distance?)
      end

      specify '#near' do
        expect(geographic_item).to respond_to(:near)
      end

      specify '#far' do
        expect(geographic_item).to respond_to(:far)
      end

      specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
        expect(k.contains?(p1.geo_object)).to be_truthy
      end

      specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
        expect(e1.contains?(p10.geo_object)).to be_falsey
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(p0.st_npoints).to eq(1)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(a.st_npoints).to eq(4)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(b.st_npoints).to eq(13)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(h.st_npoints).to eq(5)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(f.st_npoints).to eq(4)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(g.st_npoints).to eq(12)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(all_items.st_npoints).to eq(157)
      end

      specify '#st_npoints returns the number of included points for a valid GeoItem' do
        expect(outer_limits.st_npoints).to eq(7)
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(p0.valid_geometry?).to be_truthy
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(a.valid_geometry?).to be_truthy
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(b.valid_geometry?).to be_truthy
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(h.valid_geometry?).to be_truthy
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(f.valid_geometry?).to be_truthy
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(g.valid_geometry?).to be_truthy
      end

      specify '#valid_geometry? returns \'true\' for a valid GeoObject' do
        expect(all_items.valid_geometry?).to be_truthy
      end

      specify '#st_centroid returns a lat/lng of the centroid of the GeoObject' do
        expect(new_box_a.st_centroid).to eq('POINT(5 5)')
      end

      specify '#center_coords' do
        expect(new_box_a.center_coords).to eq(['5.000000', '5.000000'])
      end

      context '#shape on new' do
        let(:object) { GeographicItem.new }
        # '[40.190063612251016, -111.58300638198853]'
        specify 'for point' do
          object.shape = '{"type":"Feature","geometry":{"type":"Point",' \
            '"coordinates":[-88.0975631475394,40.45993808344767]},' \
            '"properties":{"name":"Paxton City Hall"}}'
          expect(object.valid?).to be_truthy
        end

        specify 'for polygon' do
          object.shape = '{"type":"Feature","geometry":{"type":"Polygon",' \
            '"coordinates":[[[-90.25122106075287,38.619731572825145],[-86.12036168575287,39.77758382625017],' \
            '[-87.62384042143822,41.89478088863241],[-90.25122106075287,38.619731572825145]]]},"properties":{}}'
          expect(object.valid?).to be_truthy
        end

        specify 'for linestring' do
          object.shape = '{"type":"Feature","geometry":{"type":"LineString","coordinates":[' \
                          '[-90.25122106075287,38.619731572825145],' \
                          '[-86.12036168575287,39.77758382625017],' \
                          '[-87.62384042143822,41.89478088863241]]},"properties":{}}'
          expect(object.valid?).to be_truthy
        end

        specify 'for circle' do
          object.shape = '{"type":"Feature","geometry":{"type":"Point",' \
            '"coordinates":[-88.09681320155505,40.461195702960666]},' \
            '"properties":{"radius":1468.749413840412, "name":"Paxton City Hall"}}'
          expect(object.valid?).to be_truthy
        end
      end

      context '#centroid' do
        specify 'for point' do
          expect(r2024.centroid.to_s).to eq('POINT (-88.241413 40.091655 0.0)')
        end

        specify 'for line_string' do
          expect(c1.centroid.to_s).to eq('POINT (16.4614536801933 19.2769570914595 0.0)')
        end

        specify 'for polygon' do
          expect(b.centroid.to_s).to eq('POINT (-8.09134615384615 16.6666666666667 0.0)')
        end

        specify 'for multi_point' do
          expect(h.centroid.to_s).to eq('POINT (5.0 -15.74 0.0)')
        end

        specify 'for multi_line_string' do
          expect(c.centroid.to_s).to eq('POINT (16.5387567713192 15.3001668707456 0.0)')
        end

        specify 'for multi_polygon' do
          expect(g.centroid.to_s).to eq('POINT (21.1264542235711 -3.05523520485584 0.0)')
        end

        specify 'for geometry_collection' do
          expect(j.centroid.to_s).to eq('POINT (21.1264542235711 -3.05523520485584 0.0)')
        end
      end
    end

    context 'class methods' do

      specify '::geometry_sql' do
        test = 'select geom_alias_tbl.polygon::geometry from geographic_items geom_alias_tbl ' \
                'where geom_alias_tbl.id = 2'
        expect(GeographicItem.geometry_sql(2, :polygon)).to eq(test)
      end

      specify '::ordered_by_shortest_distance_from to specify ordering of found objects.' do
        expect(GeographicItem).to respond_to(:ordered_by_shortest_distance_from)
      end

      specify '::ordered_by_longest_distance_from' do
        expect(GeographicItem).to respond_to(:ordered_by_longest_distance_from)
      end

      specify '::disjoint_from to find all objects which are disjoint from an \'and\' list of objects.' do
        expect(GeographicItem).to respond_to(:disjoint_from)
      end

      specify '::within_radius_of_item to find all objects which are within a specific ' \
              'distance of a geographic item.' do
        expect(GeographicItem).to respond_to(:within_radius_of_item)
      end

      specify '::intersecting method to intersecting an \'or\' list of objects.' do
        expect(GeographicItem).to respond_to(:intersecting)
      end

      specify '::containing_sql' do
        test1 = 'ST_Contains(polygon::geometry, (select geom_alias_tbl.point::geometry from ' \
                "geographic_items geom_alias_tbl where geom_alias_tbl.id = #{p1.id}))"
        expect(GeographicItem.containing_sql('polygon',
                                             p1.to_param, p1.geo_object_type)).to eq(test1)
      end

      specify '::eval_for_type' do
        expect(GeographicItem.eval_for_type('polygon')).to eq('GeographicItem::Polygon')
      end

      specify '::eval_for_type' do
        expect(GeographicItem.eval_for_type('linestring')).to eq('GeographicItem::LineString')
      end

      specify '::eval_for_type' do
        expect(GeographicItem.eval_for_type('point')).to eq('GeographicItem::Point')
      end

      specify '::eval_for_type' do
        expect(GeographicItem.eval_for_type('other_thing')).to eq(nil)
      end

      context 'scopes (GeographicItems can be found by searching with) ' do
        before {
          [ce_a, ce_b, gr_a, gr_b].each
        }

        specify '::geo_with_collecting_event' do
          expect(GeographicItem.geo_with_collecting_event.to_a).to include(p_a, p_b) #
        end

        specify '::geo_with_collecting_event' do
          expect(GeographicItem.geo_with_collecting_event.to_a).not_to include(e4)
        end

        specify '::err_with_collecting_event' do
          expect(GeographicItem.err_with_collecting_event.to_a).to include(new_box_a, err_b) #
        end

        specify '::err_with_collecting_event' do
          expect(GeographicItem.err_with_collecting_event.to_a).not_to include(g, p17)
        end

        specify '::with_collecting_event_through_georeferences' do
          expect(GeographicItem.with_collecting_event_through_georeferences.order('id').to_a)
            .to contain_exactly(new_box_a, p_a, p_b, err_b) #
        end

        specify '::with_collecting_event_through_georeferences' do
          expect(GeographicItem.with_collecting_event_through_georeferences.order('id').to_a)
            .not_to include(e4)
        end

        specify '::include_collecting_event' do
          expect(GeographicItem.include_collecting_event.to_a)
            .to include(new_box_b, new_box_a, err_b, p_a, p_b, new_box_e)
        end

        context '::containing' do
          before { [k, l, b, b1, b2, e1].each }

          specify 'find the polygon containing the points' do
            expect(GeographicItem.containing(p1.id).to_a).to contain_exactly(k)
          end

          specify 'find the polygon containing all three points' do
            expect(GeographicItem.containing(p1.id, p2.id, p3.id).to_a).to contain_exactly(k)
          end

          specify 'find that a line string can contain a point' do
            expect(GeographicItem.containing(p4.id).to_a).to contain_exactly(l)
          end

          specify 'point in two polygons, but not their intersection' do
            expect(GeographicItem.containing(p18.id).to_a).to contain_exactly(b1, b2)
          end

          specify 'point in two polygons, one with a hole in it' do
            expect(GeographicItem.containing(p19.id).to_a).to contain_exactly(b1, b)
          end
        end

        context '::are_contained_in - returns objects which contained in another object.' do
          before { [e1, k].each }

          # OR!
          specify 'three things inside and one thing outside k' do
            expect(GeographicItem.are_contained_in_item('polygon',
                                                        [p1, p2, p3, p11]).to_a)
              .to contain_exactly(e1, k)
          end

          # OR!
          specify 'one thing inside one thing, and another thing inside another thing' do
            expect(GeographicItem.are_contained_in_item('polygon',
                                                        [p1, p11]).to_a)
              .to contain_exactly(e1, k)
          end

          #
          # All these are deprecated for ::containing
          #
          #
          #  expect(GeographicItem.are_contained_in('not_a_column_name', @p1).to_a).to eq([])
          #  expect(GeographicItem.are_contained_in('point', 'Some devious SQL string').to_a).to eq([])

          # specify 'one thing inside k' do
          #   expect(GeographicItem.are_contained_in_item('polygon', @p1).to_a).to eq([@k])
          # end

          # specify 'three things inside k' do
          #   expect(GeographicItem.are_contained_in_item('polygon', [@p1, @p2, @p3]).to_a).to eq([@k])
          # end

          # specify 'one thing outside k' do
          #   expect(GeographicItem.are_contained_in_item('polygon', @p4).to_a).to eq([])
          # end

          # specify ' one thing inside two things (overlapping)' do
          #   expect(GeographicItem.are_contained_in_item('polygon', @p12).to_a.sort).to contain_exactly(@e1, @e2)
          # end

          #  specify 'two things inside one thing, and (1)' do
          #    expect(GeographicItem.are_contained_in_item('polygon', @p18).to_a).to contain_exactly(@b1, @b2)
          #  end

          #  specify 'two things inside one thing, and (2)' do
          #    expect(GeographicItem.are_contained_in_item('polygon', @p19).to_a).to contain_exactly(@b1, @b)
          #  end
        end

        context '::contained_by' do
          before { [p1, p2, p3, p11, p12, k, l].each }

          specify 'find the points in a polygon' do
            expect(GeographicItem.contained_by(k.id).to_a).to contain_exactly(p1, p2, p3, k)
          end

          specify 'find the (overlapping) points in a polygon' do
            overlapping_point = FactoryBot.create(:geographic_item_point, point: point12.as_binary)
            expect(GeographicItem.contained_by(e1.id).to_a).to contain_exactly(p12, overlapping_point, p11, e1)
          end
        end

        context '::are_contained_in_item_by_id - returns objects which contained in another object.' do
          before { [p0, p1, p2, p3, p12, p13, b1, b2, b, e1, e2, k].each }

          specify 'one thing inside k' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon', p1.id).to_a).to eq([k])
          end

          specify 'three things inside k (in array)' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon',
                                                              [p1.id, p2.id, p3.id]).to_a)
              .to eq([k])
          end

          specify 'three things inside k (as seperate parameters)' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon', p1.id,
                                                              p2.id,
                                                              p3.id).to_a)
              .to eq([k])
          end

          specify 'one thing outside k' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon', p4.id).to_a)
              .to eq([])
          end

          specify ' one thing inside two things (overlapping)' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon', p12.id).to_a.sort)
              .to contain_exactly(e1, e2)
          end

          specify 'three things inside and one thing outside k' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon',
                                                              [p1.id, p2.id,
                                                               p3.id, p11.id]).to_a)
              .to contain_exactly(e1, k)
          end

          specify 'one thing inside one thing, and another thing inside another thing' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon',
                                                              [p1.id, p11.id]).to_a)
              .to contain_exactly(e1, k)
          end

          specify 'two things inside one thing, and (1)' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon', p18.id).to_a)
              .to contain_exactly(b1, b2)
          end

          specify 'two things inside one thing, and (2)' do
            expect(GeographicItem.are_contained_in_item_by_id('polygon', p19.id).to_a)
              .to contain_exactly(b1, b)
          end
        end

        context '::is_contained_by - returns objects which are contained by other objects.' do
          before { [b, p0, p1, p2, p3, p11, p12, p13, p18, p19].each }

          specify ' three things inside k' do
            expect(GeographicItem.is_contained_by('any', k).not_including(k).to_a)
              .to contain_exactly(p1, p2, p3)
          end

          specify 'one thing outside k' do
            expect(GeographicItem.is_contained_by('any', p4).not_including(p4).to_a).to eq([])
          end

          specify 'three things inside and one thing outside k' do
            pieces = GeographicItem.is_contained_by('any',
                                                    [e2, k]).not_including([k, e2]).to_a
            expect(pieces).to contain_exactly(p0, p1, p2, p3, p12, p13) # , @p12c

          end

          # other objects are returned as well, we just don't care about them:
          # we want to find p1 inside K, and p11 inside e1
          specify 'one specific thing inside one thing, and another specific thing inside another thing' do
            expect(GeographicItem.is_contained_by('any',
                                                  [e1, k]).to_a)
              .to include(p1, p11)
          end

          specify 'one thing (p19) inside a polygon (b) with interior, and another inside ' \
                  'the interior which is NOT included (p18)' do
            expect(GeographicItem.is_contained_by('any', b).not_including(b).to_a).to eq([p19])
          end

          specify 'three things inside two things. Notice that the outer ring of b ' \
                  'is co-incident with b1, and thus "contained".' do
            expect(GeographicItem.is_contained_by('any',
                                                  [b1, b2]).not_including([b1, b2]).to_a)
              .to contain_exactly(p18, p19, b)
          end

          # other objects are returned as well, we just don't care about them
          # we want to find p19 inside b and b1, but returned only once
          specify 'both b and b1 contain p19, which gets returned only once' do
            expect(GeographicItem.is_contained_by('any',
                                                  [b1, b]).to_a)
              .to include(p19)
          end
        end

        context '::not_including([])' do
          before { [p1, p4, p17, r2024, r2022, r2020, p10].each { |object| object } }

          specify 'drop specifc item[s] from any scope (list of objects.)' do
            # @p2 would have been in the list, except for the exclude
            expect(GeographicItem.not_including([p2])
                     .ordered_by_shortest_distance_from('point', p3)
                     .limit(3).to_a)
              .to eq([p1, p4, p17])
          end

          specify 'drop specifc item[s] from any scope (list of objects.)' do
            # @p2 would *not* have been in the list anyway
            expect(GeographicItem.not_including([p2])
                     .ordered_by_longest_distance_from('point', p3)
                     .limit(3).to_a)
              .to eq([r2024, r2022, r2020])
          end

          specify 'drop specifc item[s] from any scope (list of objects.)' do
            # @r2022 would have been in the list, except for the exclude
            expect(GeographicItem.not_including([r2022])
                     .ordered_by_longest_distance_from('point', p3)
                     .limit(3).to_a)
              .to eq([r2024, r2020, p10])
          end
        end

        # specify '::not_including_self to drop self from any list of objects' do
        #   skip 'construction of scenario'
        # expect(GeographicItem.ordered_by_shortest_distance_from('point', @p7).limit(5)).to_a).to eq([@p2, @p1, @p4])
        # end

        context '::ordered_by_shortest_distance_from' do
          before { [p1, p2, p4, outer_limits, l, f1, e5, e3, e4, h, rooms, f, c, g, e, j].each }

          specify ' orders objects by distance from passed object' do
            expect(GeographicItem.ordered_by_shortest_distance_from('point', p3)
                     .limit(3).to_a)
              .to eq([p2, p1, p4])
          end

          specify ' orders objects by distance from passed object' do
            expect(GeographicItem.ordered_by_shortest_distance_from('line_string', p3)
                     .limit(3).to_a)
              .to eq([outer_limits, l, f1])
          end

          specify ' orders objects by distance from passed object' do
            expect(GeographicItem.ordered_by_shortest_distance_from('polygon', p3)
                     .limit(3).to_a)
              .to eq([e5, e3, e4])
          end

          specify ' orders objects by distance from passed object' do
            expect(GeographicItem.ordered_by_shortest_distance_from('multi_point', p3)
                     .limit(3).to_a)
              .to eq([h, rooms])
          end

          specify ' orders objects by distance from passed object' do
            expect(GeographicItem.ordered_by_shortest_distance_from('multi_line_string', p3)
                     .limit(3).to_a)
              .to eq([f, c])
          end

          specify ' orders objects by distance from passed object' do
            subject = GeographicItem.ordered_by_shortest_distance_from('multi_polygon', p3).limit(3).to_a
            expect(subject[0..1]).to contain_exactly(new_box_e, new_box_b) # Both boxes are at same distance from p3
            expect(subject[2..]).to eq([new_box_a])
          end

          specify ' orders objects by distance from passed object' do
            expect(GeographicItem.ordered_by_shortest_distance_from('geometry_collection', p3)
                     .limit(3).to_a)
              .to eq([e, j])
          end
        end

        context '::ordered_by_longest_distance_from' do
          before {
            [r2024, r2022, r2020, c3, c1, c2, g1, g2, g3, b2, rooms, h, c, f, g, j, e].each
          }

          specify 'orders points by distance from passed point' do
            expect(GeographicItem.ordered_by_longest_distance_from('point', p3).limit(3).to_a)
              .to eq([r2024, r2022, r2020])
          end

          specify 'orders line_strings by distance from passed point' do
            expect(GeographicItem.ordered_by_longest_distance_from('line_string', p3)
                     .limit(3).to_a)
              .to eq([c3, c1, c2])
          end

          specify 'orders polygons by distance from passed point' do
            expect(GeographicItem.ordered_by_longest_distance_from('polygon', p3)
                     .limit(4).to_a)
              .to eq([g1, g2, g3, b2])
          end

          specify 'orders multi_points by distance from passed point' do
            expect(GeographicItem.ordered_by_longest_distance_from('multi_point', p3)
                     .limit(3).to_a)
              .to eq([rooms, h])
          end

          specify 'orders multi_line_strings by distance from passed point' do
            expect(GeographicItem.ordered_by_longest_distance_from('multi_line_string', p3)
                     .limit(3).to_a)
              .to eq([c, f])
          end

          specify 'orders multi_polygons by distance from passed point' do
            # existing multi_polygons: [new_box_e, new_box_a, new_box_b, g]
            # new_box_e is excluded, because p3 is *exactly* the same distance from new_box_e, *and* new_box_a
            # This seems to be the reason these two objects *might* be in either order. Thus, one of the two
            # is excluded to prevent it from confusing the order (farthest first) of the appearance of the objects.
            expect(GeographicItem.ordered_by_longest_distance_from('multi_polygon', p3)
                     .not_including(new_box_e)
                     .limit(3).to_a) # TODO: Limit is being called over an array. Check whether this is a gem/rails bug or we need to update code.
              .to eq([g, new_box_a, new_box_b])
          end

          specify 'orders objects by distance from passed object geometry_collection' do
            expect(GeographicItem.ordered_by_longest_distance_from('geometry_collection', p3)
                     .limit(3).to_a)
              .to eq([j, e])
          end
        end

        context '::disjoint_from' do
          before { [p1].each }

          specify "list of objects (uses 'and')." do
            expect(GeographicItem.disjoint_from('point',
                                                [e1, e2, e3, e4, e5])
                     .order(:id)
                     .limit(1).to_a)
              .to contain_exactly(p_b)
          end
        end

        context '::within_radius_of_item' do
          before { [e2, e3, e4, e5, item_a, item_b, item_c, item_d, k, r2022, r2024, p14].each }

          specify 'returns objects within a specific distance of an object.' do
            pieces = GeographicItem.within_radius_of_item(p0.id, 1000000)
                       .where(type: ['GeographicItem::Polygon'])
            expect(pieces).to contain_exactly(err_b, e2, e3, e4, e5, item_a, item_b, item_c, item_d)
          end

          specify '::within_radius_of_item("any", ...)' do
            expect(GeographicItem.within_radius_of_item(p0.id, 1000000))
              .to include(e2, e3, e4, e5, item_a, item_b, item_c, item_d)
          end

          specify "::intersecting list of objects (uses 'or')" do
            expect(GeographicItem.intersecting('polygon', [l])).to eq([k])
          end

          specify "::intersecting list of objects (uses 'or')" do
            expect(GeographicItem.intersecting('polygon', [f1]))
              .to eq([]) # Is this right?
          end

          specify '::select_distance_with_geo_object provides an extra column called ' \
                '\'distance\' to the output objects' do
            result = GeographicItem.select_distance_with_geo_object('point', r2020)
                       .limit(3).order('distance')
                       .where_distance_greater_than_zero('point', r2020).to_a
            # get back these three points
            expect(result).to eq([r2022, r2024, p14])
          end

          specify '::select_distance_with_geo_object provides an extra column called ' \
                '\'distance\' to the output objects' do
            result = GeographicItem.select_distance_with_geo_object('point', r2020)
                       .limit(3).order('distance')
                       .where_distance_greater_than_zero('point', r2020).to_a
            # 5 meters
            expect(result.first.distance).to be_within(0.1).of(5.008268179)
          end

          specify '::select_distance_with_geo_object provides an extra column called ' \
                '\'distance\' to the output objects' do
            result = GeographicItem.select_distance_with_geo_object('point', r2020)
                       .limit(3).order('distance')
                       .where_distance_greater_than_zero('point', r2020).to_a
            # 10 meters
            expect(result[1].distance).to be_within(0.1).of(10.016536381)
          end

          specify '::select_distance_with_geo_object provides an extra column called ' \
                '\'distance\' to the output objects' do
            result = GeographicItem.select_distance_with_geo_object('point', r2020)
                       .limit(3).order('distance')
                       .where_distance_greater_than_zero('point', r2020).to_a
            # 5,862 km (3,642 miles)
            expect(result[2].distance).to be_within(0.1).of(5862006.0029975)
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(p0)).to be_truthy
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(a)).to be_truthy
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(b)).to be_truthy
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(h)).to be_truthy
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(f)).to be_truthy
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(g)).to be_truthy
          end

          specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
            expect(GeographicItem.with_is_valid_geometry_column(all_items)).to be_truthy
          end
        end

        context 'distance to others' do
          specify 'slow' do
            expect(p1.st_distance(p2.id)).to be_within(0.1).of(497835.8972059313)
          end

          specify 'fast' do
            expect(p1.st_distance_spheroid(p2.id)).to be_within(0.1).of(479988.253998808)
          end
        end
      end

      context '::gather_geographic_area_or_shape_data' do
        specify 'collection_objetcs' do

        end
        specify 'asserted_distribution' do

        end
      end
    end
  end # end using ce_test_objects

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
