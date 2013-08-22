require 'spec_helper'

describe GeographicItem do

  let(:spherical_factory) { ::RGeo::Geographic.spherical_factory(:srid => 4326)}
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
        geographic_item.point = spherical_factory.point(-88.241413, 40.091655)
        expect(geographic_item.valid?).to be_true
      end

      specify 'A good point that didn\'t change.' do
        geographic_item.point = spherical_factory.point(-88.241413, 40.091655)
        expect(geographic_item.point.x).to eq -88.241413
      end

      specify 'One and only one of point, line_string, etc. is set.' do
        geographic_item.point = spherical_factory.point(-88.241413, 40.091655)
        geographic_item.polygon = geographic_item.point.buffer(10)
        expect(geographic_item.valid?).to be_false
      end

      specify 'A good point that didn\'t change.' do
        geographic_item.point = spherical_factory.point(-88.241413, 40.091655)
        expect(geographic_item.point.x).to eq -88.241413
      end

    end
  end

  context 'Geographical objects calculations.' do
    before do
      ls = spherical_factory.line_string([spherical_factory.point(0, 0),
                                            spherical_factory.point(10, 0),
                                            spherical_factory.point(10, 10),
                                            spherical_factory.point(0, 10),
                                            spherical_factory.point(0, 0)])

      square = spherical_factory.polygon(ls)

      point_in = spherical_factory.point(5, 5)
      point_out = spherical_factory.point(15, 15)

      @s = GeographicItem.new
      @s.polygon = square
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
      p1 = spherical_factory.point(-88.241413, 40.091655)
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

