require 'rails_helper'

describe GeographicItem, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'

  context 'a column for each shape type' do
    let(:geographic_item) { GeographicItem.new }

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
      g.update(shape: geo_json2)
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
        },
        "properties": {}
      }'

      g = GeographicItem.new(shape: bad)
      g.valid?
      expect(g.errors[:base]).to be_present
    end

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

    specify 'st_covered_by' do
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

  end
=end


    # TODO: remove, redundant with single Factory use
    specify 'Two different object types share the same factory.' do
      # r is the result of an intersection
      # p16 uses the config.default factory
      expect(r.factory.projection_factory).to eq(p16_on_a.factory.projection_factory)
    end

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
        expect(geographic_item.errors[:base]).to be_present
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
        geographic_item_with_point_a.polygon = geographic_item_with_polygon.polygon
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

      specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
        expect(k.contains?(p1.geo_object)).to be_truthy
      end

      specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
        expect(e1.contains?(p10.geo_object)).to be_falsey
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(p0.st_is_valid).to be_truthy
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(a.st_is_valid).to be_truthy
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(b.st_is_valid).to be_truthy
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(h.st_is_valid).to be_truthy
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(f.st_is_valid).to be_truthy
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(g.st_is_valid).to be_truthy
      end

      specify '#st_is_valid returns \'true\' for a valid GeoObject' do
        expect(all_items.st_is_valid).to be_truthy
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
          expect(c1.centroid.to_s).to match(/POINT \(16\.461453\d* 19\.276957\d* 0\.0\)/)
        end

        specify 'for polygon' do
          expect(b.centroid.to_s).to match(/POINT \(-8\.091346\d* 16\.666666\d* 0\.0\)/)
        end

        specify 'for multi_point' do
          expect(h.centroid.to_s).to match(/POINT \(5\.0 -15\.7(4|399999\d*) 0\.0\)/) # TODO: Review the way this is being check (and the others too actually)
        end

        specify 'for multi_line_string' do
          expect(c.centroid.to_s).to match(/POINT \(16\.538756\d* 15\.300166\d* 0\.0\)/)
        end

        specify 'for multi_polygon' do
          expect(g.centroid.to_s).to match(/POINT \(21\.126454\d* -3.055235\d* 0\.0\)/)
        end

        specify 'for geometry_collection' do
          expect(j.centroid.to_s).to match(/POINT \(21\.126454\d* -3\.055235\d* 0\.0\)/)
        end
      end
    end

    context 'class methods' do

      specify '::within_radius_of_item to find all objects which are within a specific ' \
        'distance of a geographic item.' do
          expect(GeographicItem).to respond_to(:within_radius_of_item)
        end

      specify '::intersecting method to intersecting an \'or\' list of objects.' do
        expect(GeographicItem).to respond_to(:intersecting)
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
            expect(GeographicItem.superset_of_union_of(p1.id).to_a).to contain_exactly(k)
          end

          specify 'find the polygon containing all three points' do
            expect(GeographicItem.superset_of_union_of(p1.id, p2.id, p3.id).to_a).to contain_exactly(k)
          end

          specify 'find that a line string can contain a point' do
            expect(GeographicItem.superset_of_union_of(p4.id).to_a).to contain_exactly(l)
          end

          specify 'point in two polygons, but not their intersection' do
            expect(GeographicItem.superset_of_union_of(p18.id).to_a).to contain_exactly(b1, b2)
          end

          specify 'point in two polygons, one with a hole in it' do
            expect(GeographicItem.superset_of_union_of(p19.id).to_a).to contain_exactly(b1, b)
          end
        end

        context '::are_contained_in - returns objects which contained in another object.' do
          before { [p0, p1, p2, p3, p12, p13, b1, b2, b, e1, e2, k].each }

          # OR!
          specify 'three things inside and one thing outside k' do
            expect(GeographicItem.st_covers('polygon',
                                                        [p1, p2, p3, p11]).to_a)
              .to contain_exactly(e1, k)
          end

          # OR!
          specify 'one thing inside one thing, and another thing inside another thing' do
            expect(GeographicItem.st_covers('polygon',
                                                        [p1, p11]).to_a)
              .to contain_exactly(e1, k)
          end

          specify 'one thing inside k' do
            expect(GeographicItem.st_covers('polygon', p1).to_a).to eq([k])
          end

          specify 'three things inside k (in array)' do
            expect(GeographicItem.st_covers('polygon',
                                                              [p1, p2, p3]).to_a)
              .to eq([k])
          end

          specify 'three things inside k (as separate parameters)' do
            expect(GeographicItem.st_covers('polygon', p1,
                                                              p2,
                                                              p3).to_a)
              .to eq([k])
          end

          specify 'one thing outside k' do
            expect(GeographicItem.st_covers('polygon', p4).to_a)
              .to eq([])
          end

          specify ' one thing inside two things (overlapping)' do
            expect(GeographicItem.st_covers('polygon', p12).to_a.sort)
              .to contain_exactly(e1, e2)
          end

          specify 'three things inside and one thing outside k' do
            expect(GeographicItem.st_covers('polygon',
                                                              [p1, p2,
                                                                p3, p11]).to_a)
              .to contain_exactly(e1, k)
          end

          specify 'one thing inside one thing, and another thing inside another thing' do
            expect(GeographicItem.st_covers('polygon',
                                                              [p1, p11]).to_a)
              .to contain_exactly(e1, k)
          end

          specify 'two things inside one thing, and (1)' do
            expect(GeographicItem.st_covers('polygon', p18).to_a)
              .to contain_exactly(b1, b2)
          end

          specify 'two things inside one thing, and (2)' do
            expect(GeographicItem.st_covers('polygon', p19).to_a)
              .to contain_exactly(b1, b)
          end
        end

        context 'contained by' do
          before { [p1, p2, p3, p11, p12, k, l].each }

          specify 'find the points in a polygon' do
            expect(
              GeographicItem.where(
                GeographicItem.subset_of_union_of_sql(k.id)
              ).to_a
            ).to contain_exactly(p1, p2, p3, k)
          end

          specify 'find the (overlapping) points in a polygon' do
            overlapping_point = FactoryBot.create(:geographic_item_point, point: point12.as_binary)
            expect(GeographicItem.where(GeographicItem.subset_of_union_of_sql(e1.id)).to_a).to contain_exactly(p12, overlapping_point, p11, e1)
          end
        end

        context '::is_contained_by - returns objects which are contained by other objects.' do
          before { [b, p0, p1, p2, p3, p11, p12, p13, p18, p19].each }

          specify ' three things inside k' do
            expect(GeographicItem.st_covered_by('any', k).not_including(k).to_a)
              .to contain_exactly(p1, p2, p3)
          end

          specify 'one thing outside k' do
            expect(GeographicItem.st_covered_by('any', p4).not_including(p4).to_a).to eq([])
          end

          specify 'three things inside and one thing outside k' do
            pieces = GeographicItem.st_covered_by('any',
                                                    [e2, k]).not_including([k, e2]).to_a
            # p_a just happens to be in context because it happens to be the
            # GeographicItem of the Georeference g_a defined in an outer
            # context
            expect(pieces).to contain_exactly(p0, p1, p2, p3, p12, p13, p_a) # , @p12c

          end

          # other objects are returned as well, we just don't care about them:
          # we want to find p1 inside K, and p11 inside e1
          specify 'one specific thing inside one thing, and another specific thing inside another thing' do
            expect(GeographicItem.st_covered_by('any',
                                                  [e1, k]).to_a)
              .to include(p1, p11)
          end

          specify 'one thing (p19) inside a polygon (b) with interior, and another inside ' \
            'the interior which is NOT included (p18)' do
              expect(GeographicItem.st_covered_by('any', b).not_including(b).to_a).to eq([p19])
            end

          specify 'three things inside two things. Notice that the outer ring of b ' \
            'is co-incident with b1, and thus "contained".' do
              expect(GeographicItem.st_covered_by('any',
                                                    [b1, b2]).not_including([b1, b2]).to_a)
                .to contain_exactly(p18, p19, b)
            end

          # other objects are returned as well, we just don't care about them
          # we want to find p19 inside b and b1, but returned only once
          specify 'both b and b1 contain p19, which gets returned only once' do
            expect(GeographicItem.st_covered_by('any',
                                                  [b1, b]).to_a)
              .to include(p19)
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
            expect(GeographicItem.intersecting('polygon', [l.id])).to eq([k])
          end

          specify "::intersecting list of objects (uses 'or')" do
            expect(GeographicItem.intersecting('polygon', [f1.id]))
              .to eq([]) # Is this right?
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



end
