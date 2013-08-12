require 'spec_helper'



describe GeoRef do

  let(:m) {::RGeo::Geographic.simple_mercator_factory(:has_z_coordinate => true,
                                                      :has_m_coordinate => true)}
  let(:g1) { GeoRef.new }
  let(:g2) { GeoRef.new }
  let(:g3) { GeoRef.new }

  context "validation" do
    context "requires" do

      g1 = GeoRef.new
      g2 = GeoRef.new
      g3 = GeoRef.new

      m = ::RGeo::Geographic.simple_mercator_factory(
        :has_z_coordinate => true,
        :has_m_coordinate => true
      )
      # -------------------  Long,     Lat,       Z,   M
      g1.a_point = m.point(-88.241413, 40.091655, 757, 2024)
      g2.a_point = m.point(-88.241421, 40.091565, 757, 2020)
      g1.a_polygon = g1.a_point.buffer(1)
      g1.a_line = m.line(g1.a_point, g2.a_point)
      g3.a_point = m.point(
        (g2.a_point.x + ((g1.a_point.x - g2.a_point.x) / 2)),
        (g2.a_point.y + ((g1.a_point.y - g2.a_point.y) / 2)),
        (g2.a_point.z + ((g1.a_point.z - g2.a_point.z) / 2)),
        2022
      )

      g1.save
      g2.save
      g3.save

      before do
        # this code does *not* execute.  Why not?
        g1.a_point = m.point(-88.241413, 40.091655, 757, 2024)
        g1.save
      end
    end

    specify "At least one point or one line or one polygon or one multi_polygon is provided" do
      expect(g1.errors.include?(:cashed_display)).to be_true
    end
  end
end
