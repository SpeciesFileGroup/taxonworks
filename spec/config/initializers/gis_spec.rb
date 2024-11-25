require 'rails_helper'

describe 'Gis', type: :model, group: [:geo, :shared_geo] do
  # Spec'ing these since they're undocumented by rgeo and speak to our
  # understanding of rgeo shape creation/interpretation and
  # anti-meridian-crossing behavior (see anti_meridian_spec.rb for more on
  # that).
  context 'Gis::FACTORY' do
    context 'latitudes' do
      specify 'latitudes are clamped to pseudo-mercator range [-85.0511287, 85.0511287]' do
        expect(Gis::FACTORY.point(0, 85.5).lat).to eq(85.0511287)
        expect(Gis::FACTORY.point(0, -85.5).lat).to eq(-85.0511287)
      end

      specify 'valid shapes can become invalid in our factory representation due to latitude clamping' do
        s = Gis::FACTORY.parse_wkt(
          # This gets squished to four points with the same latitude
          'POLYGON ((0 85.5, 10 85.5, 15 85.7, 5 85.7, 0 85.5))'
        )

        expect(s.as_text).to eq(
          'POLYGON ((0.0 85.0511287 0.0, 10.0 85.0511287 0.0, 15.0 85.0511287 0.0, 5.0 85.0511287 0.0, 0.0 85.0511287 0.0))'
        )

        expect(s.valid?).to be false
      end
    end

    context 'longitudes' do
      context 'point coordinate longitudes are NEVER adjusted' do
        specify 'point coordinate longitudes in [-180, 0] are NOT adjusted' do
          expect(Gis::FACTORY.point(-170, 0).lon).to eq(-170)
          expect(Gis::FACTORY.parse_wkt('POINT (-170 0)').lon).to eq(-170)
        end

        specify 'point coordinate longitudes in [180, 360] are NOT adjusted' do
          expect(Gis::FACTORY.point(190, 0).lon).to eq(190)
          expect(Gis::FACTORY.parse_wkt('POINT (190 0)').lon).to eq(190)
        end

        specify 'multipoint coordinate longitudes in [180, 360] are NOT adjusted' do
          s = Gis::FACTORY.parse_wkt('MULTIPOINT ((190 0), (200 0))')
          expect(s.first.lon).to eq(190)
        end
      end

      context 'non-point shape coordinate longitudes ARE converted to the range [-180, 180], i.e. [180, 360] is converted to [-180, 0]' do
        specify 'linestring' do
          expect(
            Gis::FACTORY.parse_wkt('LINESTRING (-170 0, 160 0, 190 10)').as_text
          ).to eq('LINESTRING (-170.0 0.0 0.0, 160.0 0.0 0.0, -170.0 10.0 0.0)')
        end

        specify 'polygon' do
          expect(Gis::FACTORY
            .parse_wkt('POLYGON ((-170 0, 190 10, 175 0, -170 0))').as_text
          ).to eq(
            'POLYGON ((-170.0 0.0 0.0, -170.0 10.0 0.0, 175.0 0.0 0.0, -170.0 0.0 0.0))'
          )
        end
      end

      specify '"Valid" shapes can become invalid due to longitude shifting/interpretation' do
        # Lines between points are NOT always shortest-distance geodesics - see
        # anti_meridian_spec.rb for further details.
        s = Gis::FACTORY.parse_wkt(
          'POLYGON ((-200 -10, -200 10, -160 10, -190 0, -160 -10, -200 -10))'
        )

        # In this case the factory interpretation is that all lines between
        # points in opposite hemispheres cross the meridian, not the
        # anti-meridian, which causes this shape to have a self-intersection.
        expect(s.valid?).to be false
      end
    end
  end
end