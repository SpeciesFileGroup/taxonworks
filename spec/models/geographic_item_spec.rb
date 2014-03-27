require 'spec_helper'

describe GeographicItem do
  before(:all) {
    prep
    gen_wkt_files
  }

  after(:all) {
    GeographicItem.destroy_all
  }

  #let(:FFI_FACTORY) { ::RGeo::Geographic.FFI_FACTORY(:srid => 4326)}
  #let(:FFI_FACTORY) { ::RGeo::Geos.factory(:srid             => 4326,
  #                                        :has_z_coordinate => true,
  #                                        :has_m_coordinate => false) }
  let(:geographic_item) { FactoryGirl.build(:geographic_item) }
  let(:geographic_item_with_point_a) { FactoryGirl.build(:geographic_item_with_point_a) }
  let(:geographic_item_with_point_b) { FactoryGirl.build(:geographic_item_with_point_b) }
  let(:geographic_item_with_point_c) { FactoryGirl.build(:geographic_item_with_point_c) }
  let(:geographic_item_with_line_string) { FactoryGirl.build(:geographic_item_with_line_string) }
  let(:geographic_item_with_polygon) { FactoryGirl.build(:geographic_item_with_polygon) }

=begin
  context 'database functions' do

    specify 'ST_Geometry_Same' do
      pending
      #expect(GeographicItem.same(geographic_item_with_line_string.geo_object,
      #                           geographic_item_with_line_string.geo_object)).to be_true
      #expect(GeographicItem.same(geographic_item_with_line_string.geo_object,
      #                           geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Area' do
      pending
      #expect(GeographicItem.area(geographic_item_with_polygon.geo_object)).to eq 0.123
    end

    specify 'ST_Azimuth' do
      pending
      #expect(GeographicItem.azimuth(geographic_item_with_point_a.geo_object,
      #                              geographic_item_with_point_b.geo_object)).to eq 44.5
      #expect(GeographicItem.azimuth(geographic_item_with_point_b.geo_object,
      #                              geographic_item_with_point_a.geo_object)).to eq 44.5
      #expect(GeographicItem.azimuth(geographic_item_with_point_a.geo_object,
      #                              geographic_item_with_point_a.geo_object)).to eq 44.5
    end

    specify 'ST_Centroid' do
      pending
      #expect(GeographicItem.centroid(geographic_item_with_polygon.polygon)).to eq geographic_item_with_point_c
    end

    specify 'ST_Contains' do
      pending
      #expect(GeographicItem.contains(geographic_item_with_polygon.geo_object,
      #                               geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.contains(geographic_item_with_point_c.geo_object,
      #                               geographic_item_with_polygon.geo_object)).to be_false
      #expect(GeographicItem.contains(geographic_item_with_polygon.geo_object,
      #                               geographic_item_with_polygon.geo_object)).to be_true
    end

    specify 'self.find_contains ' do
      pending 'building a City of Champaign shape, and a point inside it'
    end

    specify 'ST_ContainsProperly ' do
      pending
      #expect(GeographicItem.contains_properly(geographic_item_with_polygon.geo_object,
      #                                        geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.contains_properly(geographic_item_with_point_c.geo_object,
      #                                        geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Covers' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_CoveredBy' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Crosses' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_LineCrossingDirection' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Disjoint' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Distance' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

  end
=end

  context 'validation' do
    before(:each) {
      geographic_item.valid?
    }

    specify 'some data must be provided' do
      expect(geographic_item.errors.keys).to include(:point)
    end

    specify 'invalid data for point is invalid' do
      geographic_item.point = 'Some string'
      expect(geographic_item.valid?).to be_false
    end

    specify 'a valid point is valid' do
      expect(geographic_item_with_point_a.valid?).to be_true
    end

    specify 'A good point that didn\'t change.' do
      expect(geographic_item_with_point_a.point.x).to eq -88.241413
    end

    specify 'One and only one of point, line_string, etc. is set.' do
      geographic_item_with_point_a.polygon = geographic_item_with_point_a.point.buffer(10)
      expect(geographic_item_with_point_a.valid?).to be_false
    end
  end

  context 'when Geographical objects interact.' do
    before do
      #gen_db_objects()
    end

    specify 'Certain line_string shapes cannot be polygons, others can.' do
      @k.reload # can't make a polygon out of a line_string which crosses itself
      @d.reload # can make a (closed) polygon out of a line_string which is either closed, or open

      expect(RSPEC_GEO_FACTORY.polygon(@k.geo_object)).to be_nil
      expect(RSPEC_GEO_FACTORY.polygon(@d.geo_object).to_s).not_to be_nil
    end

    specify 'That one object contains another, or not.' do
      expect(@k.contains?(@p1)).to be_true
      expect(@k.contains?(@p17)).to be_false

      expect(@p1.within?(@k)).to be_true
      expect(@p17.within?(@k)).to be_false
    end

    specify 'Two polygons may have various intersections.' do

      @e.reload
      e0      = @e.geo_object # a collection of polygons
      shapeE1 = e0.geometry_n(0)
      shapeE2 = e0.geometry_n(1)
      shapeE3 = e0.geometry_n(2)
      shapeE4 = e0.geometry_n(3)
      shapeE5 = e0.geometry_n(4)

      expect(shapeE1.intersects?(shapeE2)).to be_true
      expect(shapeE1.intersects?(shapeE3)).to be_false

      expect(shapeE1.overlaps?(shapeE2)).to be_true
      expect(shapeE1.overlaps?(shapeE3)).to be_false

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

      expect(shapeE1.touches?(shapeE5)).to be_false
      expect(shapeE2.touches?(shapeE3)).to be_true
      expect(shapeE2.touches?(shapeE5)).to be_false

      expect(shapeE1.disjoint?(shapeE5)).to be_true
      expect(shapeE2.disjoint?(shapeE5)).to be_true
      expect(shapeE2.disjoint?(shapeE4)).to be_false
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

      expect(l.intersects?(k)).to be_true
      expect(l.intersects?(e)).to be_false

      expect(f1.intersection(f2)).to be_true
    end

    specify 'Objects can be related by distance' do
      p1  = @p1.geo_object
      p10 = @p10.geo_object
      p17 = @p17.geo_object

      k = @k.geo_object

      expect(p17.distance(k)).to be < p10.distance(k)

      expect(@k.near(@p1, 0)).to be_true
      expect(@k.near(@p17, 2)).to be_true
      expect(@k.near(@p10, 5)).to be_false

      expect(@k.far(@p1, 0)).to be_false
      expect(@k.far(@p17, 1)).to be_true
      expect(@k.far(@p10, 5)).to be_true
    end

    specify 'Outer Limits' do
      everything = @all_items.geo_object
      expect(everything.convex_hull()).to eq(CONVEX_HULL)
    end

  end

  context 'That GeographicItems provide certain methods.' do
    specify 'self.geo_object returns stored data' do
      geographic_item.point = ROOM2024
      expect(geographic_item.save).to be_true
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

  context 'that GeographicItems can be found to respond to an' do
    specify 'instance method to return its object.' do
      expect(geographic_item).to respond_to(:geo_object)
    end

    specify 'instance method to see if one object is contained by another.' do
      expect(geographic_item).to respond_to(:contains?)
    end

    specify 'instance method to see if one object is within another.' do
      expect(geographic_item).to respond_to(:within?)
    end

    specify 'instance method to to see how far one object is from another.' do
      expect(geographic_item).to respond_to(:distance?)
      expect(geographic_item).to respond_to(:near)
      expect(geographic_item).to respond_to(:far)
    end

    specify 'class method to discover orphan records.' do
      expect(GeographicItem).to respond_to(:clean?)
    end

    specify 'class method to delete orphan records.' do
      expect(GeographicItem).to respond_to(:clean!)
    end

    specify 'class method to see if one object contains another.' do
      expect(GeographicItem).to respond_to(:contains?)
    end

    specify 'class method to specify ordering of found objects.' do
      expect(GeographicItem).to respond_to(:ordered_by_shortest_distance_from)
      expect(GeographicItem).to respond_to(:ordered_by_longest_distance_from)
    end

    specify 'class method to find all objects which contain an \'or\' list of objects.' do
      expect(GeographicItem).to respond_to(:containing)
    end

    specify 'class method to find all objects which are disjoint from an \'and\' list of objects.' do
      expect(GeographicItem).to respond_to(:disjoint_from)
    end

    specify 'class method to find all objects which are within a specific distance of an object.' do
      expect(GeographicItem).to respond_to(:meters_away_from)
    end

    specify 'class method to intersecting an \'or\' list of objects.' do
      expect(GeographicItem).to respond_to(:intersecting)
    end

    #specify 'point of Lat/Long' do
    #  p1 = RSPEC_GEO_FACTORY.point(-88.241413, 40.091655, 757)
    #
    #end
  end

  context 'that GeographicItems can be found by searching with a' do

    specify 'class method to find objects which contain another objects.' do

      expect(GeographicItem.containing('not_a_column_name', @p1).to_a).to eq([])
      expect(GeographicItem.containing('point', 'Some devious SQL string').to_a).to eq([])

      # one thing inside k
      expect(GeographicItem.containing('polygon', @p1).to_a).to eq([@k])
      # three things inside k
      expect(GeographicItem.containing('polygon', [@p1, @p2, @p3]).to_a).to eq [@k]
      # one thing outside k
      expect(GeographicItem.containing('polygon', @p4).to_a).to eq([])
      # one thing inside two things (overlapping)
      expect(GeographicItem.containing('polygon', @p12).to_a).to have(2).things
      expect(GeographicItem.containing('polygon', @p12).to_a.sort).to eq([@e1, @e2].sort)
      expect(GeographicItem.containing('polygon', @p12).to_a.sort).to eq([@e2, @e1].sort)
      # three things inside and one thing outside k
      expect(GeographicItem.containing('polygon', [@p1, @p2, @p3, @p11]).to_a).to eq([@e1, @k])
      # one thing inside one thing, and another thing inside another thing
      expect(GeographicItem.containing('polygon', [@p1, @p11]).to_a).to eq([@e1, @k])
      # two things inside one thing, and

      expect(GeographicItem.containing('polygon', @p18).to_a).to eq([@b1, @b2])
      expect(GeographicItem.containing('polygon', @p19).to_a).to eq([@b, @b1])

    end

    specify 'containing_sql' do
      expect(GeographicItem.containing_sql('polygon', @p1)).to eq('ST_Contains(polygon::geometry, ST_GeomFromText(\'srid=4326;POINT (-29.0 -16.0 0.0)\'))')
      expect(GeographicItem.containing_sql('polygon', @p2)).not_to eq('ST_Contains(polygon::geometry, ST_GeomFromText(\'srid=4326;POINT (-29.0 -16.0 0.0)\'))')
    end

    specify 'class method to see if one object contains another.' do

      expect(GeographicItem.contains?(@k, @p1)).to be_true
      expect(GeographicItem.contains?(@e1, @p10)).to be_false
    end

    specify 'instance method to see if one object contains another.' do

      expect(@k.contains?(@p1)).to be_true
      expect(@e1.contains?(@p0)).to be_false
    end

    specify 'class method to specify ordering of found objects.' do
      expect(GeographicItem.ordered_by_shortest_distance_from('polygon', @p0)).to eq []
      expect(GeographicItem.ordered_by_longest_distance_from('polygon', @p0)).to eq []
    end

    specify 'class method to find all objects which are disjoint from an \'and\' list of objects.' do
      expect(GeographicItem.disjoint_from('polygon', [@e1, @e2, @e3, @e4, @e5])).to eq [@b]
    end

    specify 'class method to find all objects which are within a specific distance of an object.' do
      expect(GeographicItem.meters_away_from('polygon', @p0, 10)).to eq []
    end

    specify 'class method to find all objects intersecting with an \'or\' list of objects.' do
      expect(GeographicItem.intersecting('polygon', [@l])).to eq [@k]
      expect(GeographicItem.intersecting('polygon', [@f1])).to eq []
    end

  end


  context 'that each type of item knows how to emits its own array' do
    specify 'that represents a point' do
      expect(@r2024.to_a).to eq [-88.241413, 40.091655]
    end

    specify 'that represents a line_string' do
      expect(@a.to_a).to eq [[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]]
    end

    specify 'that represents a polygon' do
      expect(@k.to_a).to eq [[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0], [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]
    end

    specify 'that represents a multi_point' do
      expect(@rooms.to_a).to eq [[-88.241421, 40.091565], [-88.241417, 40.09161], [-88.241413, 40.091655]]
    end

    specify 'that represents a multi_line_string' do
      expect(@c.to_a).to eq [[[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]], [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]], [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]]]
    end

    specify 'that represents a multi_polygon' do
      expect(@g.to_a).to eq [[[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]]]
    end
  end

  context 'that each type of item knows how to emits its own hash' do
    specify 'for a point' do
      expect(@r2024.rendering_hash).to eq(points: [[-88.241413, 40.091655]])
    end

    specify 'for a line_string' do
      expect(@a.rendering_hash).to eq(lines: [[[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]]])
    end

    specify 'for a polygon' do
      expect(@k.rendering_hash).to eq(polygons: [[[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0], [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]])
    end

    specify 'for a multi_point' do
      expect(@rooms.rendering_hash).to eq(points: [[-88.241421, 40.091565], [-88.241417, 40.09161], [-88.241413, 40.091655]])
    end

    specify 'for a multi_line_string' do
      expect(@c.rendering_hash).to eq(lines: [[[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]], [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]], [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]]])
    end

    specify 'for a multi_polygon' do
      expect(@g.rendering_hash).to eq(polygons: [[[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]]])
    end

    specify 'for a geometry_collection' do
      expect(@all_items.rendering_hash[:points]).to eq [
                                                         [3.0, -14.0],
                                                         [6.0, -12.9],
                                                         [5.0, -16.0],
                                                         [4.0, -17.9],
                                                         [7.0, -17.9],
                                                         [3.0, -14.0],
                                                         [6.0, -12.9],
                                                         [5.0, -16.0],
                                                         [4.0, -17.9],
                                                         [7.0, -17.9],
                                                         [-88.241421, 40.091565],
                                                         [-88.241417, 40.09161],
                                                         [-88.241413, 40.091655],
                                                         [0.0, 0.0],
                                                         [-29.0, -16.0],
                                                         [-25.0, -18.0],
                                                         [-28.0, -21.0],
                                                         [-19.0, -18.0],
                                                         [3.0, -14.0],
                                                         [6.0, -12.9],
                                                         [5.0, -16.0],
                                                         [4.0, -17.9],
                                                         [7.0, -17.9],
                                                         [32.2, 22.0],
                                                         [-17.0, 7.0],
                                                         [-9.8, 5.0],
                                                         [-10.7, 0.0],
                                                         [-30.0, 21.0],
                                                         [-25.0, 18.3],
                                                         [-23.0, 18.0],
                                                         [-19.6, -13.0],
                                                         [-7.6, 14.2],
                                                         [-4.6, 11.9],
                                                         [-8.0, -4.0],
                                                         [-4.0, -3.0],
                                                         [-10.0, -6.0]
                                                       ]

      expect(@all_items.rendering_hash[:lines]).to eq [
                                                        [
                                                          [-32.0, 21.0],
                                                          [-25.0, 21.0],
                                                          [-25.0, 16.0],
                                                          [-21.0, 20.0]
                                                        ],
                                                        [
                                                          [23.0, 21.0],
                                                          [16.0, 21.0],
                                                          [16.0, 16.0],
                                                          [11.0, 20.0]
                                                        ],
                                                        [
                                                          [4.0, 12.6],
                                                          [16.0, 12.6],
                                                          [16.0, 7.6]
                                                        ],
                                                        [
                                                          [21.0, 12.6],
                                                          [26.0, 12.6],
                                                          [22.0, 17.6]
                                                        ],
                                                        [
                                                          [-33.0, 11.0],
                                                          [-24.0, 4.0],
                                                          [-26.0, 13.0],
                                                          [-31.0, 4.0],
                                                          [-33.0, 11.0]
                                                        ],
                                                        [
                                                          [-20.0, -1.0],
                                                          [-26.0, -6.0]
                                                        ],
                                                        [
                                                          [-21.0, -4.0],
                                                          [-31.0, -4.0]
                                                        ],
                                                        [
                                                          [27.0, -14.0],
                                                          [18.0, -21.0],
                                                          [20.0, -12.0],
                                                          [25.0, -23.0]
                                                        ],
                                                        [
                                                          [27.0, -14.0],
                                                          [18.0, -21.0],
                                                          [20.0, -12.0],
                                                          [25.0, -23.0]
                                                        ],
                                                        [
                                                          [-16.0, -15.5],
                                                          [-22.0, -20.5]
                                                        ]
                                                      ]

      expect(@all_items.rendering_hash[:polygons]).to eq [
                                                           [
                                                             [-14.0, 23.0],
                                                             [-14.0, 11.0],
                                                             [-2.0, 11.0],
                                                             [-2.0, 23.0],
                                                             [-8.0, 21.0],
                                                             [-14.0, 23.0]
                                                           ],
                                                           [
                                                             [-19.0, 9.0],
                                                             [-9.0, 9.0],
                                                             [-9.0, 2.0],
                                                             [-19.0, 2.0],
                                                             [-19.0, 9.0]
                                                           ],
                                                           [
                                                             [5.0, -1.0],
                                                             [-14.0, -1.0],
                                                             [-14.0, 6.0],
                                                             [5.0, 6.0],
                                                             [5.0, -1.0]
                                                           ],
                                                           [
                                                             [-11.0, -1.0],
                                                             [-11.0, -5.0],
                                                             [-7.0, -5.0],
                                                             [-7.0, -1.0],
                                                             [-11.0, -1.0]
                                                           ],
                                                           [
                                                             [-3.0, -9.0],
                                                             [-3.0, -1.0],
                                                             [-7.0, -1.0],
                                                             [-7.0, -9.0],
                                                             [-3.0, -9.0]
                                                           ],
                                                           [
                                                             [-7.0, -9.0],
                                                             [-7.0, -5.0],
                                                             [-11.0, -5.0],
                                                             [-11.0, -9.0],
                                                             [-7.0, -9.0]
                                                           ],
                                                           [
                                                             [28.0, 2.3],
                                                             [23.0, -1.7],
                                                             [26.0, -4.8],
                                                             [28.0, 2.3]
                                                           ],
                                                           [
                                                             [22.0, -6.8],
                                                             [22.0, -9.8],
                                                             [16.0, -6.8],
                                                             [22.0, -6.8]
                                                           ],
                                                           [
                                                             [16.0, 2.3],
                                                             [14.0, -2.8],
                                                             [18.0, -2.8],
                                                             [16.0, 2.3]
                                                           ],
                                                           [
                                                             [28.0, 2.3],
                                                             [23.0, -1.7],
                                                             [26.0, -4.8],
                                                             [28.0, 2.3]
                                                           ],
                                                           [
                                                             [22.0, -6.8],
                                                             [22.0, -9.8],
                                                             [16.0, -6.8],
                                                             [22.0, -6.8]],
                                                           [
                                                             [16.0, 2.3],
                                                             [14.0, -2.8],
                                                             [18.0, -2.8],
                                                             [16.0, 2.3]
                                                           ],
                                                           [
                                                             [-33.0, -11.0],
                                                             [-33.0, -23.0],
                                                             [-21.0, -23.0],
                                                             [-21.0, -11.0],
                                                             [-27.0, -13.0],
                                                             [-33.0, -11.0]
                                                           ]
                                                         ]

      expect(@all_items.rendering_hash).to eq ({lines: [[[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]], [[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]], [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]], [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]], [[-33.0, 11.0], [-24.0, 4.0], [-26.0, 13.0], [-31.0, 4.0], [-33.0, 11.0]], [[-20.0, -1.0], [-26.0, -6.0]], [[-21.0, -4.0], [-31.0, -4.0]], [[27.0, -14.0], [18.0, -21.0], [20.0, -12.0], [25.0, -23.0]], [[27.0, -14.0], [18.0, -21.0], [20.0, -12.0], [25.0, -23.0]], [[-16.0, -15.5], [-22.0, -20.5]]], points: [[3.0, -14.0], [6.0, -12.9], [5.0, -16.0], [4.0, -17.9], [7.0, -17.9], [3.0, -14.0], [6.0, -12.9], [5.0, -16.0], [4.0, -17.9], [7.0, -17.9], [-88.241421, 40.091565], [-88.241417, 40.09161], [-88.241413, 40.091655], [0.0, 0.0], [-29.0, -16.0], [-25.0, -18.0], [-28.0, -21.0], [-19.0, -18.0], [3.0, -14.0], [6.0, -12.9], [5.0, -16.0], [4.0, -17.9], [7.0, -17.9], [32.2, 22.0], [-17.0, 7.0], [-9.8, 5.0], [-10.7, 0.0], [-30.0, 21.0], [-25.0, 18.3], [-23.0, 18.0], [-19.6, -13.0], [-7.6, 14.2], [-4.6, 11.9], [-8.0, -4.0], [-4.0, -3.0], [-10.0, -6.0]], polygons: [[[-14.0, 23.0], [-14.0, 11.0], [-2.0, 11.0], [-2.0, 23.0], [-8.0, 21.0], [-14.0, 23.0]], [[-19.0, 9.0], [-9.0, 9.0], [-9.0, 2.0], [-19.0, 2.0], [-19.0, 9.0]], [[5.0, -1.0], [-14.0, -1.0], [-14.0, 6.0], [5.0, 6.0], [5.0, -1.0]], [[-11.0, -1.0], [-11.0, -5.0], [-7.0, -5.0], [-7.0, -1.0], [-11.0, -1.0]], [[-3.0, -9.0], [-3.0, -1.0], [-7.0, -1.0], [-7.0, -9.0], [-3.0, -9.0]], [[-7.0, -9.0], [-7.0, -5.0], [-11.0, -5.0], [-11.0, -9.0], [-7.0, -9.0]], [[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]], [[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]], [[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0], [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]]})
    end
  end
end

def build_RGeo_objects()

end

def gen_db_objects()
  #build_RGeo_objects()
  #gen_wkt_files()

  # build the records

  [@a, @b, @c].each do |v|
    # this *does NOT* work the way I want it to!
    v = GeographicItem.new
  end

  @r2020 = GeographicItem.new
  @r2022 = GeographicItem.new
  @r2024 = GeographicItem.new
  @rooms = GeographicItem.new

  @p0  = GeographicItem.new
  @p1  = GeographicItem.new
  @p2  = GeographicItem.new
  @p3  = GeographicItem.new
  @p4  = GeographicItem.new
  @p10 = GeographicItem.new
  @p11 = GeographicItem.new
  @p12 = GeographicItem.new
  @p16 = GeographicItem.new
  @p17 = GeographicItem.new
  @p18 = GeographicItem.new
  @p19 = GeographicItem.new

  @a  = GeographicItem.new
  @b  = GeographicItem.new
  @b1 = GeographicItem.new
  @b2 = GeographicItem.new
  @c  = GeographicItem.new
  @d  = GeographicItem.new
  @e  = GeographicItem.new
  @e1 = GeographicItem.new
  @e2 = GeographicItem.new
  @e3 = GeographicItem.new
  @e4 = GeographicItem.new
  @e5 = GeographicItem.new
  @f  = GeographicItem.new
  @f1 = GeographicItem.new
  @f2 = GeographicItem.new
  @g  = GeographicItem.new
  @h  = GeographicItem.new
  @k  = GeographicItem.new
  @l  = GeographicItem.new

  @all_items = GeographicItem.new

  @outer_limits = GeographicItem.new

  @r2020.point = ROOM2020.as_binary
  @r2022.point = ROOM2022.as_binary
  @r2024.point = ROOM2024.as_binary

  @rooms.multi_point = ROOMS20NN.as_binary
  @p0.point          = POINT0.as_binary
  @p1.point          = POINT1.as_binary
  @p2.point          = POINT2.as_binary
  @p3.point          = POINT3.as_binary
  @p4.point          = POINT4.as_binary
  @p10.point         = POINT10.as_binary
  @p11.point         = POINT11.as_binary
  @p12.point         = POINT12.as_binary
  @p16.point         = POINT16.as_binary
  @p17.point         = POINT17.as_binary
  @p18.point         = POINT18.as_binary
  @p19.point         = POINT19.as_binary

  @a.line_string                 = SHAPE_A.as_binary
  @b.polygon                 = SHAPE_B.as_binary
  @b1.polygon                    = SHAPE_B_OUTER.as_binary
  @b2.polygon                    = SHAPE_B_INNER.as_binary
  @c.multi_line_string           = SHAPE_C.as_binary
  @d.line_string                 = SHAPE_D.as_binary
  @e.geometry_collection         = SHAPE_E.as_binary
  @e1.polygon                    = POLY_E1.as_binary
  @e2.polygon                    = POLY_E2.as_binary
  @e3.polygon                    = POLY_E3.as_binary
  @e4.polygon                    = POLY_E4.as_binary
  @e5.polygon                    = POLY_E5.as_binary
  @f.multi_line_string           = SHAPE_F.as_binary
  @f1.line_string                = SHAPE_F1.as_binary
  @f2.line_string                = SHAPE_F2.as_binary
  @g.multi_polygon               = SHAPE_G.as_binary
  @h.multi_point                 = SHAPE_H.as_binary
  @k.polygon                     = SHAPE_K.as_binary
  @l.line_string                 = SHAPE_L.as_binary
  @all_items.geometry_collection = ALL_SHAPES.as_binary
  @outer_limits.line_string      = CONVEX_HULL.exterior_ring.as_binary

  @r2020.save!
  @r2022.save!
  @r2024.save!
  @rooms.save!

  @p0.save!
  @p1.save!
  @p2.save!
  @p3.save!
  @p4.save!
  @p10.save!
  @p11.save!
  @p12.save!
  @p16.save!
  @p17.save!
  @p18.save!
  @p19.save!

  @a.save!
  @b.save!
  @b1.save!
  @b2.save!
  @c.save!
  @d.save!
  @e.save!
  @e1.save!
  @e2.save!
  @e3.save!
  @e4.save!
  @e5.save!
  @f.save!
  @f1.save!
  @f1.save!
  @g.save!
  @h.save!
  @k.save!
  @l.save!
  @all_items.save!
  @outer_limits.save!
end

def prep
  build_RGeo_objects
  gen_db_objects
end

def gen_wkt_files()
  # using the prebuilt RGeo test objects, write out three QGIS-acceptable WKT files, one each for points, linestrings, and polygons.
  f_point = File.new('./tmp/RGeoPoints.wkt', 'w+')
  f_line  = File.new('./tmp/RGeoLines.wkt', 'w+')
  f_poly  = File.new('./tmp/RGeoPolygons.wkt', 'w+')

  col_header = "id:wkt:name\n"

  f_point.write(col_header)
  f_line.write(col_header)
  f_poly.write(col_header)

  ALL_WKT_NAMES.each_with_index do |it, index|
    wkt  = it[0].as_text
    name = it[1]
    case it[0].geometry_type.type_name
      when 'Point'
        f_type = f_point
      when 'MultiPoint'
        # MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0)
        f_type = $stdout
      when /^Line[S]*/ #when 'Line' or 'LineString'
        f_type = f_line
      when 'MultiLineString'
        # MULTILINESTRING ((-20.0 -1.0 0.0, -26.0 -6.0 0.0), (-21.0 -4.0 0.0, -31.0 -4.0 0.0))
        f_type = $stdout
      when 'Polygon'
        f_type = f_poly
      when 'MultiPolygon'
        # MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0))
        f_type = $stdout
      when 'GeometryCollection'
        # GEOMETRYCOLLECTION (POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), POLYGON ((5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0)), POLYGON ((-11.0 -1.0 0.0, -11.0 -5.0 0.0, -7.0 -5.0 0.0, -7.0 -1.0 0.0, -11.0 -1.0 0.0)), POLYGON ((-3.0 -9.0 0.0, -3.0 -1.0 0.0, -7.0 -1.0 0.0, -7.0 -9.0 0.0, -3.0 -9.0 0.0)), POLYGON ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))
        f_type = $stdout
      else
        f_type = $stdout
      # ignore it for now
    end
    f_type.write("#{index}:#{wkt}: #{name}\n")
  end

  f_point.close
  f_line.close
  f_poly.close
end

def point_methods()
  [:x, :y, :z, :m, :geometry_type, :rep_equals?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
end

def line_string_methods()
  [:length, :start_point, :end_point, :is_closed?, :is_ring?, :num_points, :point_n, :points, :factory, :z_geometry, :m_geometry, :dimension, :geometry_type, :srid, :envelope, :as_text, :as_binary, :is_empty?, :is_simple?, :boundary, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :union, :difference, :sym_difference, :rep_equals?, :-, :+, :*, :_copy_state_from, :marshal_dump, :marshal_load, :encode_with, :init_with]
end

def line_methods()
  [:geometry_type, :length, :num_points, :point_n, :start_point, :end_point, :points, :is_closed?, :is_ring?, :rep_equals?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
end

def linear_ring_methods()
  [:to_i, :to_f, :to_a, :to_h, :&, :|, :^, :to_r, :rationalize, :to_c, :encode_json]
end

def polygon_methods()
  [:geometry_type, :area, :centroid, :point_on_surface, :exterior_ring, :num_interior_rings, :interior_ring_n, :interior_rings, :rep_equals?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
end

def multi_point_methods()
  [:geometry_type, :rep_equals?, :num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
end

def multi_line_string_methods()
  [:geometry_type, :length, :is_closed?, :rep_equals?, :num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
end

def multi_polygon_methods
  [:geometry_type, :area, :centroid, :point_on_surface, :rep_equals?, :num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
end

def collection_methods()
  [:num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :factory, :z_geometry, :m_geometry, :dimension, :geometry_type, :srid, :envelope, :as_text, :as_binary, :is_empty?, :is_simple?, :boundary, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :union, :difference, :sym_difference, :rep_equals?, :-, :+, :*, :_copy_state_from, :marshal_dump, :marshal_load, :encode_with, :init_with]
end
