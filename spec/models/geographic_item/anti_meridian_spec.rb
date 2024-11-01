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
  context 'Gis::FACTORY longitude conventions' do
    # Spec'ing these since they're undocumented by rgeo and speak to our
    # understanding of rgeo and postgis anti-meridian-crossing behavior, namely:
    # for any shape with more than one point (i.e. anything other than Point),
    # longitude values in the range [180, 360] are always converted to the range
    # [-180, 0] by our Gis::FACTORY, so that all longitudes of all non-Point
    # shapes are in the range [-180, 180].
    #
    # Geometrically the interpretation is that the line between any two points
    # with longitudes in the range [-180, 180] never crosses the anti-meridian
    # (the -180/180 barrier of that longitude domain), i.e. the line segment
    # between any two points in our Gis::FACTORY representation always crosses
    # the meridian if the two points are in different hemispheres, even if
    # that's the long way between the two points.
    #
    # Applying ST_Shift_Longitude converts longitudes in the range [-180, 0] to
    # the range [180, 360], so converts longitudes in the range [-180, 180] to
    # longitudes in the range [0, 360]. Geometrically the interpretation is that
    # lines between any two points with coordinates in this range can never
    # cross the meridian (the 0/360 boundary of that longitude domain), they
    # always cross the anti-meridian if they're in different hemispheres, even
    # if that's the long way between the points.
    #
    # If you want the shapes your input points describe to cross the meridian -
    # ACCORDING TO valid?, ST_Is_Valid, make_valid, and ST_MakeValid (others??)
    # - then leave them in the coordinate representation applied by
    # Gis::FACTORY. If you instead expect a shape to cross the anti-meridian
    # then apply ST_ShiftLongitude to the shape.
    #
    # How can you tell which was intended for an input shape? By a quirk of
    # behavior, `intersects_anti_meridian?` (which relies on ST_Intersects)
    # operates as though the lines between points of your shape are
    # shortest-distance geodesics, i.e. ignores the above [a guess: this is a
    # special case processing quirk because the
    # polygon-intersect-anti-meridian check boils down to a bounding box
    # comparison here]. That's most likely the interpretation of your shape that
    # was intended.
    #
    # See specs below for evidence supporting these claims.
    context 'point coordinate longitudes are NEVER adjusted' do
      specify 'point coordinate longitudes in [-180, 0] are NOT adjusted' do
        expect(Gis::FACTORY.point(-170, 0).lon).to eq(-170)
        expect(Gis::FACTORY.parse_wkt('POINT (-170 0)').lon).to eq(-170)
        expect(Gis::FACTORY.parse_wkt('POINT (-170 0)').as_text)
          .to eq('POINT (-170.0 0.0 0.0)')
      end

      specify 'point coordinate longitudes in [180, 360] are NOT adjusted' do
        expect(Gis::FACTORY.point(190, 0).lon).to eq(190)
        expect(Gis::FACTORY.parse_wkt('POINT (190 0)').lon).to eq(190)
        expect(Gis::FACTORY.parse_wkt('POINT (190 0)').as_text)
          .to eq('POINT (190.0 0.0 0.0)')
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
  end

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
          # drawn on leaflet clockwise
          'POLYGON (
            (160.0 -10.0 0.0, 160.0 10.0 0.0, -160.0 10.0 0.0,
             170.0 0.0 0.0, -160.0 -10.0 0.0, 160.0 -10.0 0.0)
           )',
          # drawn on leaflet counter-clockwise
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

    context 'Leaflet/GeoJSON inputs and Gis::FACTORY considerations' do
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
        # p is the GeoJson feature returned by leaflet for the shape drawn on
        # leaflet as above, where * is the anti-meridian.
        '{"type":"Feature","properties":{},
          "geometry":{"type":"Polygon",
            "coordinates":
            [[[-200,-10],[-200,10],[-160,10],[-190,0],[-160,-10],[-200,-10]]]
         }}'
      }
      let(:s) {
        # The geo_factory argument is significant here for the way it normalizes
        # coordinates - see longitude specs above.
        RGeo::GeoJSON.decode(p, geo_factory: Gis::FACTORY)
        # s.geometry.as_text = POLYGON (
        #    (160.0 -10.0 0.0, 160.0 10.0 0.0, -160.0 10.0 0.0, 170.0 0.0 0.0,
        #     -160.0 -10.0 0.0, 160.0 -10.0 0.0)
        #   )
      }

      xspecify 'valid leaflet-provided anti-meridian-crossing shapes can become
        invalid when normalized by Gis::FACTORY' do

        # s as normalized by our factory is invalid according to both rgeo and
        # postgis:
        expect(s.geometry.valid?).to be false
        expect(GeographicItem.find_by_sql(
            "SELECT ST_IsValid(ST_GeomFromText('#{s.geometry.as_text}')) as r;"
          ).first.r).to be false
        # ... due to a self-intersection
        expect(s.geometry.invalid_reason).to eq('Self-intersection')
        # The postgis invalid reason is 'Self-intersection at or near point 160
        # 0.303030303030303 0' which is consistent with the segment from
        # (-160,0) to (170,0) being interpreted as crossing the meridian (going
        # the "long" way) and not the anti-meridian.

        # By comparison if we decode without specifying our factory:
        s2 = RGeo::GeoJSON.decode(p)
        # then we get
        # s2.geometry.as_text = POLYGON ((-200 -10, -200 10, -160 10, -190 0, -160 -10, -200 -10)) # same as the geojson feature coordinates
        # which **is** valid but cannot be stored in our factory in this form given
        # our factory's normalization conventions - this shape would have to be split in two across the anti-meridian to be stored in our Gis::FACTORY.
        expect(s2.geometry.valid?).to be true
        expect(GeographicItem.find_by_sql(
            "SELECT ST_IsValid(ST_GeomFromText('#{s2.geometry.as_text}')) as r;"
          ).first.r).to be true

        # In spite of what both rgeo and postgis suggest about s crossing the
        # meridian instead of the anti-meridian, both s and s2 are reported to
        # intersect the anti_meridian by postgis. (A similar rgeo intersection
        # check on s fails because s has a self-intersection.)
        expect(GeographicItem.crosses_anti_meridian?(s.geometry.as_text)).to be true
        expect(GeographicItem.crosses_anti_meridian?(s2.geometry.as_text)).to be true
      end

      context 'st_shifting an anti-meridian-crossing shape normalized by our gis factory produces a valid shape' do
        # Can't test rgeo-valid here without bypassing our GIS::Factory, which
        # we don't want to do.
        specify 'st_shifted(s) is postgis valid' do
          expect(ActiveRecord::Base.connection.select_value('SELECT ' +
            GeographicItem.st_is_valid_sql(
              GeographicItem.st_shift_longitude_sql(
                GeographicItem.st_geom_from_text_sql(
                  s.geometry.as_text
                )
              )
            ).to_sql
          )).to be true
          # The shifted shape here is
          # POLYGON Z ((160 -10 0,160 10 0,200 10 0,170 0 0,200 -10 0,160 -10 0))
        end
      end

      context 'GeographicItem.split_along_anti_meridian(wkt)' do
        # GeographicItem.split_along_anti_meridian has the pre-condition that
        # its input crosses_anti_meridian? and so applies ST_ShiftLongitude to
        # match that interpretation of the input.
        context 'Leaflet-provided GIS:Factory polygon' do
          let!(:wkt) {
            # Make sure it's represented as it would be internally:
            Gis::FACTORY.parse_wkt(
              'POLYGON (
                (160.0 -10.0 0.0, 160.0 10.0 0.0, -160.0 10.0 0.0,
                170.0 0.0 0.0, -160.0 -10.0 0.0, 160.0 -10.0 0.0)
              )'
            ).as_text
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

      context 'Attempting to make arbitrary input shapes both valid and not anti-meridian-crossing' do
        let(:devils_bowtie) {
          # Make sure it's represented as it would be internally:
          Gis::FACTORY.parse_wkt(
            'POLYGON ((200 0, 170 10, 170 0, 200 10, 200 0))'
          ).as_text
        }

        # If you try to make_valid first, you get the "wrong" result on shapes
        # that are anti-meridian-crossing:
        xspecify 'make_valid on anti-meridian-crossing shapes - as normalized by our factory - gives undesired results' do
          # This makes the **meridian-crossing interpretation** of the shape
          # valid:
          new_s = s.make_valid
          expect(new_s.contains?(Gis::FACTORY.point(0, 9))).to be true
        end

        # The correct action here would be to make_valid on the shifted shape,
        # but we shouldn't shift unless we know crosses_anti_meridian?, so we'd
        # like crosses_anti_meridian? to tolerate (i.e. not raise and give the
        # correct result on) invalid shapes, both crossing and not crossing the
        # anti-meridian.
        specify 'crosses_anti_meridian? tolerates non-anti-meridian-crossing invalid shape' do
          inv_s = 'POLYGON ((0 0, 10 10, 10 0, 0 10, 0 0))' # bowtie
          expect(GeographicItem.crosses_anti_meridian?(inv_s)).to be false
        end

        specify 'crosses_anti_meridian? tolerates anti-meridian-crossing invalid shape' do
          expect(GeographicItem.crosses_anti_meridian?(devils_bowtie)).to be true
        end

        # Using ST_Intersects on an invalid shape can blow up
        xspecify 'failure on split_along_anti_meridian for invalid anti-meridian-crossing shape' do
          expect{GeographicItem.split_along_anti_meridian(devils_bowtie)}
            .to raise_error ActiveRecord::StatementInvalid, /geom_intersection/
        end

        specify 'make_valid(shifted(anti_meridian-crossing-shape)) gives the expected result' do
          # This is tricky because make_valid operates correctly on a shifted
          # shape, but when it gets saved back to our Gis::FACTORY its
          # coordinates get saved as meridian-crossing/non-shifted, which is
          # "wrong" - it's still crosses_anti_meridian? true - but we can't
          # store it that way in our factory.

          new_s = Gis::FACTORY.parse_wkb(
            ActiveRecord::Base.connection.select_value('SELECT ' +
              GeographicItem.anti_meridian_crossing_make_valid_sql(
                devils_bowtie
              ).to_sql
            )
          )

          expect(new_s.as_text).to eq('MULTIPOLYGON (((170.0 10.0 0.0, -175.0 5.0 0.0, 170.0 0.0 0.0, 170.0 10.0 0.0)), ((-160.0 10.0 0.0, -160.0 0.0 0.0, -175.0 5.0 0.0, -160.0 10.0 0.0)))')

          expect(GeographicItem.crosses_anti_meridian?(new_s.as_text)).to be true
        end

        # To complete the process, now that we've made the
        # anti-meridian-crossing invalid shape into its valid
        # anti-meridian-crossing version, we can apply
        # split_across_anti_meridian to get valid non-anti-meridian-crossing
        # shapes, our original goal.
        context 'make invalid anti-meridian-crossing shapes valid and non-anti-meridian-crossing' do
          specify 'splits into 3 pieces' do
            mp = GeographicItem
              .make_valid_non_anti_meridian_crossing_shape(devils_bowtie)

            expect(mp.geometry_type.to_s).to eq('MultiPolygon')
            expect(mp.num_geometries).to eq(3)
          end

          specify 'split pieces are valid' do
            mp = GeographicItem
              .make_valid_non_anti_meridian_crossing_shape(devils_bowtie)

            mp.each do |p|
              expect(p.valid?).to be true
            end
          end

          specify "results don't cross the anti-meridian" do
            mp = GeographicItem
              .make_valid_non_anti_meridian_crossing_shape(devils_bowtie)

            mp.each do |p|
              expect(GeographicItem.crosses_anti_meridian?(p.as_text)).to be false
            end
            expect(GeographicItem.crosses_anti_meridian?(mp.as_text)).to be false
          end

          specify 'split pieces include expected points' do
            mp = GeographicItem
              .make_valid_non_anti_meridian_crossing_shape(devils_bowtie)

            # the right piece
            expect(mp[0].contains?(Gis::FACTORY.point(179, 5))).to be true
            # the middle
            expect(mp[1].contains?(Gis::FACTORY.point(-179, 5))).to be true
            # the left piece
            expect(mp[2].contains?(Gis::FACTORY.point(-161, 5))).to be true
          end
        end
      end
    end
  end
end
