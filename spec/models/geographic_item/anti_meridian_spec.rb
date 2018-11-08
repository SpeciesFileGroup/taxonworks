require 'rails_helper'
# require_relative '../../support/shared_contexts/geo/build_rspec_geo'

# include the subclasses, perhaps move this out
Dir[Rails.root.to_s + '/app/models/geographic_item/**/*.rb'].each { |file| require_dependency file }


# An exercise in exploring and handling data that crosses the anti-meridian.
#
#           anti-meridian
#                |
#           X----|---->
#  east/left     |        west/right
#           <----|-----X
#                |
#
# The take home message- if you use ST_Contains(ST_ShiftLongitude(), ST_ShiftLongitude())
# then everything will "just work".
# IFF the "A" argument crosses the anti-meridian.
#
#
describe GeographicItem, type: :model, group: :geo do

  # after(:all) { clean_slate_geo }

  let(:shift_method) { PSQL_VERSION >= 2.2 ? 'ST_ShiftLongitude' : 'ST_Shift_Longitude' }

  context 'anti-meridian' do
    # Containers left side/object/A component of ST_Contains(A, B)
    # crosses anti from eastern to western (easterly)
    let(:left_right_anti_box) { 'POLYGON((179.0 27.0, -178.0 27.0, -178.0 25.0, 179.0 25.0, 179.0 27.0))' }
    # crosses anti from western to eastern (westerly)
    let(:right_left_anti_box) { 'POLYGON((-179.0 27.0, 178.0 27.0,  178.0 25.0, -179.0 25.0, -179.0 27.0))' }

    # Test/target/found objects, right side/object B component of ST_Contains(A, B)
    #- antimeridian crossing line contained by anti_box, crosses anti from eastern to western (easterly)
    let(:left_right_anti_line) { 'LINESTRING (179.5 26.0, -179.5 25.5)' }
    #- antimeridian crossing line contained by anti_box, crosses anti from western to eastern (westerly)
    let(:right_left_anti_line) { 'LINESTRING (-179.5 26.0, 179.5 25.5)' }

    # test/target/found objects right side/object B component of ST_Contains(A, B)
    #  points( outside, inside )
    #- antimeridian crossing line contained by anti_box, crosses anti from eastern to western (easterly)
    let(:left_right_anti_line_partial) { 'LINESTRING (170.5 26.0, -179.8 25.5)' } #- partially contained by anti_box
    #- antimeridian crossing line contained by anti_box, crosses anti from western to eastern (westerly)
    let(:right_left_anti_line_partial) { 'LINESTRING (-170.5 26.0, 179.8 25.5)' } #- partially contained by anti_box

    # test/target/found objects right side/object B component of ST_Contains(A, B)
    #  points( outside, outside )
    #- antimeridian crossing line NOT contained by anti_box, crosses anti from eastern to western (easterly)
    let(:left_right_anti_line_out) { 'LINESTRING (170.5 26.0, 175.0 25.5)' }
    #- antimeridian crossing line NOT contained by anti_box, crosses anti from western to eastern (westerly)
    let(:right_left_anti_line_out) { 'LINESTRING (-170.5 26.0, -175.8 25.5)' }

    #- antimeridian string
    let(:anti_s) { 'LINESTRING (180 89.0, 180 -89)' }

    context 'raw SQL' do

      context 'box checks' do
        [:left_right_anti_box, :right_left_anti_box].each do |b|
          specify "box #{b} is ST_IsValid?" do
            expect(GeographicItem.find_by_sql(
              "SELECT ST_IsValid(ST_GeomFromText('#{send(b)}')) as r;"
            ).first.r).to be true
          end

          specify "#{b} ST_Intersects with anti-merdian (we can detect things crossing the AM" do
            expect(GeographicItem.find_by_sql(
              "SELECT ST_Intersects(ST_GeogFromText('#{send(b)}'), ST_GeogFromText('#{anti_s}')) as r;"
            ).first.r).to be true
          end
        end
      end

      context 'ST_ShiftLongitude NOT applied to parameters/containers of ST_Contains(A, B)' do
        context 'possible results are' do

          context 'entirely enclosed in right-left anti-box' do
            specify 'left-right anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_GeomFromText('#{right_left_anti_box}'), " \
                    "ST_GeomFromText('#{left_right_anti_line}')) as r;"
              ).first.r).to be false
            end

            specify 'right-left anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_GeomFromText('#{right_left_anti_box}'), " \
                    "ST_GeomFromText('#{right_left_anti_line}')) as r;"
              ).first.r).to be false
            end
          end

          context 'entirely enclosed in left-right anti-box' do
            specify 'left-right anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_GeomFromText('#{left_right_anti_box}'), " \
                    "ST_GeomFromText('#{left_right_anti_line}')) as r;"
              ).first.r).to be false
            end

            specify 'west-east line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_GeomFromText('#{left_right_anti_box}'), " \
                    "ST_GeomFromText('#{right_left_anti_line}')) as r;"
              ).first.r).to be false
            end
          end

          context 'demonstrate that anti_boxes are big for geometries/ST_Contains' do
            @boxes = %I{left_right_anti_box right_left_anti_box}

            @boxes.each do |b|
              ['-90 26', '0 26', '90 26'].each do |p| # points in really wide box
                specify "#{b}/#{p}" do
                  expect(GeographicItem.find_by_sql(
                    "SELECT ST_Contains(ST_GeomFromText('#{send(b)}'), ST_GeomFromText('POINT(#{p})')) as r;"
                  ).first.r).to be true
                end
              end

              ['180 26', '179.9 26', '-179.9 26'].each do |p| # points not in really wide box
                specify "#{b}/#{p}" do
                  expect(GeographicItem.find_by_sql(
                    "SELECT ST_Contains(ST_GeomFromText('#{send(b)}'), ST_GeomFromText('POINT(#{p})')) as r;"
                  ).first.r).to be false
                end
              end
            end

            context 'not (completely) contained/enclosed' do
              @boxes = %I{left_right_anti_box right_left_anti_box}

              @boxes.each do |b|
                %I{left_right_anti_line_out right_left_anti_line_out}.each do |s|
                  specify "#{b}/#{s}" do
                    expect(GeographicItem.find_by_sql(
                      "SELECT ST_Contains(ST_GeomFromText('#{send(b)}'), ST_GeomFromText('#{send(s)}')) as r;"
                    ).first.r).to be true
                  end
                end

                %I{left_right_anti_line_partial right_left_anti_line_partial}.each do |s|
                  specify "#{b}/#{s}" do
                    expect(GeographicItem.find_by_sql(
                      "SELECT ST_Contains(ST_GeomFromText('#{send(b)}'), ST_GeomFromText('#{send(s)}')) as r;"
                    ).first.r).to be false
                  end
                end
              end
            end
          end
        end
      end

      context 'ST_ShiftLongitude applied to parameters/containers of ST_Contains(A, B)' do

        context 'demonstrate that shifted anti_boxes are not big' do
          @boxes = %I{left_right_anti_box right_left_anti_box}

          @boxes.each do |b|
            ['-90 26', '0 26', '90 26'].each do |p| # points in really wide box
              specify "shifted #{b}/#{p}" do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{send(b)}')), " \
                    "ST_GeomFromText('POINT(#{p})')) as r;"
                ).first.r).to be false
              end
            end

            ['180 26', '179.9 26'].each do |p| # points not in really wide box
              specify "shifted #{b}/#{p}" do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{send(b)}')), " \
                    "ST_GeomFromText('POINT(#{p})')) as r;"
                ).first.r).to be true
              end
            end

            specify "#{b} (positive shifted does not contain negative point)" do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{send(b)}')), " \
                    "ST_GeomFromText('POINT(-179.9 26)')) as r;"
              ).first.r).to be false
            end

            specify "#{b} (both shifted does contain point)" do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{send(b)}')), " \
                    "#{shift_method}(ST_GeomFromText('POINT(-179.9 26)'))) as r;"
              ).first.r).to be true
            end
          end
        end


        context 'possible results are' do
          context 'entirely enclosed in right-left anti-box' do
            specify 'left-right anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{right_left_anti_box}')), " \
                    "#{shift_method}(ST_GeomFromText('#{left_right_anti_line}'))) as r;"
              ).first.r).to be true
            end

            specify 'west-east line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{right_left_anti_box}')), " \
                    "#{shift_method}(ST_GeomFromText('#{right_left_anti_line}'))) as r;"
              ).first.r).to be true
            end
          end

          context 'entirely enclosed in left-right anti-box' do
            specify 'left-right anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{left_right_anti_box}')), " \
                    "#{shift_method}(ST_GeomFromText('#{left_right_anti_line}'))) as r;"
              ).first.r).to be true
            end

            specify 'right-left anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{left_right_anti_box}')), " \
                    "#{shift_method}(ST_GeomFromText('#{right_left_anti_line}'))) as r;"
              ).first.r).to be true
            end
          end

          context 'not (completely) contained/enclosed' do
            @out = %I{left_right_anti_line_partial right_left_anti_line_partial
            left_right_anti_line_out right_left_anti_line_out}

            @out.each do |s|
              specify "#{s}" do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(#{shift_method}(ST_GeomFromText('#{right_left_anti_box}')), " \
                    "#{shift_method}(ST_GeomFromText('#{send(s)}'))) as r;"
                ).first.r).to be false
              end
            end
          end
        end
      end
    end

    context 'Demonstrate that anti_boxes are small for geographies/ST_Covers' do
      # Note _lines can not be used in ST_Covers!

      %I{left_right_anti_box right_left_anti_box}.each do |b|
        ['-90 26', '0 26', '90 26'].each do |p| # points in really wide box
          specify "#{b}/#{p}" do
            expect(GeographicItem.find_by_sql(
              "SELECT ST_Covers(ST_GeogFromText('#{send(b)}'), ST_GeogFromText('POINT(#{p})')) as r;"
            ).first.r).to be false
          end
        end

        ['180 26', '179.9 26', '-179.9 26'].each do |p| # points not in really wide box
          specify "#{b}/#{p}" do
            expect(GeographicItem.find_by_sql(
              "SELECT ST_Covers(ST_GeogFromText('#{send(b)}'), ST_GeogFromText('POINT(#{p})')) as r;"
            ).first.r).to be true
          end
        end
      end
    end

    context 'Verify array of GeographicItem IDs shifts longitude correctly for each geography' do
      # use boxes and lines above to make GeographicItem(s)' geometries (?)
      # a fair amount of infrastructure needs to be synthesized here to be able to get a list of GI IDs
      # from a geometry collection whose geometries are ShiftLongitude-d depending on
      # crosses_anti_meridian_by_id?()
      # We are trying to find any/all GeographicItem which are contained in the group specified by the list of
      # GeographicItem.IDs -- i.e., we are collecting GeographicItem-s

      # boxes
      let(:eastern_box_text) { 'POLYGON(( 176.0 27.0,  179.0 27.0,  179.0 25.0,  176.0 25.0,  176.0 27.0))' }
      let(:eastern_box) { GeographicItem.create(polygon: Gis::FACTORY.parse_wkt(eastern_box_text)) }
      let(:western_box_text) { 'POLYGON((-179.0 27.0, -176.0 27.0, -176.0 25.0, -179.0 25.0, -179.0 27.0))' }
      let(:western_box) { GeographicItem.create(polygon: Gis::FACTORY.parse_wkt(western_box_text)) }
      let(:crossing_box) { GeographicItem.create(polygon: Gis::FACTORY.parse_wkt(left_right_anti_box)) }

      # lines
      let(:l_r_line) { GeographicItem.create(line_string: Gis::FACTORY.parse_wkt(left_right_anti_line)) }
      let(:r_l_line) { GeographicItem.create(line_string: Gis::FACTORY.parse_wkt(right_left_anti_line)) }

      # points
      let(:point_in_eastern_box) { GeographicItem.create(point: Gis::FACTORY.parse_wkt('POINT(177 26.0)')) }
      let(:point_in_europe) { GeographicItem.create(point: Gis::FACTORY.parse_wkt('POINT(17 26.0)')) }
      let(:point_in_england) { GeographicItem.create(point: Gis::FACTORY.parse_wkt('POINT(1 26.0)')) }
      let(:point_in_western_box) { GeographicItem.create(point: Gis::FACTORY.parse_wkt('POINT(-177.0 26.0)')) }

      let(:build_structure) { [western_box, eastern_box, point_in_western_box,
                               point_in_eastern_box, point_in_europe, point_in_england,
                               crossing_box, r_l_line, l_r_line]
      }

      context 'detecting items which cross the anti-meridian by id' do
        context 'each crossing object id is detected' do
          %I{crossing_box r_l_line l_r_line}.each do |item|
            specify "#{item} returns true" do
              expect(GeographicItem.crosses_anti_meridian_by_id?(send(item).id)).to be_truthy
            end
          end
        end

        context 'set of crossing object ids is detected' do
          specify '[crossing_box, r_l_line, l_r_line] returns true' do
            expect(GeographicItem.crosses_anti_meridian_by_id?([crossing_box.id,
                                                                r_l_line.id,
                                                                l_r_line.id])).to be_truthy
          end
        end

        context 'set of heterogeneous object ids is detected' do
          specify '[eastern_box, r_l_line, l_r_line] returns true' do
            expect(GeographicItem.crosses_anti_meridian_by_id?([eastern_box.id,
                                                                crossing_box.id,
                                                                r_l_line.id,
                                                                l_r_line.id])).to be_truthy
          end
        end

        context 'each non-crossing object id is not detected' do
          %I{eastern_box western_box}.each do |item|
            specify "#{item} returns false" do
              expect(GeographicItem.crosses_anti_meridian_by_id?(send(item).id)).to be_falsey
            end
          end
        end
      end

      context '.contained_by_with_antimeridian_check(*ids)' do
        before { build_structure }

        specify 'results from single non-meridian crossing polygon is found' do
          # invokes geometry_sql2
          # using contained_by_with_antimeridian_check is not harmful for non-crossing objects
          expect(GeographicItem.contained_by_with_antimeridian_check(western_box.id).map(&:id))
            .to contain_exactly(point_in_western_box.id, western_box.id)
        end

        specify 'results from multiple non-meridian crossing polygons are found' do
          # invokes geometry_sql2
          # using contained_by_with_antimeridian_check is not harmful for non-crossing objects
          expect(GeographicItem.contained_by_with_antimeridian_check(eastern_box.id, western_box.id).map(&:id))
            .to contain_exactly(point_in_eastern_box.id,
                                point_in_western_box.id,
                                eastern_box.id,
                                western_box.id)
        end

        specify 'results from single meridian crossing polygon are found' do
          # why is crossing_box not finding l_r_line or r_l_line
          # why does crossing_box find point_in_eastern_box
          expect(GeographicItem.contained_by_with_antimeridian_check(crossing_box.id).map(&:id))
            .to contain_exactly(l_r_line.id, r_l_line.id, crossing_box.id)
        end

        specify 'results from merdian crossing and non-meridian crossing polygons are found' do
          # why is crossing_box not finding l_r_line or r_l_line
          expect(GeographicItem.contained_by_with_antimeridian_check(eastern_box.id, western_box.id, crossing_box.id)
                   .map(&:id)).to contain_exactly(point_in_eastern_box.id,
                                                  point_in_western_box.id,
                                                  l_r_line.id, r_l_line.id,
                                                  eastern_box.id,
                                                  western_box.id,
                                                  crossing_box.id)
        end

        specify 'shifting an already shifted polygon has no effect' do
          shifted_wkt = eastern_box.geo_object.to_s
          expect(shifted_wkt =~ /-/).to be_falsey
          expect(GeographicItem.where(GeographicItem.contained_by_wkt_sql(shifted_wkt)).map(&:id))
            .to contain_exactly(point_in_eastern_box.id, eastern_box.id)
        end
      end
    end

    context 'verify GeographicItem.crosses_anti_meridian?(wkt) works' do
      let(:eastern_box_text) { 'POLYGON(( 176.0 27.0,  179.0 27.0,  179.0 25.0,  176.0 25.0,  176.0 27.0))' }

      specify 'left_right_anti_box' do
        expect(GeographicItem.crosses_anti_meridian?(left_right_anti_box)).to be_truthy
      end

      specify 'eastern_box_text' do
        expect(GeographicItem.crosses_anti_meridian?(eastern_box_text)).to be_falsey
      end
    end
  end
end
