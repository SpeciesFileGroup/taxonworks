require 'rails_helper'
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
    #- antimeridian crossing line partially contained by anti_box, crosses anti from eastern to western (easterly)
    let(:left_right_anti_line_partial) { 'LINESTRING (170.5 26.0, -179.8 25.5)' } #- partially contained by anti_box
    #- antimeridian crossing line partially contained by anti_box, crosses anti from western to eastern (westerly)
    let(:right_left_anti_line_partial) { 'LINESTRING (-170.5 26.0, 179.8 25.5)' } #- partially contained by anti_box

    # test/target/found objects right side/object B component of ST_Contains(A, B)
    #  points( outside, outside )
    #- line NOT contained by anti_box
    let(:left_right_anti_line_out) { 'LINESTRING (170.5 26.0, 175.0 25.5)' }
    #- line NOT contained by anti_box
    let(:right_left_anti_line_out) { 'LINESTRING (-170.5 26.0, -175.8 25.5)' }

    #- antimeridian string
    let(:anti_s) { 'LINESTRING (180 89, 180 -89)' }

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
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{send(b)}')), " \
                    "ST_GeomFromText('POINT(#{p})')) as r;"
                ).first.r).to be false
              end
            end

            ['180 26', '179.9 26'].each do |p| # points not in really wide box
              specify "shifted #{b}/#{p}" do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{send(b)}')), " \
                    "ST_GeomFromText('POINT(#{p})')) as r;"
                ).first.r).to be true
              end
            end

            specify "#{b} (positive shifted does not contain negative point)" do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{send(b)}')), " \
                    "ST_GeomFromText('POINT(-179.9 26)')) as r;"
              ).first.r).to be false
            end

            specify "#{b} (both shifted does contain point)" do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{send(b)}')), " \
                    "ST_ShiftLongitude(ST_GeomFromText('POINT(-179.9 26)'))) as r;"
              ).first.r).to be true
            end
          end
        end


        context 'possible results are' do
          context 'entirely enclosed in right-left anti-box' do
            specify 'left-right anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_box}')), " \
                    "ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_line}'))) as r;"
              ).first.r).to be true
            end

            specify 'west-east line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_box}')), " \
                    "ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_line}'))) as r;"
              ).first.r).to be true
            end
          end

          context 'entirely enclosed in left-right anti-box' do
            specify 'left-right anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_box}')), " \
                    "ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_line}'))) as r;"
              ).first.r).to be true
            end

            specify 'right-left anti line' do
              expect(GeographicItem.find_by_sql(
                "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_box}')), " \
                    "ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_line}'))) as r;"
              ).first.r).to be true
            end
          end

          context 'not (completely) contained/enclosed' do
            @out = %I{left_right_anti_line_partial right_left_anti_line_partial
            left_right_anti_line_out right_left_anti_line_out}

            @out.each do |s|
              specify "#{s}" do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_box}')), " \
                    "ST_ShiftLongitude(ST_GeomFromText('#{send(s)}'))) as r;"
                ).first.r).to be false
              end
            end
          end
        end
      end
    end

    context 'Demonstrate that anti_boxes are small for geographies/ST_Covers' do
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
      let(:eastern_box) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt(eastern_box_text)) }
      let(:western_box_text) { 'POLYGON((-179.0 27.0, -176.0 27.0, -176.0 25.0, -179.0 25.0, -179.0 27.0))' }
      let(:western_box) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt(western_box_text)) }
      let(:crossing_box) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt(left_right_anti_box)) }

      # lines
      let(:l_r_line) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt(left_right_anti_line)) }
      let(:r_l_line) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt(right_left_anti_line)) }

      # points
      let(:point_in_eastern_box) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt('POINT(177 26.0)')) }
      let(:point_in_europe) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt('POINT(17 26.0)')) }
      let(:point_in_england) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt('POINT(1 26.0)')) }
      let(:point_in_western_box) { GeographicItem.create(geography: Gis::FACTORY.parse_wkt('POINT(-177.0 26.0)')) }

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

      context 'shifted wkt' do
        before { build_structure }

        specify 'shifting an already shifted polygon has no effect' do
          shifted_wkt = eastern_box.geo_object.to_s
          expect(shifted_wkt =~ /-/).to be_falsey
          expect(GeographicItem.where(GeographicItem.covered_by_wkt_sql(shifted_wkt)).map(&:id))
            .to contain_exactly(point_in_eastern_box.id, eastern_box.id)
        end
      end
    end

    context 'verify GeographicItem.crosses_anti_meridian?(wkt) works' do
      let(:eastern_box_text) { 'POLYGON(( 176.0 27.0,  179.0 27.0,  179.0 25.0,  176.0 25.0,  176.0 27.0))' }

      %I{left_right_anti_box right_left_anti_box
        left_right_anti_line right_left_anti_line}.each do |p|
        specify "#{p}" do
          expect(GeographicItem.crosses_anti_meridian?("#{send(p)}")).to be_truthy
        end
      end

      specify 'eastern_box_text' do
        expect(GeographicItem.crosses_anti_meridian?(eastern_box_text)).to be_falsey
      end

      context 'anti-meridian crossing shapes from leaflet decoded with Gis::FACTORY' do
        # See the xspecify example below for context
        [
          # clockwise
          'POLYGON (
            (160.0 -10.0 0.0, 160.0 10.0 0.0, -160.0 10.0 0.0,
             170.0 0.0 0.0, -160.0 -10.0 0.0, 160.0 -10.0 0.0)
           )',
          # counter-clockwise
          'POLYGON (
            (-160.0 10.0 0.0, 160.0 10.0 0.0, 160.0 -10.0 0.0,
             -160.0 -10.0 0.0, 170.0 0.0 0.0, -160.0 10.0 0.0)
          )',
        ].each do |p|
          specify "#{p}" do
            expect(GeographicItem.crosses_anti_meridian?("#{p}")).to be_truthy
          end
        end
      end
    end

    context 'GeographicItem.split_along_anti_meridian(wkt)' do
      context 'Leaflet-provided GIS:Factory polygon' do
        let!(:wkt) { 'POLYGON (
            (160.0 -10.0 0.0, 160.0 10.0 0.0, -160.0 10.0 0.0,
            170.0 0.0 0.0, -160.0 -10.0 0.0, 160.0 -10.0 0.0)
          )'
        }

        specify 'splits into 3 pieces' do
          mp = GeographicItem.split_along_anti_meridian(wkt)
          expect(mp.geometry_type.to_s).to eq('MultiPolygon')
          expect(mp.num_geometries).to eq(3)
        end

        specify 'split pieces are valid' do
          mp = GeographicItem.split_along_anti_meridian(wkt)
          mp.each do |p|
            expect(p.valid?).to be true
          end
        end

        specify "results don't cross the anti-meridian" do
          mp = GeographicItem.split_along_anti_meridian(wkt)
          mp.each do |p|
            expect(GeographicItem.crosses_anti_meridian?(p.as_text)).to be false
          end
          expect(GeographicItem.crosses_anti_meridian?(mp.as_text)).to be false
        end

        specify 'split pieces include expected points' do
          mp = GeographicItem.split_along_anti_meridian(wkt)
          # the left piece
          expect(mp[0].contains?(Gis::FACTORY.point(165, 0))).to be true
          # the lower right piece
          expect(mp[1].contains?(Gis::FACTORY.point(-175, -5))).to be true
          # the upper right piece
          expect(mp[2].contains?(Gis::FACTORY.point(-175, 5))).to be true
        end
      end
    end

    context 'A leaflet/GeoJSON/Gis::FACTORY interaction' do
      let(:p) {
        #              *
        #      --------*--
        #      |       * /
        #      |       */
        #      |       /
        #      |      /*
        #      |     / *
        #      |     \ *
        #      |      \*
        #      |       \
        #      |       *\
        #      |       * \
        #      --------*--
        #              *
        # p is the GeoJson feature provided by leaflet for the shape drawn on
        # leaflet as above, where * is the anti-meridian.
        '{"type":"Feature","properties":{},
          "geometry":{"type":"Polygon",
            "coordinates":
            [[[-200,-10],[-200,10],[-160,10],[-190,0],[-160,-10],[-200,-10]]]
         }}'
      }
      let(:s) {
        # The geo_factory argument is significant here for the way it normalizes
        # coordinates.
        RGeo::GeoJSON.decode(p, geo_factory: Gis::FACTORY)
        # s.geometry.as_text = POLYGON (
        #    (160.0 -10.0 0.0, 160.0 10.0 0.0, -160.0 10.0 0.0, 170.0 0.0 0.0,
        #     -160.0 -10.0 0.0, 160.0 -10.0 0.0)
        #   )
      }
      xspecify 'valid leaflet-provided anti-meridian-crossing shapes can become
        invalid when normalized by Gis::FACTORY' do
        # s is reported to cross the anti-meridian...
        expect(GeographicItem.crosses_anti_meridian?(s.geometry.as_text)).to be true
        # ... but is at the same time invalid...
        expect(s.geometry.valid?).to be false
        expect(GeographicItem.find_by_sql(
            "SELECT ST_IsValid(ST_GeomFromText('#{s.geometry.as_text}')) as r;"
          ).first.r).to be false
        # ... due to a self-intersection
        expect(s.geometry.invalid_reason).to eq('Self-intersection')
        # The postgis invalid reason is 'Self-intersection at or near point 160
        # 0.303030303030303 0' which suggests the segment from (-160,0) to
        # (170,0) is being interpreted as crossing the meridian (going the
        # "long" way) and not the anti-meridian (even though the anti-meridian
        # check passed...).

        # Question: is it possible to represent this polygon in our
        # GIS::Factory's normalized coordinates in a way that makes it `valid?`?
        # Or can it only be made valid by splitting it across the anti-meridian?

        # GeographicItem.split_along_anti_meridian sidesteps the issue by
        # st_shifting the invalid polygon - to 'POLYGON Z ((160 -10 0,160 10
        # 0,200 10 0,170 0 0,200 -10 0,160 -10 0))', which *IS* ST_IsValid - and
        # then working directly in postgis to get non-anti-meridian-crossing
        # pieces from that, which can be safely parsed with GIS::Factory.

        # By comparison (and as an alternative?), if we decode without
        # specifying a factory:
        s2 = RGeo::GeoJSON.decode(p)
        # s2.geometry.as_text = POLYGON ((-200 -10, -200 10, -160 10, -190 0, -160 -10, -200 -10)) # same as the geojson feature coordinates
        #   )
        # Reported to cross the anti-meridian...
        expect(GeographicItem.crosses_anti_meridian?(s2.geometry.as_text)).to be true
        # ... and is valid
        expect(s2.geometry.valid?).to be true
        expect(GeographicItem.find_by_sql(
            "SELECT ST_IsValid(ST_GeomFromText('#{s2.geometry.as_text}')) as r;"
          ).first.r).to be true
      end
    end
  end
end
