require 'spec_helper'

describe GeographicItem do

  #let(:tw_factory) { ::RGeo::Geographic.tw_factory(:srid => 4326)}
  let(:tw_factory) {::RGeo::Geos.factory(:srid => 4326,
                                         :has_z_coordinate => true,
                                         :has_m_coordinate => true)}
  let(:geographic_item) { GeographicItem.new }

  context 'on creation' do
    context 'on save' do

      before do
        geographic_item.save
      end

      specify 'Errors added because of no data provided.' do
        expect(geographic_item.errors.keys).to include(:point)
      end

      specify 'Fake title' do
        geographic_item.point = 'Some string'
        expect(geographic_item.valid?).to be_false
      end

      specify 'A good point' do
        geographic_item.point = tw_factory.point(-88.241413, 40.091655)
        expect(geographic_item.valid?).to be_true
      end

      specify 'A good point that didn\'t change.' do
        geographic_item.point = tw_factory.point(-88.241413, 40.091655)
        expect(geographic_item.point.x).to eq -88.241413
      end

      specify 'One and only one of point, line_string, etc. is set.' do
        geographic_item.point = tw_factory.point(-88.241413, 40.091655)
        geographic_item.polygon = geographic_item.point.buffer(10)
        expect(geographic_item.valid?).to be_false
      end

      specify 'A good point that didn\'t change.' do
        geographic_item.point = tw_factory.point(-88.241413, 40.091655)
        expect(geographic_item.point.x).to eq -88.241413
      end

    end
  end

  context 'Geographical objects calculations.' do
    before do
      build_the_objects()
      
      point_in = @point1
      point_out = @point17
      
      @s = GeographicItem.new
      @s.polygon = @shapeK
      @p1 = GeographicItem.new
      @p2 = GeographicItem.new
      @p1.point =  point_in
      @p2.point =  point_out


      @s.save!
      @p1.save!
      @p2.save!

    end

    specify 'That one object contains another.' do
      #pending('Requires additional spatial math.')
      expect(@s.contains?(@p1)).to be_true
      expect(@s.contains?(@p2)).to be_false

      expect(@p1.within?(@s)).to be_true
      expect(@p2.within?(@s)).to be_false
    end
  end

  context 'That GeographicItems provide certain methods.' do
    specify 'self.object returns stored data' do
      p1 = tw_factory.point(-88.241413, 40.091655, 757)
      geographic_item.point = p1
      geographic_item.save
      # also 'respond_to'
      # after the save, the factory type of geographic_item is #<RGeo::Geographic::Factory> and the
      # factory for p1 is #<RGeo::Geos::ZMFactory>, to the two points do not match.
      # if we look at the string values, however, we see that the points are the same.
      expect(geographic_item.object.to_s).to eq p1.to_s
    end
  end
end

=begin
      g1 = GeographicItem.new
      g2 = GeographicItem.new
      g3 = GeographicItem.new

      m = ::RGeo::Geographic.simple_mercator_factory(
        :has_z_coordinate => true,
        :has_m_coordinate => true
      )
      # -------------------  Long,     Lat,       Z,   M
      g1.a_point = m.point(-88.241413, 40.091655, 757, 2024)
      g2.a_point = m.point(-88.241421, 40.091565, 757, 2020)
      g3.a_point = m.point(
        (g2.a_point.x + ((g1.a_point.x - g2.a_point.x) / 2)),
        (g2.a_point.y + ((g1.a_point.y - g2.a_point.y) / 2)),
        (g2.a_point.z + ((g1.a_point.z - g2.a_point.z) / 2)),
        2022
      )
      g1.a_polygon = g1.a_point.buffer(1)
      g1.a_simple_line = m.line(g1.a_point, g2.a_point)
      g1.a_complex_line = m.line_string(g1.a_polygon)
      g1.a_linear_ring = m.linear_ring(g1.a_polygon)

      g1.save
      g2.save
      g3.save

      before do
        g1.a_point = m.point(-88.241413, 40.091655, 757, 2024)
        g1.save
      end
=end
=begin
      specify 'At least one point or one line or one polygon or one multi_polygon is provided' do
        expect(geographic_item.errors.include?(:cashed_display)).to be_true
      end
    end
=end

def build_the_objects()

  @tw_factory = ::RGeo::Geos.factory(:srid => 4326, :has_m_coordinate => false, :has_z_coordinate => true)

  @room2024 = @tw_factory.point(-88.241413, 40.091655, 757)
  @room2020 = @tw_factory.point(-88.241421, 40.091565, 757)
  @room2022 = @tw_factory.point((@room2020.x + ((@room2024.x - @room2020.x) / 2)),
                                (@room2020.y + ((@room2024.y - @room2020.y) / 2)),
                                (@room2020.z + ((@room2024.z - @room2020.z) / 2)))

  @point1 = @tw_factory.point(-29, -16)
  @point2 = @tw_factory.point(-25, -18)
  @point3 = @tw_factory.point(-28, -21)
  @point4 = @tw_factory.point(-19, -18)
  @point5 = @tw_factory.point(3, -14)
  @point6 = @tw_factory.point(6, -12.9)
  @point7 = @tw_factory.point(5, -16)
  @point8 = @tw_factory.point(4, -17.9)
  @point9 = @tw_factory.point(7, -17.9)
  @point10 = @tw_factory.point(32.2, 22)
  @point11 = @tw_factory.point(-17, 7)
  @point12 = @tw_factory.point(-9.8, 5)
  @point13 = @tw_factory.point(-10.7, 0)
  @point14 = @tw_factory.point(-32, 21)
  @point15 = @tw_factory.point(-24.9, 18.3)
  @point16 = @tw_factory.point(-22.1, 18.1)
  @point17 = @tw_factory.point(-19.6, -12)
  @point18 = @tw_factory.point(-7.6, 14.2)
  @point19 = @tw_factory.point(-4.6, 11.9)
  @point20 = @tw_factory.point(-8, -4)
  @point21 = @tw_factory.point(-4, -3)
  @point22 = @tw_factory.point(-10, -6)

  @shapeA = @tw_factory.line_string([@tw_factory.point(-32, 21),
                                   @tw_factory.point(-25, 21),
                                   @tw_factory.point(-25, 16),
                                   @tw_factory.point(-20, 20)])

  listB1 = @tw_factory.line_string([@tw_factory.point(-14, 23),
                                    @tw_factory.point(-14, 11),
                                    @tw_factory.point(-2, 11),
                                    @tw_factory.point(-2, 23),
                                    @tw_factory.point(-8, 21)])

  listB2 = @tw_factory.line_string([@tw_factory.point(-11, 18),
                                    @tw_factory.point(-8, 17),
                                    @tw_factory.point(-6, 20),
                                    @tw_factory.point(-4, 16),
                                    @tw_factory.point(-7, 13),
                                    @tw_factory.point(-11, 14)])

  @shapeB = @tw_factory.polygon(listB1, [listB2])

  listC1 = @tw_factory.line_string([@tw_factory.point(23, 44),
                                    @tw_factory.point(16, 44),
                                    @tw_factory.point(16, 39),
                                    @tw_factory.point(11, 43)])

  listC2 = @tw_factory.line_string([@tw_factory.point(4, 12.6),
                                    @tw_factory.point(16, 12.6),
                                    @tw_factory.point(16, 7.6)])

  listC3 = @tw_factory.line_string([@tw_factory.point(21, 12.6),
                                    @tw_factory.point(26, 12.6),
                                    @tw_factory.point(22, 17.6)])

  @shapeC = @tw_factory.multi_line_string([listC1, listC2, listC3])

  @shapeD = @tw_factory.line_string([@tw_factory.point(-33, 11),
                                     @tw_factory.point(-24, 4),
                                     @tw_factory.point(-26, 13),
                                     @tw_factory.point(-31, 4)])

  listE1 = @tw_factory.line_string([@tw_factory.point(-19, 9),
                                    @tw_factory.point(-9, 9),
                                    @tw_factory.point(-9, 2),
                                    @tw_factory.point(-19, 2),
                                    @tw_factory.point(-19, 9)])

  listE2 = @tw_factory.line_string([@tw_factory.point(5, -1),
                                    @tw_factory.point(-14, -1),
                                    @tw_factory.point(-14, 6),
                                    @tw_factory.point(5, 6),
                                    @tw_factory.point(5, -1)])

  listE3 = @tw_factory.line_string([@tw_factory.point(-11, -1),
                                    @tw_factory.point(-11, -5),
                                    @tw_factory.point(-7, -5),
                                    @tw_factory.point(-7, -1),
                                    @tw_factory.point(-11, -1)])

  listE4 = @tw_factory.line_string([@tw_factory.point(-3, -9),
                                    @tw_factory.point(-3, -1),
                                    @tw_factory.point(-7, -1),
                                    @tw_factory.point(-7, -9),
                                    @tw_factory.point(-3, -9)])

  listE5 = @tw_factory.line_string([@tw_factory.point(-7, -9),
                                    @tw_factory.point(-7, -5),
                                    @tw_factory.point(-11, -5),
                                    @tw_factory.point(-11, -9),
                                    @tw_factory.point(-7, -9)])

  @shapeE = @tw_factory.multi_polygon([@tw_factory.polygon(listE1), @tw_factory.polygon(listE2), @tw_factory.polygon(listE3), @tw_factory.polygon(listE4), @tw_factory.polygon(listE5)])
=begin
  @shapeE1 = @shapeE.geometry_n(0)
  @shapeE2 = @shapeE.geometry_n(1)
  @shapeE3 = @shapeE.geometry_n(2)
  @shapeE4 = @shapeE.geometry_n(3)
  @shapeE5 = @shapeE.geometry_n(4)
=end

  @shapeF1 = @tw_factory.line(@tw_factory.point(-23, -1),
                              @tw_factory.point(-29, -6))

  @shapeF2 = @tw_factory.line(@tw_factory.point(-21, -4),
                              @tw_factory.point(-31, -4))

  @shapeF = @tw_factory.multi_line_string([@shapeF1, @shapeF2])

  listG1 = @tw_factory.line_string([@tw_factory.point(28, 2.3),
                                    @tw_factory.point(23, -1.7),
                                    @tw_factory.point(26, -4.8),
                                    @tw_factory.point(28, 2.3)])

  listG2 = @tw_factory.line_string([@tw_factory.point(22, -6.8),
                                    @tw_factory.point(22, -9.8),
                                    @tw_factory.point(16, -6.8),
                                    @tw_factory.point(22, -6.8)])

  listG3 = @tw_factory.line_string([@tw_factory.point(16, 2.3),
                                    @tw_factory.point(14, -2.8),
                                    @tw_factory.point(18, -2.8),
                                    @tw_factory.point(16, 2.3)])

  @shapeG = @tw_factory.multi_polygon([@tw_factory.polygon(listG1), @tw_factory.polygon(listG2), @tw_factory.polygon(listG3)])
  @shapeG1 = @shapeG.geometry_n(0)
  @shapeG2 = @shapeG.geometry_n(1)
  @shapeG3 = @shapeG.geometry_n(2)


  @shapeH = @tw_factory.multi_point([@point5,
                                     @point6,
                                     @point7,
                                     @point8,
                                     @point9])

  @shapeI = @tw_factory.line_string([@tw_factory.point(27, -14),
                                     @tw_factory.point(18, -21),
                                     @tw_factory.point(20, -12),
                                     @tw_factory.point(25, -23)])

  @shapeJ = @tw_factory.collection([@shapeG, @shapeH, @shapeI])

  listK = @tw_factory.line_string([@tw_factory.point(-33, -11),
                                   @tw_factory.point(-33, -23),
                                   @tw_factory.point(-21, -23),
                                   @tw_factory.point(-21, -11),
                                   @tw_factory.point(-27, -13)])


  @shapeK = @tw_factory.polygon(listK)

  @shapeL = @tw_factory.line(@tw_factory.point(-16, -15.5),
                             @tw_factory.point(-22, -20.5))

  @everything = @tw_factory.collection([@point1,
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
                                        @point22,
                                        @shapeA,
                                        @shapeB,
                                        @shapeC,
                                        @shapeD,
=begin
                                        @shapeE,
=end
                                        @shapeF,
                                        @shapeG,
                                        @shapeH,
                                        @shapeI,
                                        @shapeJ,
                                        @shapeK,
                                        @shapeL])

end #.methods - Kernel.methods

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
