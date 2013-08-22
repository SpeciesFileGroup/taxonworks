require 'spec_helper'

describe GeographicItem do

  let(:tw_factory) { ::RGeo::Geographic.tw_factory(:srid => 4326)}
  let(:tw_factory) { ::RGeo::Geos.factory(:srid => 4326, 
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
      pending('Requires additional spatial math.')
      #expect(@s.contains?(@p1)).to be_true
      #expect(@s.contains?(@p2)).to be_false
    end
  end

  context 'That GeographicItems provide certain methods.' do
    specify 'self.object returns stored data' do
      p1 = tw_factory.point(-88.241413, 40.091655)
      geographic_item.point = p1
      geographic_item.save
      # also 'respond_to'
      expect(geographic_item.object).to eq p1
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

  @tw_factory = ::RGeo::Geos.factory(:srid => 4326,
                                     :has_z_coordinate => true,
                                     :has_m_coordinate => true)

  @point1 = @tw_factory.point(4, 7)
  @point2 = @tw_factory.point(8, 5)
  @point3 = @tw_factory.point(3, 2)
  @point4 = @tw_factory.point(14, 5)
  @point14 = @tw_factory.point(3, 44)
  @point15 = @tw_factory.point(8, 41.3)
  @point16 = @tw_factory.point(10.9, 41.1)
  @point17 = @tw_factory.point(13.4, 10)
  @point18 = @tw_factory.point(25.4, 37.2)
  @point19 = @tw_factory.point(28.4, 34.9)

  @shapeA = @tw_factory.line_string([@tw_factory.point(1, 44),
                                   @tw_factory.point(8, 44),
                                   @tw_factory.point(8, 39),
                                   @tw_factory.point(13, 43)])

  listB1 = @tw_factory.line_string([@tw_factory.point(19, 46),
                                    @tw_factory.point(19, 34),
                                    @tw_factory.point(31, 34),
                                    @tw_factory.point(31, 46),
                                    @tw_factory.point(25, 44)])

  listB2 = @tw_factory.line_string([@tw_factory.point(22, 41),
                                    @tw_factory.point(25, 40),
                                    @tw_factory.point(27, 43),
                                    @tw_factory.point(29, 39),
                                    @tw_factory.point(26, 36),
                                    @tw_factory.point(22, 37)])

  @shapeB = @tw_factory.polygon(listB1, [listB2])

  listC1 = @tw_factory.line_string([@tw_factory.point(56, 44),
                                    @tw_factory.point(49, 44),
                                    @tw_factory.point(49, 39),
                                    @tw_factory.point(44, 43)])

  listC2 = @tw_factory.line_string([@tw_factory.point(42, 35.5),
                                     @tw_factory.point(49, 35.5),
                                     @tw_factory.point(49, 30.5)])

  listC3 = @tw_factory.line_string([@tw_factory.point(54, 30.5),
                                     @tw_factory.point(59, 30.5),
                                     @tw_factory.point(55, 43)])

  @shapeC = @tw_factory.collection([listC1, listC2, listC3])

  listK = @tw_factory.line_string([@tw_factory.point(0, 12),
                                  @tw_factory.point(0, 0),
                                  @tw_factory.point(12, 0),
                                  @tw_factory.point(12, 12),
                                  @tw_factory.point(6, 10),
                                  @tw_factory.point(0, 12)])

  @shapeK = @tw_factory.polygon(listK)

  @shapeL = @tw_factory.line(@tw_factory.point(17, 7.5),
                           @tw_factory.point(11, 2.5))


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

def collection_methods()
  [:num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :factory, :z_geometry, :m_geometry, :dimension, :geometry_type, :srid, :envelope, :as_text, :as_binary, :is_empty?, :is_simple?, :boundary, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :union, :difference, :sym_difference, :rep_equals?, :-, :+, :*, :_copy_state_from, :marshal_dump, :marshal_load, :encode_with, :init_with]
end
