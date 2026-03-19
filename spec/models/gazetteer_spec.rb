require 'rails_helper'

RSpec.describe Gazetteer, type: :model, group: [:geo, :shared_geo] do
  let(:gz) { FactoryBot.build(:valid_gazetteer) }

  context 'creation' do
    context 'validation' do
      let!(:gz) { Gazetteer.new}

      specify 'name is required' do
        gz.valid?
        expect(gz.errors.include?(:name)).to be_truthy
      end

      specify 'blank names are invalid' do
        gz.name = ''
        gz.valid?
        expect(gz.errors.include?(:name)).to be_truthy
      end
    end

    context 'create from shapes' do
      let!(:new_gz) { Gazetteer.new(name: 'shapes') }
      let(:poly1_wkt) {
        'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))'
      }
      let(:poly1_gi) {
        FactoryBot.create(:geographic_item, geography: poly1_wkt)
      }
      let(:poly2_wkt) {
        'POLYGON((5 5, 15 5, 15 15, 5 15, 5 5))'
      }
      let(:poly2_gi) {
        FactoryBot.create(:geographic_item, geography: poly2_wkt)
      }
      let(:poly1_intersect_poly2_wkt) {
        'POLYGON((5 5, 10 5, 10 10, 5 10, 5 5))'
      }
      let(:p1_wkt) { 'POINT(0 0)' }
      let(:p2_wkt) { 'POINT(1 1)' }
      let(:p1) { FactoryBot.create(:geographic_item, geography: p1_wkt) }
      let(:p2) { FactoryBot.create(:geographic_item, geography: p2_wkt) }
      let(:ga1) { FactoryBot.create(:valid_geographic_area,
          geographic_areas_geographic_items_attributes: [{geographic_item: poly1_gi}]
        )
      }
      let(:ga2) { FactoryBot.create(:valid_geographic_area,
          geographic_areas_geographic_items_attributes: [{geographic_item: poly2_gi}]
        )
      }
      let(:gz1) { FactoryBot.create(:gazetteer,
          name: 'gz1', geographic_item: poly1_gi
        )
      }
      let(:gz2) { FactoryBot.create(:gazetteer,
          name: 'gz2', geographic_item: poly2_gi
        )
      }

      # Check that a saved Gazetteer spatially covers all input geographic items.
      def covers_all?(gz, *gi_ids)
        gz_gi_id = gz.geographic_item.id
        gi_ids.all? do |gi_id|
          ActiveRecord::Base.connection.select_value(<<~SQL) == true
            SELECT ST_CoveredBy(
              (SELECT geography::geometry FROM geographic_items WHERE id = #{gi_id}),
              (SELECT geography::geometry FROM geographic_items WHERE id = #{gz_gi_id})
            )
          SQL
        end
      end

      # Check that a saved Gazetteer is spatially covered by all input geographic items.
      def covered_by_all?(gz, *gi_ids)
        gz_gi_id = gz.geographic_item.id
        gi_ids.all? do |gi_id|
          ActiveRecord::Base.connection.select_value(<<~SQL) == true
            SELECT ST_CoveredBy(
              (SELECT geography::geometry FROM geographic_items WHERE id = #{gz_gi_id}),
              (SELECT geography::geometry FROM geographic_items WHERE id = #{gi_id})
            )
          SQL
        end
      end

      specify 'create from geojson' do
        shapes = {
          geojson: [poly1_gi.to_geo_json_feature, poly2_gi.to_geo_json_feature]
        }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(covers_all?(new_gz, poly1_gi.id, poly2_gi.id)).to be true
      end

      specify 'create from wkt' do
        shapes = { wkt: [poly1_wkt, poly2_wkt] }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(covers_all?(new_gz, poly1_gi.id, poly2_gi.id)).to be true
      end

      specify 'create from points' do
        shapes = {
          geojson: [p1.to_geo_json_feature, p2.to_geo_json_feature]
        }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(covers_all?(new_gz, p1.id, p2.id)).to be true
      end

      specify 'create from GAs' do
        shapes = { ga_combine: [ga1.id, ga2.id] }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(covers_all?(new_gz, poly1_gi.id, poly2_gi.id)).to be true
      end

      specify 'create from GZs' do
        shapes = { gz_combine: [gz1.id, gz2.id] }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(covers_all?(new_gz, poly1_gi.id, poly2_gi.id)).to be true
      end

      specify 'accepts shapes from multiple sources' do
        shapes = {
          geojson: [poly1_gi.to_geo_json_feature],
          wkt: [poly2_wkt],
          points: [p1.to_geo_json_feature],
          ga_combine: [ga1.id],
          gz_combine: [gz2.id]
        }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(covers_all?(new_gz, poly1_gi.id, poly2_gi.id, p1.id)).to be true
      end

      specify 'supports intersection instead of union' do
        shapes = {
          geojson: [poly1_gi.to_geo_json_feature, poly2_gi.to_geo_json_feature]
        }
        new_gz.build_gi_from_shapes(shapes, false)
        new_gz.save!
        expect(covered_by_all?(new_gz, poly1_gi.id, poly2_gi.id)).to be true
        expect(new_gz.geographic_item.geo_object).not_to be_empty
      end

      specify 'union result has 3D geometry' do
        shapes = { wkt: [poly1_wkt, poly2_wkt] }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(new_gz.geographic_item.geo_object.as_text).to include('0.0')
      end

      specify 'intersection result has 3D geometry' do
        shapes = {
          geojson: [poly1_gi.to_geo_json_feature, poly2_gi.to_geo_json_feature]
        }
        new_gz.build_gi_from_shapes(shapes, false)
        new_gz.save!
        expect(new_gz.geographic_item.geo_object.as_text).to include('0.0')
      end

      context 'union of GAs with near-coincident shared border vertices' do
        # Mimics the floating-point encoding differences observed in real
        # geographic data (e.g. SA/Namibia border: ~1e-14° difference).
        #
        # The shared border is a ridge: south's top goes (0,base_y)→(0.5,peak_y)→(1,base_y)
        # and north's bottom goes (0,base_y+ε)→(0.5,peak_y-ε)→(1,base_y+ε). The ε offsets
        # point in opposite directions at the sides vs. the apex, so the two polylines CROSS
        # (south starts below north at x=0 but ends above at x=0.5). GEOS must compute that
        # crossing to form the union boundary. Floating-point rounding places the crossing ε
        # off from its true position, creating a sliver where ST_CoveredBy(south/north, union)
        # returns false without the COMBINE_BUFFER_DEGREES fix.
        let(:base_y)      { 10.0 }
        let(:peak_y)      { 14.0 }
        let(:base_y_ulp)  { base_y + base_y * Float::EPSILON * 4 }  # slightly above base
        let(:peak_y_ulp)  { peak_y - peak_y * Float::EPSILON * 4 }  # slightly below peak

        let(:south_gi) {
          FactoryBot.create(:geographic_item,
            geography: "POLYGON((0 0, 1 0, 1 #{base_y}, 0.5 #{peak_y}, 0 #{base_y}, 0 0))")
        }
        let(:north_gi) {
          FactoryBot.create(:geographic_item,
            geography: "POLYGON((0 #{base_y_ulp}, 0.5 #{peak_y_ulp}, 1 #{base_y_ulp}, 1 20, 0 20, 0 #{base_y_ulp}))")
        }
        let(:south_ga) {
          FactoryBot.create(:valid_geographic_area,
            geographic_areas_geographic_items_attributes: [{geographic_item: south_gi}])
        }
        let(:north_ga) {
          FactoryBot.create(:valid_geographic_area,
            geographic_areas_geographic_items_attributes: [{geographic_item: north_gi}])
        }

        before do
          new_gz.build_gi_from_shapes({ ga_combine: [south_ga.id, north_ga.id] })
          new_gz.save!
        end

        specify 'saves without error' do
          expect(new_gz).to be_persisted
        end

        specify 'result has 3D geometry' do
          expect(new_gz.geographic_item.geo_object.as_text).to include('0.0')
        end

        specify 'union covers both constituent GA shapes' do
          expect(covers_all?(new_gz, south_gi.id, north_gi.id)).to be true
        end
      end

      specify 'supports geojson circles' do
        shapes = { geojson: [
            '{"type":"Feature","properties":{"radius":10},"geometry":{"type":"Point","coordinates":[0,0]}}'
          ]
        }
        new_gz.build_gi_from_shapes(shapes)
        new_gz.save!
        expect(new_gz.geographic_item.geo_object).to eq(
          GeographicItem.circle(Gis::FACTORY.point(0, 0), 10)
        )
      end

      specify 'catches invalid WKT' do
        shapes = { wkt: ['POINT(0 0)', 'asdf'] }
        new_gz.build_gi_from_shapes(shapes)
        expect(new_gz.errors.first.type.message).to start_with('Invalid WKT')
      end

      context 'normalizes longitude of single points' do
        specify 'for geojson input' do
          shapes = { geojson: [
            '{"type":"Feature","properties":{"radius":null},"geometry":{"type":"Point","coordinates":["666","5"]}}'
            ]
          }
          new_gz.build_gi_from_shapes(shapes)
          new_gz.save!
          expect(new_gz.geographic_item.geo_object).to eq(
            Gis::FACTORY.point(-54, 5)
          )
        end

        specify 'for wkt input' do
          shapes = { wkt: ['POINT (-190 10)'] }
          new_gz.build_gi_from_shapes(shapes)
          new_gz.save!
          expect(new_gz.geographic_item.geo_object).to eq(
            Gis::FACTORY.point(170, 10)
          )
        end
      end

      context "produces shapes that don't cross the anti-meridian" do
        specify 'wkt' do
          shapes = { wkt: [
              'POLYGON (
                (160.0 -10.0 0.0, 160.0 10.0 0.0, 200.0 10.0 0.0,
                200.0 -10.0 0.0, 160.0 -10.0 0.0)
              )'
            ]
          }
          new_gz.build_gi_from_shapes(shapes)

          expect(
            GeographicItem.crosses_anti_meridian?(shapes[:wkt].first)
          ).to be true

          expect(
            GeographicItem.crosses_anti_meridian?(
              new_gz.geographic_item.geo_object.as_text
            )
          ).to be false
        end

        specify 'geojson' do
          shapes = { geojson: [
            '{"type":"Feature","properties":{}, "geometry":{"type":"Polygon",
              "coordinates":
                [[[-200,-10],[-200,10],[-160,10],[-160,-10],[-200,-10]]]
            }}'
          ]}
          new_gz.build_gi_from_shapes(shapes)

          expect(
            GeographicItem.crosses_anti_meridian?(
              RGeo::GeoJSON.decode(shapes[:geojson].first).geometry.as_text
            )
          ).to be true

          expect(
            GeographicItem.crosses_anti_meridian?(
              new_gz.geographic_item.geo_object.as_text
            )
          ).to be false
        end
      end
    end

    context 'cloning into multiple projects on creation' do
      context '#save_and_clone_to_projects' do
        let(:project2) { FactoryBot.create(:valid_project) }
        let(:project3) { FactoryBot.create(:valid_project) }
        let(:p) { Gis::FACTORY.point(1, 2) }
        let(:g) {
          a = Gazetteer.new(name: 'a', iso_3166_a2: 'zz')
          a.build_geographic_item(geography: p)
          a
        }

        specify 'saves to expected projects' do
          Gazetteer.save_and_clone_to_projects(
            g, [Current.project_id, project2.id]
          )

          expect(Gazetteer.where(project_id: Current.project_id).count)
            .to equal(1)

          expect(Gazetteer.where(project_id: project2.id).count)
            .to equal(1)

          expect(Gazetteer.where(project_id: project3.id).count)
            .to equal(0)
        end

        specify 'clones have the expected data' do
          Gazetteer.save_and_clone_to_projects(
            g, [Current.project_id, project2.id]
          )
          gz2 = Gazetteer.where(project_id: project2.id).first

          expect(gz2.name).to eq('a')
          expect(gz2.iso_3166_a2).to eq('ZZ')
          expect(gz2.iso_3166_a3).to eq(nil)
          expect(gz2.geo_object).to eq(p)
        end
      end
    end
  end
end
