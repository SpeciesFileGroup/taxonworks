require 'rails_helper'
require_relative '../support/geo/geo'

# include the subclasses, perhaps move this out
Dir[Rails.root.to_s + '/app/models/geographic_item/**/*.rb'].each { |file| require_dependency file }

describe GeographicItem, type: :model, group: :geo do

  let(:geographic_item) { GeographicItem.new }

  before(:all) {
    generate_ce_test_objects 
  }

  after(:all) { 
    clean_slate_geo 
  }

  let(:geographic_item) { FactoryGirl.build(:geographic_item) }
  let(:geographic_item_with_point_a) { FactoryGirl.build(:geographic_item_with_point_a) }
  let(:geographic_item_with_point_b) { FactoryGirl.build(:geographic_item_with_point_b) }
  let(:geographic_item_with_point_c) { FactoryGirl.build(:geographic_item_with_point_c) }
  let(:geographic_item_with_line_string) { FactoryGirl.build(:geographic_item_with_line_string) }
  let(:geographic_item_with_polygon) { FactoryGirl.build(:geographic_item_with_polygon) }
  let(:geographic_item_with_multi_polygon) { FactoryGirl.build(:geographic_item_with_multi_polygon) }

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
          geographic_item.send("#{t}=", SIMPLE_SHAPES[t])
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
      geographic_item.point = SIMPLE_SHAPES[:point]
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

      geographic_item.valid?
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'One and only one of point, line_string, etc. is set.' do
      geographic_item_with_point_a.polygon = geographic_item_with_point_a.point.buffer(10)
      expect(geographic_item_with_point_a.valid?).to be_falsey
    end
  end

  context 'geo_object interactions (Geographical attribute of GeographicItem)' do

    specify 'Certain line_string shapes cannot be polygons, others can.' do
      @k.reload # can't make a polygon out of a line_string which crosses itself
      @d.reload # can make a (closed) polygon out of a line_string which is either closed, or open

      expect(RSPEC_GEO_FACTORY.polygon(@k.geo_object)).to be_nil
      expect(RSPEC_GEO_FACTORY.polygon(@d.geo_object).to_s).not_to be_nil
    end

    specify 'That one object contains another, or not.' do
      expect(@k.contains?(@p1.geo_object)).to be_truthy
      expect(@k.contains?(@p17.geo_object)).to be_falsey

      expect(@p1.within?(@k.geo_object)).to be_truthy
      expect(@p17.within?(@k.geo_object)).to be_falsey
    end

    specify 'Two polygons may have various intersections.' do
      @e.reload
      e0      = @e.geo_object # a collection of polygons
      shapeE1 = e0.geometry_n(0)
      shapeE2 = e0.geometry_n(1)
      shapeE3 = e0.geometry_n(2)
      shapeE4 = e0.geometry_n(3)
      shapeE5 = e0.geometry_n(4)

      expect(shapeE1.intersects?(shapeE2)).to be_truthy
      expect(shapeE1.intersects?(shapeE3)).to be_falsey

      expect(shapeE1.overlaps?(shapeE2)).to be_truthy
      expect(shapeE1.overlaps?(shapeE3)).to be_falsey

      expect(shapeE1.intersection(shapeE2)).to eq(E1_AND_E2)
      expect(shapeE1.intersection(shapeE4)).to eq(E1_AND_E4)

      expect(shapeE1.union(shapeE2)).to eq(E1_OR_E2)
      expect(shapeE1.union(shapeE5)).to eq(E1_OR_E5)
    end

    specify 'Two polygons may have various adjacencies.' do
      e0      = @e.geo_object # a collection of polygons
      shapeE1 = e0.geometry_n(0)
      shapeE2 = e0.geometry_n(1)
      shapeE3 = e0.geometry_n(2)
      shapeE4 = e0.geometry_n(3)
      shapeE5 = e0.geometry_n(4)

      expect(shapeE1.touches?(shapeE5)).to be_falsey
      expect(shapeE2.touches?(shapeE3)).to be_truthy
      expect(shapeE2.touches?(shapeE5)).to be_falsey

      expect(shapeE1.disjoint?(shapeE5)).to be_truthy
      expect(shapeE2.disjoint?(shapeE5)).to be_truthy
      expect(shapeE2.disjoint?(shapeE4)).to be_falsey
    end

    specify 'Two different object types have various intersections.' do
      a   = @a.geo_object
      k   = @k.geo_object
      l   = @l.geo_object
      e   = @e.geo_object
      f   = @f.geo_object
      f1  = f.geometry_n(0)
      f2  = f.geometry_n(1)
      p16 = @p16.geo_object

      expect(a.intersection(p16)).to eq(P16_ON_A)

      # f1crosses2 = RSPEC_FACTORY.parse_wkt("POINT (-23.6 -4.0 0.0)")

      expect(l.intersects?(k)).to be_truthy
      expect(l.intersects?(e)).to be_falsey

      expect(f1.intersection(f2)).to be_truthy
    end

    specify 'Objects can be related by distance' do
      p1  = @p1.geo_object
      p10 = @p10.geo_object
      p17 = @p17.geo_object

      k = @k.geo_object

      expect(p17.distance(k)).to be < p10.distance(k)

      expect(@k.near(@p1.geo_object, 0)).to be_truthy
      expect(@k.near(@p17.geo_object, 2)).to be_truthy
      expect(@k.near(@p10.geo_object, 5)).to be_falsey

      expect(@k.far(@p1.geo_object, 0)).to be_falsey
      expect(@k.far(@p17.geo_object, 1)).to be_truthy
      expect(@k.far(@p10.geo_object, 5)).to be_truthy
    end

    specify 'Outer Limits' do
      everything = @all_items.geo_object
      expect(everything.convex_hull()).to eq(CONVEX_HULL)
    end
  end

  context 'That GeographicItems provide certain methods.' do
    specify 'self.geo_object returns stored data' do
      geographic_item.point = ROOM2024
      expect(geographic_item.save).to be_truthy
      # also 'respond_to'
      # after the save, the default factory type of geographic_item is
      # #<RGeo::Geographic::Factory> and the
      # factory for p1 is #<RGeo::Geos::ZMFactory>, so the two points do not match.
      # See the model for a method to change the default factory for a given
      # column (in our case, all).
      geo_id = geographic_item.id
      expect(geographic_item.geo_object).to eq ROOM2024
      geographic_item.reload
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
      expect(@k.contains?(@p1.geo_object)).to be_truthy
      expect(@e1.contains?(@p10.geo_object)).to be_falsey
    end

    specify '#st_npoints returns the number of included points for a valid GeoItem' do
      expect(@p0.st_npoints).to eq(1)
      expect(@a.st_npoints).to eq(4)
      expect(@b.st_npoints).to eq(13)
      expect(@h.st_npoints).to eq(5)
      expect(@f.st_npoints).to eq(4)
      expect(@g.st_npoints).to eq(12)
      expect(@all_items.st_npoints).to eq(157)
      expect(@outer_limits.st_npoints).to eq(7)
    end

    specify '#is_valid_geometry? returns \'true\' for a valid GeoObject' do
      expect(@p0.is_valid_geometry?).to be_truthy
      expect(@a.is_valid_geometry?).to be_truthy
      expect(@b.is_valid_geometry?).to be_truthy
      expect(@h.is_valid_geometry?).to be_truthy
      expect(@f.is_valid_geometry?).to be_truthy
      expect(@g.is_valid_geometry?).to be_truthy
      expect(@all_items.is_valid_geometry?).to be_truthy
    end

    specify '#st_centroid returns a lat/lng of the centroid of the GeoObject' do
      # select st_centroid('multipoint (-4.0 4.0 0.0, 4.0 4.0 0.0, 4.0 -4.0 0.0, -4.0 -4.0 0.0)');
      expect(@item_d.st_centroid).to eq('POINT(-0 -0)')
    end

    specify '#center_coords' do
      expect(@item_d.center_coords).to eq(["-0", "-0"])
    end

    context '#shape on new' do
      let(:object) { GeographicItem.new }
      # '[40.190063612251016, -111.58300638198853]'
      specify 'for point' do
        object.shape = '{"type":"Feature","geometry":{"type":"Point",' +
          '"coordinates":[-88.0975631475394,40.45993808344767]},' + '"properties":{"name":"Paxton City Hall"}}'
        expect(object.valid?).to be_truthy
      end
      specify 'for polygon' do
        object.shape = '{"type":"Feature","geometry":{"type":"Polygon",' +
          '"coordinates":[[[-90.25122106075287,38.619731572825145],[-86.12036168575287,39.77758382625017],[-87.62384042143822,41.89478088863241],[-90.25122106075287,38.619731572825145]]]},"properties":{}}'
        expect(object.valid?).to be_truthy
      end
      specify 'for linestring' do
        object.shape = '{"type":"Feature","geometry":{"type":"LineString","coordinates":[[-90.25122106075287,38.619731572825145],[-86.12036168575287,39.77758382625017],[-87.62384042143822,41.89478088863241]]},"properties":{}}'
        expect(object.valid?).to be_truthy
      end
      specify 'for circle' do
        object.shape = '{"type":"Feature","geometry":{"type":"Point",' +
          '"coordinates":[-88.09681320155505,40.461195702960666]},' +
          '"properties":{"radius":1468.749413840412, "name":"Paxton City Hall"}}'
        expect(object.valid?).to be_truthy
      end
    end
  end

  context 'class methods' do

    specify '::geometry_sql' do
      test = 'select geom_alias_tbl.polygon::geometry from geographic_items geom_alias_tbl where geom_alias_tbl.id = 2'
      expect(GeographicItem.geometry_sql(2, :polygon)).to eq(test)
    end

    specify '::contains? to see if one object contains another.' do
      expect(GeographicItem).to respond_to(:contains?)
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

    specify '::within_radius_of to find all objects which are within a specific distance of an object.' do
      expect(GeographicItem).to respond_to(:within_radius_of)
    end

    specify '::intersecting method to intersecting an \'or\' list of objects.' do
      expect(GeographicItem).to respond_to(:intersecting)
    end

    specify '::containing_sql' do
      test1 = 'ST_Contains(polygon::geometry, (select geom_alias_tbl.point::geometry from geographic_items geom_alias_tbl where geom_alias_tbl.id = 2))'
      expect(GeographicItem.containing_sql('polygon', @p1.to_param, @p1.geo_object_type)).to eq(test1)
    end

    specify '::eval_for_type' do
      expect(GeographicItem.eval_for_type('polygon')).to eq('GeographicItem::Polygon')
      expect(GeographicItem.eval_for_type('linestring')).to eq('GeographicItem::LineString')
      expect(GeographicItem.eval_for_type('point')).to eq('GeographicItem::Point')
      expect(GeographicItem.eval_for_type('other_thing')).to eq(nil)
    end

    context 'scopes (GeographicItems can be found by searching with) ' do
      # GeographicItem.within_radius(x).excluding(some_gi).with_collecting_event.include_collecting_event.collect{|a| a.collecting_event}
      specify '::geo_with_collecting_event' do
        pieces = GeographicItem.geo_with_collecting_event.order('id').to_a
        expect(pieces.count).to eq(22) # p12 will be listed twice, once for e1, and once for e2
        expect(pieces).to include(@p0.reload, @p1.reload, @p2.reload, @p3.reload,
                                  @p4.reload, @p5.reload, @p6.reload, @p7.reload,
                                  @p8.reload, @p9.reload, @p10.reload, @p11.reload,
                                  @p12.reload, @p13.reload, @p14.reload, @p15.reload,
                                  @p16.reload, @p17.reload, @p18.reload, @p19.reload,
                                  @item_d.reload) #
        expect(pieces).not_to include(@e4.reload)
      end

      specify '::err_with_collecting_event' do
        pieces = GeographicItem.err_with_collecting_event.order('id').to_a
        expect(pieces.count).to eq(10) # @e1, @e2 listed twice, @k listed three times
        expect(pieces).to include(@b2, @b, @e1, @e2, @k, @item_d) #
        expect(pieces).not_to include(@e4, @b1)
      end

      specify '::with_collecting_event_through_georeferences' do
        pieces = GeographicItem.with_collecting_event_through_georeferences.order('id').to_a
        expect(pieces.count).to eq(26) # @k only listed once
        expect(pieces).to include(@p0, @p1, @p2, @p3,
                                  @p4, @p5, @p6, @p7,
                                  @p8, @p9, @p10, @p11,
                                  @p12, @p13, @p14, @p15,
                                  @p16, @p17, @p18, @p19,
                                  @item_d, @e1, @e2, @k) #
        expect(pieces).not_to include(@e4)
      end

      specify '::include_collecting_event' do
        # skip 'construction of method'
        pieces = GeographicItem.include_collecting_event.order('id').to_a
        expect(pieces.count).to eq(60)
        expect(pieces).to eq(@all_gi)
      end

      context '::are_contained_in - returns objects which contained in another object.' do
        #  expect(GeographicItem.are_contained_in('not_a_column_name', @p1).to_a).to eq([])
        #  expect(GeographicItem.are_contained_in('point', 'Some devious SQL string').to_a).to eq([])

        specify 'one thing inside k' do
          expect(GeographicItem.are_contained_in('polygon', @p1).to_a).to eq([@k])
        end

        specify 'three things inside k' do
          expect(GeographicItem.are_contained_in('polygon', [@p1, @p2, @p3]).to_a).to eq([@k])
        end

        specify 'one thing outside k' do
          expect(GeographicItem.are_contained_in('polygon', @p4).to_a).to eq([])
        end

        specify ' one thing inside two things (overlapping)' do
          expect(GeographicItem.are_contained_in('polygon', @p12).to_a.sort).to contain_exactly(@e1, @e2)
        end

        specify 'three things inside and one thing outside k' do
          expect(GeographicItem.are_contained_in('polygon', [@p1, @p2, @p3, @p11]).to_a).to contain_exactly(@e1, @k)
        end

        specify 'one thing inside one thing, and another thing inside another thing' do
          expect(GeographicItem.are_contained_in('polygon', [@p1, @p11]).to_a).to contain_exactly(@e1, @k)
        end

        specify 'two things inside one thing, and (1)' do
          expect(GeographicItem.are_contained_in('polygon', @p18).to_a).to contain_exactly(@b1, @b2)
        end

        specify 'two things inside one thing, and (2)' do
          expect(GeographicItem.are_contained_in('polygon', @p19).to_a).to contain_exactly(@b1, @b)
        end
      end
       
      context  '::is_contained_by - returns objects which are contained by other objects.' do
        specify ' three things inside k' do
          expect(GeographicItem.is_contained_by('any', @k).excluding(@k).to_a).to contain_exactly(@p1, @p2, @p3) 
        end
      
        specify 'one thing outside k' do
          expect(GeographicItem.is_contained_by('any', @p4).excluding(@p4).to_a).to eq([])
        end
        
        specify 'three things inside and one thing outside k' do
         expect(GeographicItem.is_contained_by('any', [@e2, @k]).excluding([@k, @e2]).to_a).to contain_exactly(@p0, @p1, @p2, @p3, @p12, @p13, @item_a)
        end

        xspecify 'one thing inside one thing, and another thing inside another thing' do
          expect(GeographicItem.is_contained_by('any', [@e1, @k]).to_a).to contain_exactly(@p1, @p11) # was 'include', was this the intent?
        end

        specify 'one thing (p19) inside a polygon (b) with interior, and another inside the interior which is NOT included (p18)' do
          expect(GeographicItem.is_contained_by('any', @b).excluding(@b).to_a).to eq([@p19])
        end
        
        specify 'three things inside two things. Notice that the outer ring of b is co-incident with b1, and thus "contained".' do
          expect(GeographicItem.is_contained_by('any', [@b1, @b2]).excluding([@b1, @b2]).to_a).to contain_exactly(@p18, @p19, @b) 
        end
      
        xspecify 'both b and b1 contain p19, which gets returned only once' do
          expect(GeographicItem.is_contained_by('any', [@b1, @b]).to_a).to contain_exactly(@p19) # was 'include', was that the intent?
        end
      end

      specify '::excluding([]) drop specifc item[s] from any scope (list of objects.)' do
        # @p2 would have been in the list, except for the exclude
        expect(GeographicItem.excluding([@p2]).ordered_by_shortest_distance_from('point', @p3).limit(3).to_a).to eq([@p1, @p4, @p17])
        # @p2 would *not* have been in the list anyway
        expect(GeographicItem.excluding([@p2]).ordered_by_longest_distance_from('point', @p3).limit(3).to_a).to eq([@r2024, @r2022, @r2020])
        # @r2022 would  have been in the list, except for the exclude
        expect(GeographicItem.excluding([@r2022]).ordered_by_longest_distance_from('point', @p3).limit(3).to_a).to eq([@r2024, @r2020, @p10])
      end

      # specify '::excluding_self to drop self from any list of objects' do
      #   skip 'construction of scenario'
      # expect(GeographicItem.ordered_by_shortest_distance_from('point', @p7).limit(5)).to_a).to eq([@p2, @p1, @p4])
      # end

      specify '::ordered_by_shortest_distance_from orders objects by distance from passed object' do
        expect(GeographicItem.ordered_by_shortest_distance_from('point', @p3).limit(3).to_a).to eq([@p2, @p1, @p4])
        expect(GeographicItem.ordered_by_shortest_distance_from('line_string', @p3).limit(3).to_a).to eq([@outer_limits, @l, @f1])
        expect(GeographicItem.ordered_by_shortest_distance_from('polygon', @p3).limit(3).to_a).to eq([@e5, @e3, @e4])
        expect(GeographicItem.ordered_by_shortest_distance_from('multi_point', @p3).limit(3).to_a).to eq([@h, @rooms])
        expect(GeographicItem.ordered_by_shortest_distance_from('multi_line_string', @p3).limit(3).to_a).to eq([@f, @c])
        expect(GeographicItem.ordered_by_shortest_distance_from('multi_polygon', @p3).limit(3).to_a).to eq([@g])
        expect(GeographicItem.ordered_by_shortest_distance_from('geometry_collection', @p3).limit(3).to_a).to eq([@e, @j])
      end

      specify '::ordered_by_longest_distance_from orders objects by distance from passed object' do
        expect(GeographicItem.ordered_by_longest_distance_from('point', @p3).limit(3).to_a).to eq([@r2024, @r2022, @r2020])
        expect(GeographicItem.ordered_by_longest_distance_from('line_string', @p3).limit(3).to_a).to eq([@c3, @c1, @c2])
        expect(GeographicItem.ordered_by_longest_distance_from('polygon', @p3).limit(4).to_a).to eq([@g1, @g2, @g3, @b2])
        expect(GeographicItem.ordered_by_longest_distance_from('multi_point', @p3).limit(3).to_a).to eq([@rooms, @h])
        expect(GeographicItem.ordered_by_longest_distance_from('multi_line_string', @p3).limit(3).to_a).to eq([@c, @f])
        expect(GeographicItem.ordered_by_longest_distance_from('multi_polygon', @p3).limit(3).to_a).to eq([@g])
        expect(GeographicItem.ordered_by_longest_distance_from('geometry_collection', @p3).limit(3).to_a).to eq([@j, @e])
      end

      specify "::disjoint_from list of objects (uses 'and')." do
        expect(GeographicItem.disjoint_from('point', [@e1, @e2, @e3, @e4, @e5]).order(:id).limit(1).to_a).to contain_exactly(@p1)
      end

      specify '::within_radius_of returns objects within a specific distance of an object.' do
        expect(GeographicItem.within_radius_of('polygon', @p0, 1000000)).to contain_exactly(@e2, @e3, @e4, @e5, @item_a, @item_b, @item_c, @item_d)
      end

      specify '::within_radius_of("any", ...)' do
        expect(GeographicItem.within_radius_of('any', @p0, 1000000)).to include(@e2, @e3, @e4, @e5, @item_a, @item_b, @item_c, @item_d)
      end

      specify "::intersecting list of objects (uses 'or')" do
        expect(GeographicItem.intersecting('polygon', [@l])).to eq([@k])
        expect(GeographicItem.intersecting('polygon', [@f1])).to eq([]) # Is this right?
      end

      specify '::select_distance_with_geo_object provides an extra column called \'distance\' to the output objects' do
        result = GeographicItem.select_distance_with_geo_object('point', @r2020).limit(3).order('distance').where_distance_greater_than_zero('point', @r2020).to_a
        # get back these three points
        expect(result).to eq([@r2022, @r2024, @p14])
        # 5 meters
        expect(result.first.distance).to be_within(0.1).of(5.008268179)
        # 10 meters
        expect(result[1].distance).to be_within(0.1).of(10.016536381)
        # 5,862 km (3,642 miles)
        expect(result[2].distance).to be_within(0.1).of(5862006.0029975)
      end

      specify '::with_is_valid_geometry_column returns \'true\' for a valid GeoItem' do
        expect(GeographicItem.with_is_valid_geometry_column(@p0)).to be_truthy
        expect(GeographicItem.with_is_valid_geometry_column(@a)).to be_truthy
        expect(GeographicItem.with_is_valid_geometry_column(@b)).to be_truthy
        expect(GeographicItem.with_is_valid_geometry_column(@h)).to be_truthy
        expect(GeographicItem.with_is_valid_geometry_column(@f)).to be_truthy
        expect(GeographicItem.with_is_valid_geometry_column(@g)).to be_truthy
        expect(GeographicItem.with_is_valid_geometry_column(@all_items)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
