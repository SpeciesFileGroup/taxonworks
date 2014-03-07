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
  let(:geographic_item_with_point) { FactoryGirl.build(:geographic_item_with_point) }
  let(:geographic_item_with_line_string) { FactoryGirl.build(:geographic_item_with_line_string) }

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
      expect(geographic_item_with_point.valid?).to be_true
    end

    specify 'A good point that didn\'t change.' do
      expect(geographic_item_with_point.point.x).to eq -88.241413
    end

    specify 'One and only one of point, line_string, etc. is set.' do
      geographic_item_with_point.polygon = geographic_item_with_point.point.buffer(10)
      expect(geographic_item_with_point.valid?).to be_false
    end
  end

  context 'when Geographical objects interact.' do
    before do
      #gen_db_objects()
    end

    specify 'Certain line_string shapes cannot be polygons, others can.' do
      @k.reload # can't make a polygon out of a line_string which crosses itself
      @d.reload # can make a (closed) polygon out of a line_string which is either closed, or open

      expect(GEO_FACTORY.polygon(@k.geo_object)).to be_nil
      expect(GEO_FACTORY.polygon(@d.geo_object).to_s).not_to be_nil
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

      e1and2 = GEO_FACTORY.parse_wkt('POLYGON ((-9.0 6.0 0.0, -9.0 2.0 0.0, -14.0 2.0 0.0, -14.0 6.0 0.0, -9.0 6.0 0.0))')
      e1or2  = GEO_FACTORY.parse_wkt('POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0))')
      e1and4 = GEO_FACTORY.parse_wkt("GEOMETRYCOLLECTION EMPTY")
      e1or5  = GEO_FACTORY.parse_wkt("MULTIPOLYGON (((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))")

      expect(shapeE1.intersects?(shapeE2)).to be_true
      expect(shapeE1.intersects?(shapeE3)).to be_false

      expect(shapeE1.overlaps?(shapeE2)).to be_true
      expect(shapeE1.overlaps?(shapeE3)).to be_false

      expect(shapeE1.intersection(shapeE2)).to eq(e1and2)
      expect(shapeE1.intersection(shapeE4)).to eq(e1and4)

      expect(shapeE1.union(shapeE2)).to eq(e1or2)
      expect(shapeE1.union(shapeE5)).to eq(e1or5)
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

      p16ona = GEO_FACTORY.parse_wkt("POINT (-23.0 18.0 0.0)")
      expect(a.intersection(p16)).to eq(p16ona)

      # f1crosses2 = GEO_FACTORY.parse_wkt("POINT (-23.6 -4.0 0.0)")

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
      everything  = @all_items.geo_object
      convex_hull = GEO_FACTORY.parse_wkt("POLYGON ((-33.0 -23.0 0.0, -88.241421 40.091565 757.0, -88.241413 40.091655 757.0, 32.2 22.0 0.0, 27.0 -14.0 0.0, 25.0 -23.0 0.0, -33.0 -23.0 0.0))")
      expect(everything.convex_hull()).to eq(convex_hull)
    end

  end

  context 'That GeographicItems provide certain methods.' do
    specify 'self.geo_object returns stored data' do
      p1                    = GEO_FACTORY.point(-88.241413, 40.091655, 757)
      geographic_item.point = p1
      expect(geographic_item.save).to be_true
      # also 'respond_to'
      # after the save, the default factory type of geographic_item is
      # #<RGeo::Geographic::Factory> and the
      # factory for p1 is #<RGeo::Geos::ZMFactory>, so the two points do not match.
      # See the model for a method to change the default factory for a given
      # column (in our case, all).
      geo_id = geographic_item.id
      expect(geographic_item.geo_object).to eq p1
      geographic_item.reload
      expect(GeographicItem.find(geo_id).geo_object).to eq geographic_item.geo_object
    end
  end

  context 'that GeographicItems can be found to contain a ' do
    specify 'method to return its object.' do
      expect(geographic_item).to respond_to(:geo_object)
    end

    specify 'method to see if one object is contained by another.' do
      expect(geographic_item).to respond_to(:contains?)
    end

    specify 'method to see if one object is within another.' do
      expect(geographic_item).to respond_to(:within?)
    end

    specify 'method to to see how far one object is from another.' do
      expect(geographic_item).to respond_to(:distance?)
      expect(geographic_item).to respond_to(:near)
      expect(geographic_item).to respond_to(:far)
    end

    specify 'method to find objects which contain another objects.' do
      #expect(geographic_item).to respond_to(:find_containing)
      pending ' construction of intersection finder.'
    end

    specify 'point of Lat/Long' do
      p1                    = GEO_FACTORY.point(-88.241413, 40.091655, 757)

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
  @room2024 = GEO_FACTORY.point(-88.241413, 40.091655, 757)
  @room2020 = GEO_FACTORY.point(-88.241421, 40.091565, 757)
  @room2022 = GEO_FACTORY.point((@room2020.x + ((@room2024.x - @room2020.x) / 2)),
                                (@room2020.y + ((@room2024.y - @room2020.y) / 2)),
                                (@room2020.z + ((@room2024.z - @room2020.z) / 2)))

  @rooms20 = GEO_FACTORY.multi_point([@room2020,
                                      @room2022,
                                      @room2024])

  @point0  = GEO_FACTORY.point(0, 0)
  @point1  = GEO_FACTORY.point(-29, -16)
  @point2  = GEO_FACTORY.point(-25, -18)
  @point3  = GEO_FACTORY.point(-28, -21)
  @point4  = GEO_FACTORY.point(-19, -18)
  @point5  = GEO_FACTORY.point(3, -14)
  @point6  = GEO_FACTORY.point(6, -12.9)
  @point7  = GEO_FACTORY.point(5, -16)
  @point8  = GEO_FACTORY.point(4, -17.9)
  @point9  = GEO_FACTORY.point(7, -17.9)
  @point10 = GEO_FACTORY.point(32.2, 22)
  @point11 = GEO_FACTORY.point(-17, 7)
  @point12 = GEO_FACTORY.point(-9.8, 5)
  @point13 = GEO_FACTORY.point(-10.7, 0)
  @point14 = GEO_FACTORY.point(-30, 21)
  @point15 = GEO_FACTORY.point(-25, 18.3)
  @point16 = GEO_FACTORY.point(-23, 18)
  @point17 = GEO_FACTORY.point(-19.6, -13)
  @point18 = GEO_FACTORY.point(-7.6, 14.2)
  @point19 = GEO_FACTORY.point(-4.6, 11.9)
  @point20 = GEO_FACTORY.point(-8, -4)
  @point21 = GEO_FACTORY.point(-4, -3)
  @point22 = GEO_FACTORY.point(-10, -6)

  @shapeA = GEO_FACTORY.line_string([GEO_FACTORY.point(-32, 21),
                                     GEO_FACTORY.point(-25, 21),
                                     GEO_FACTORY.point(-25, 16),
                                     GEO_FACTORY.point(-21, 20)])

  listB1 = GEO_FACTORY.line_string([GEO_FACTORY.point(-14, 23),
                                    GEO_FACTORY.point(-14, 11),
                                    GEO_FACTORY.point(-2, 11),
                                    GEO_FACTORY.point(-2, 23),
                                    GEO_FACTORY.point(-8, 21)])

  listB2 = GEO_FACTORY.line_string([GEO_FACTORY.point(-11, 18),
                                    GEO_FACTORY.point(-8, 17),
                                    GEO_FACTORY.point(-6, 20),
                                    GEO_FACTORY.point(-4, 16),
                                    GEO_FACTORY.point(-7, 13),
                                    GEO_FACTORY.point(-11, 14)])

  @shapeB = GEO_FACTORY.polygon(listB1, [listB2])

  listC1 = GEO_FACTORY.line_string([GEO_FACTORY.point(23, 21),
                                    GEO_FACTORY.point(16, 21),
                                    GEO_FACTORY.point(16, 16),
                                    GEO_FACTORY.point(11, 20)])

  listC2 = GEO_FACTORY.line_string([GEO_FACTORY.point(4, 12.6),
                                    GEO_FACTORY.point(16, 12.6),
                                    GEO_FACTORY.point(16, 7.6)])

  listC3 = GEO_FACTORY.line_string([GEO_FACTORY.point(21, 12.6),
                                    GEO_FACTORY.point(26, 12.6),
                                    GEO_FACTORY.point(22, 17.6)])

  @shapeC  = GEO_FACTORY.multi_line_string([listC1, listC2, listC3])
  @shapeC1 = @shapeC.geometry_n(0)
  @shapeC2 = @shapeC.geometry_n(1)
  @shapeC3 = @shapeC.geometry_n(2)

  @shapeD = GEO_FACTORY.line_string([GEO_FACTORY.point(-33, 11),
                                     GEO_FACTORY.point(-24, 4),
                                     GEO_FACTORY.point(-26, 13),
                                     GEO_FACTORY.point(-31, 4),
                                     GEO_FACTORY.point(-33, 11)])

  listE1 = GEO_FACTORY.line_string([GEO_FACTORY.point(-19, 9),
                                    GEO_FACTORY.point(-9, 9),
                                    GEO_FACTORY.point(-9, 2),
                                    GEO_FACTORY.point(-19, 2),
                                    GEO_FACTORY.point(-19, 9)])

  listE2 = GEO_FACTORY.line_string([GEO_FACTORY.point(5, -1),
                                    GEO_FACTORY.point(-14, -1),
                                    GEO_FACTORY.point(-14, 6),
                                    GEO_FACTORY.point(5, 6),
                                    GEO_FACTORY.point(5, -1)])

  listE3 = GEO_FACTORY.line_string([GEO_FACTORY.point(-11, -1),
                                    GEO_FACTORY.point(-11, -5),
                                    GEO_FACTORY.point(-7, -5),
                                    GEO_FACTORY.point(-7, -1),
                                    GEO_FACTORY.point(-11, -1)])

  listE4 = GEO_FACTORY.line_string([GEO_FACTORY.point(-3, -9),
                                    GEO_FACTORY.point(-3, -1),
                                    GEO_FACTORY.point(-7, -1),
                                    GEO_FACTORY.point(-7, -9),
                                    GEO_FACTORY.point(-3, -9)])

  listE5 = GEO_FACTORY.line_string([GEO_FACTORY.point(-7, -9),
                                    GEO_FACTORY.point(-7, -5),
                                    GEO_FACTORY.point(-11, -5),
                                    GEO_FACTORY.point(-11, -9),
                                    GEO_FACTORY.point(-7, -9)])

  @shapeE  = GEO_FACTORY.collection([GEO_FACTORY.polygon(listE1), GEO_FACTORY.polygon(listE2), GEO_FACTORY.polygon(listE3), GEO_FACTORY.polygon(listE4), GEO_FACTORY.polygon(listE5)])
  @shapeE1 = @shapeE.geometry_n(0)
  @shapeE2 = @shapeE.geometry_n(1)
  @shapeE3 = @shapeE.geometry_n(2)
  @shapeE4 = @shapeE.geometry_n(3)
  @shapeE5 = @shapeE.geometry_n(4)

  @shapeF1 = GEO_FACTORY.line(GEO_FACTORY.point(-20, -1),
                              GEO_FACTORY.point(-26, -6))

  @shapeF2 = GEO_FACTORY.line(GEO_FACTORY.point(-21, -4),
                              GEO_FACTORY.point(-31, -4))

  @shapeF = GEO_FACTORY.multi_line_string([@shapeF1, @shapeF2])

  listG1 = GEO_FACTORY.line_string([GEO_FACTORY.point(28, 2.3),
                                    GEO_FACTORY.point(23, -1.7),
                                    GEO_FACTORY.point(26, -4.8),
                                    GEO_FACTORY.point(28, 2.3)])

  listG2 = GEO_FACTORY.line_string([GEO_FACTORY.point(22, -6.8),
                                    GEO_FACTORY.point(22, -9.8),
                                    GEO_FACTORY.point(16, -6.8),
                                    GEO_FACTORY.point(22, -6.8)])

  listG3 = GEO_FACTORY.line_string([GEO_FACTORY.point(16, 2.3),
                                    GEO_FACTORY.point(14, -2.8),
                                    GEO_FACTORY.point(18, -2.8),
                                    GEO_FACTORY.point(16, 2.3)])

  @shapeG  = GEO_FACTORY.multi_polygon([GEO_FACTORY.polygon(listG1), GEO_FACTORY.polygon(listG2), GEO_FACTORY.polygon(listG3)])
  @shapeG1 = @shapeG.geometry_n(0)
  @shapeG2 = @shapeG.geometry_n(1)
  @shapeG3 = @shapeG.geometry_n(2)

  @shapeH = GEO_FACTORY.multi_point([@point5,
                                     @point6,
                                     @point7,
                                     @point8,
                                     @point9])

  @shapeI = GEO_FACTORY.line_string([GEO_FACTORY.point(27, -14),
                                     GEO_FACTORY.point(18, -21),
                                     GEO_FACTORY.point(20, -12),
                                     GEO_FACTORY.point(25, -23)])

  @shapeJ = GEO_FACTORY.collection([@shapeG, @shapeH, @shapeI])

  listK = GEO_FACTORY.line_string([GEO_FACTORY.point(-33, -11),
                                   GEO_FACTORY.point(-33, -23),
                                   GEO_FACTORY.point(-21, -23),
                                   GEO_FACTORY.point(-21, -11),
                                   GEO_FACTORY.point(-27, -13)])

  @shapeK = GEO_FACTORY.polygon(listK)

  @shapeL = GEO_FACTORY.line(GEO_FACTORY.point(-16, -15.5),
                             GEO_FACTORY.point(-22, -20.5))

  @everything = GEO_FACTORY.collection([@shapeA,
                                        @shapeB,
                                        @shapeC,
                                        @shapeD,
                                        @shapeE,
                                        @shapeF,
                                        @shapeG,
                                        @shapeH,
                                        @shapeI,
                                        @shapeJ,
                                        @shapeK,
                                        @shapeL,
                                        @rooms20,
                                        @point0,
                                        @point1,
                                        @point2,
                                        @point3,
                                        @point4,
                                        @point5,
                                        @point6,
                                        @point7,
                                        @point8,
                                        @point9,
                                        @point10,
                                        @point11,
                                        @point12,
                                        @point13,
                                        @point14,
                                        @point15,
                                        @point16,
                                        @point17,
                                        @point18,
                                        @point19,
                                        @point20,
                                        @point21,
                                        @point22])

  @convex_hull = @everything.convex_hull()

  @all_wkt_names = [[@convex_hull.exterior_ring, 'Outer Limits'],
                    [@shapeA, 'A'],
                    [@shapeB, 'B'],
                    [@shapeC1, 'C1'],
                    [@shapeC2, 'C2'],
                    [@shapeC3, 'C3'],
                    [@shapeD, 'D'],
                    [@shapeE2, 'E2'],
                    [@shapeE1, 'E1'],
                    [@shapeE3, 'E3'],
                    [@shapeE4, 'E4'],
                    [@shapeE5, 'E5'],
                    [@shapeF1, 'F1'],
                    [@shapeF2, 'F2'],
                    [@shapeG1, 'G1'],
                    [@shapeG2, 'G2'],
                    [@shapeG3, 'G3'],
                    #[@shapeH, 'H'],
                    [@shapeI, 'I'],
                    #[@shapeJ, 'J'],
                    [@shapeK, 'K'],
                    [@shapeL, 'L'],
                    [@room2020, 'Room 2020'],
                    [@room2022, 'Room 2022'],
                    [@room2024, 'Room 2024'],
                    [@point0, 'P0'],
                    [@point1, 'P1'],
                    [@point2, 'P2'],
                    [@point3, 'P3'],
                    [@point4, 'P4'],
                    [@point5, 'P5'],
                    [@point6, 'P6'],
                    [@point7, 'P7'],
                    [@point8, 'P8'],
                    [@point9, 'P9'],
                    [@point10, 'P10'],
                    [@point11, 'P11'],
                    [@point12, 'P12'],
                    [@point13, 'P13'],
                    [@point14, 'P14'],
                    [@point15, 'P15'],
                    [@point16, 'P16'],
                    [@point17, 'P17'],
                    [@point18, 'P18'],
                    [@point19, 'P19'],
                    [@point20, 'P20'],
                    [@point21, 'P21'],
                    [@point22, 'P22']]

end

def gen_db_objects()
  #build_RGeo_objects()
  #gen_wkt_files()

  # build the records

  [@a, @b, @c].each do |v|
    # this *does NOT* work the way I want it to!
    v = GeographicItem.new
  end

  point_in  = @point1
  point_out = @point17

  @r2020 = GeographicItem.new
  @r2022 = GeographicItem.new
  @r2024 = GeographicItem.new
  @rooms = GeographicItem.new

  @p1  = GeographicItem.new
  @p10 = GeographicItem.new
  @p16 = GeographicItem.new
  @p17 = GeographicItem.new

  @a = GeographicItem.new
  @c = GeographicItem.new
  @d = GeographicItem.new
  @e = GeographicItem.new
  @f = GeographicItem.new
  @g = GeographicItem.new
  @h = GeographicItem.new
  @k = GeographicItem.new
  @l = GeographicItem.new

  @all_items = GeographicItem.new

  @outer_limits = GeographicItem.new

  @r2020.point       = @room2020.as_binary
  @r2022.point       = @room2022.as_binary
  @r2024.point       = @room2024.as_binary

  @rooms.multi_point = @rooms20.as_binary
  @p1.point  = point_in.as_binary
  @p10.point = @point10.as_binary
  @p16.point = @point16.as_binary
  @p17.point = point_out.as_binary

  @a.line_string                 = @shapeA.as_binary
  @c.multi_line_string           = @shapeC.as_binary
  @d.line_string                 = @shapeD.as_binary
  @e.geometry_collection         = @shapeE.as_binary
  @f.multi_line_string           = @shapeF.as_binary
  @g.multi_polygon               = @shapeG.as_binary
  @h.multi_point                 = @shapeH.as_binary
  @k.polygon                     = @shapeK.as_binary
  @l.line_string                 = @shapeL.as_binary
  @all_items.geometry_collection = @everything.as_binary
  @outer_limits.line_string      = @convex_hull.exterior_ring.as_binary

  @r2020.save!
  @r2022.save!
  @r2024.save!
  @rooms.save!

  @p1.save!
  @p10.save!
  @p16.save!
  @p17.save!

  @a.save!
  @c.save!
  @d.save!
  @e.save!
  @f.save!
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

  @all_wkt_names.each_with_index do |it, index|
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
