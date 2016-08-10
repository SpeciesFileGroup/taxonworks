require 'rails_helper'
require_relative '../../support/geo/build_rspec_geo'

# include the subclasses, perhaps move this out
Dir[Rails.root.to_s + '/app/models/geographic_item/**/*.rb'].each { |file| require_dependency file }

describe GeographicItem, type: :model, group: :geo do

  let(:geographic_item) { GeographicItem.new }

  after(:all) {
    clean_slate_geo
  }

  # For context:
  #   http://gis.stackexchange.com/questions/192218/best-practices-for-databases-and-apis-with-geographic-data-spanning-the-antimeri
  #
  #  THIS: !? ST_Shift_Longitude(geom)
  #
  # Also:
  #   http://gis.stackexchange.com/questions/29975/postgis-incorrect-interpretation-of-a-polygon-that-intersects-the-180th-meridia
  #   http://postgis.net/docs/using_postgis_dbmanagement.html#PostGIS_Geography
  xcontext 'certain known errors ' do

    # this shape is designed to cross the anti-meridian, with a centroid in the Western Hemisphere, around -179.5
    let(:a) { RSPEC_GEO_FACTORY.point(179, 27) }
    let(:b) { RSPEC_GEO_FACTORY.point(-178, 27) }
    let(:c) { RSPEC_GEO_FACTORY.point(-178, 25) }
    let(:d) { RSPEC_GEO_FACTORY.point(179, 25) }

    let(:pre_shape_f_i) { RSPEC_GEO_FACTORY.polygon(pre_line_string_f_i) }

    let(:shape_f_i) { RSPEC_GEO_FACTORY.multi_polygon([pre_shape_f_i]) }

    let(:pre_line_string_f_i) { RSPEC_GEO_FACTORY.line_string([a, b, c, d]) }
    let(:pre_shape_f_i) { RSPEC_GEO_FACTORY.polygon(pre_line_string_f_i) }

    let(:shape_f_i) { RSPEC_GEO_FACTORY.multi_polygon([pre_shape_f_i]) }
    let(:line_string_f_i) { FactoryGirl.create(:geographic_item, line_string: pre_line_string_f_i) }
    let(:item_f_i) { FactoryGirl.create(:geographic_item, polygon: pre_shape_f_i) }

    # let(:far_island_point) { RSPEC_GEO_FACTORY.point(-178.5, 26) }

    let(:far_island_point) { RSPEC_GEO_FACTORY.point(181.5, 26) }

    let(:point_f_i) { FactoryGirl.create(:geographic_item, point: far_island_point) }

    let(:cent) { FactoryGirl.create(:geographic_item, point: item_f_i.st_centroid) }

    let(:x1) { RSPEC_GEO_FACTORY.point(181.5, 26) }
    let(:x2) { RSPEC_GEO_FACTORY.point(-181.5, 26) }

    let(:x1_geographic_item) { FactoryGirl.create(:geographic_item, point: x1) }
    let(:x2_geographic_item) { FactoryGirl.create(:geographic_item, point: x2) }

    context 'points in a box' do
      # two points, one on either side of the anti-meridian
      let(:pre_pos_point) { RSPEC_GEO_FACTORY.point(179.1, 26) }
      let(:pre_neg_point) { RSPEC_GEO_FACTORY.point(-178.1, 26) }

      let(:pre_pos_point_out) { RSPEC_GEO_FACTORY.point(175, 26) }
      let(:pre_neg_point_out) { RSPEC_GEO_FACTORY.point(-175, 26) }

      let(:pre_pos_box_lines) { pre_line_string_f_i }
      let(:pre_neg_box_lines) { RSPEC_GEO_FACTORY.line_string([b, a, d, c]) }

      let(:pos_point) { FactoryGirl.create(:geographic_item, point: pre_pos_point) }
      let(:shape_pos_box) { RSPEC_GEO_FACTORY.polygon(pre_pos_box_lines) }
      let(:pos_box) { FactoryGirl.create(:geographic_item, polygon: shape_pos_box) }

      let(:neg_point) { FactoryGirl.create(:geographic_item, point: pre_neg_point) }
      let(:shape_neg_box) { RSPEC_GEO_FACTORY.polygon(pre_neg_box_lines) }
      let(:neg_box) { FactoryGirl.create(:geographic_item, polygon: shape_neg_box) }

      let(:pos_point_out) { FactoryGirl.create(:geographic_item, point: pre_pos_point_out) }
      let(:neg_point_out) { FactoryGirl.create(:geographic_item, point: pre_neg_point_out) }

      specify 'pos_box contains pos_point' do
        expect(pos_box.contains?(pos_point.geo_object)).to be_truthy
      end

      specify 'pos_box does not contain pos_point_out' do
        expect(pos_box.contains?(pos_point_out.geo_object)).to be_falsey
      end

      specify 'pos_box contains neg_point' do
        expect(pos_box.contains?(neg_point.geo_object)).to be_truthy
      end

      specify 'neg_box contains neg_point' do
        expect(neg_box.contains?(neg_point.geo_object)).to be_truthy
      end

      specify 'neg_box does not contain neg_point_out' do
        expect(neg_box.contains?(neg_point_out.geo_object)).to be_falsey
      end

      specify 'neg_box contains pos_point' do
        expect(neg_box.contains?(pos_point.geo_object)).to be_truthy
      end

      specify 'pos_point is within neg_box' do
        expect(pos_point.within?(neg_box.geo_object)).to be_truthy
      end

      specify 'pos_point is within pos_box' do
        expect(pos_point.within?(pos_box.geo_object)).to be_truthy
      end

      specify 'neg_point is within neg_box' do
        expect(neg_point.within?(neg_box.geo_object)).to be_truthy
      end

      specify 'neg_point is within pos_box' do
        expect(neg_point.within?(pos_box.geo_object)).to be_truthy
      end

      specify 'pos_point_out is not found in pos_box' do

      end
    end

    # note the reload!
    context 'normalizing points' do
      specify '> 180' do
        expect(x1_geographic_item.reload.geo_object.to_s).to eq('POINT (-178.5 26.0 0.0)')
      end

      specify '< -180' do
        expect(x2_geographic_item.reload.geo_object.to_s).to eq('POINT (178.5 26.0 0.0)')
      end
    end

    context 'linestring started in the eastern hemisphere' do

      specify 'rgeo#contains?' do
        expect(pre_shape_f_i.contains?(far_island_point)).to be_truthy
      end

      specify 'rgeo#contains? (> 180)' do
        expect(pre_shape_f_i.contains?(x1)).to be_truthy
      end

      specify '!rgeo#contains? (< -180)' do
        expect(pre_shape_f_i.contains?(x2)).to be_falsey
      end

      context 'first point positive' do
        let(:shape) { RSPEC_GEO_FACTORY.line_string([a, b, c, d]) }
        let(:gi) { FactoryGirl.create(:geographic_item, line_string: shape) }

        specify 'line_string effect' do
          expect(gi.reload.geo_object.to_s).to eq('LINESTRING (179.0 27.0 0.0, -178.0 27.0 0.0, -178.0 25.0 0.0, 179.0 25.0 0.0)')
        end
      end

      specify 'point effect' do
        expect(far_island_point.to_s).to eq('POINT (-178.5 26.0 0.0)')
      end

      specify 'point effect_n' do
        expect(anti_point.to_s).to eq('POINT (178.5 26.0 0.0)')
      end

      specify 'point effect3' do
        expect(GeographicItem.find(point_f_i.id).geo_object.to_s).to eq('POINT (-178.5 26.0 0.0)')
      end

      specify 'point effect2' do
        expect(far_island_point.to_s).to eq('POINT (-178.5 26.0 0.0)')
      end

      specify 'polygon/multi_polygon effect' do
        expect(item_f_i.geo_object.to_s).to eq('MULTIPOLYGON (((179.0 27.0 0.0, -178.0 27.0 0.0, -178.0 25.0 0.0, 179.0 25.0 0.0, 179.0 27.0 0.0)))')
      end

      specify 'centroid effect' do
        expect(cent.geo_object.to_s).to eq('POINT (-179.5 26.0 0.0)')
      end

      context 'finding things' do
        context 'item_f_i should contain point_f_i' do
          specify 'containing, are_contained_in_wkt, are_contained_in_item' do
            expect(GeographicItem.are_contained_in_item('multi_polygon', point_f_i).to_a).to contain_exactly(item_f_i)
          end

          specify '#containing' do
            test1 = GeographicItem.containing(point_f_i.id)
            expect(test1.to_a).to contain_exactly(item_f_i)
          end

          specify '#contained_by_wkt_sql' do
            test2 = GeographicItem.where(GeographicItem.contained_by_wkt_sql(item_f_i.geo_object.to_s))
            expect(test2.to_a).to contain_exactly(item_f_i)
          end
        end

        context 'point_f_i should be contained in item_f_i' do
          specify 'contained_by_wkt_sql' do
            test1 = GeographicItem.where(GeographicItem.contained_by_wkt_sql(item_f_i.geo_object.to_s))
            expect(test1).to contain_exactly(point_f_i)
          end
        end

      end
    end
  end

end
