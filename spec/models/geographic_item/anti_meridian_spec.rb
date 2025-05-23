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
    # See spec/config/initializers/gis_spec.rb for specs on the following
    # Gis::FACTORY behavior which informs our understanding of RGeo's
    # (undocumented) anti-meridian handling.
    #
    # For any shape with edges (i.e. anything other than Point and MultiPoint),
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
    # longitudes in the range [0, 360]. In this case lines between points never
    # cross the meridian.
    #
    # If you want the shapes your input points describe to cross the meridian -
    # ACCORDING TO valid?, ST_Is_Valid, make_valid, and ST_MakeValid (others??)
    # - then leave them in the coordinate representation applied by
    # Gis::FACTORY. If you instead expect a shape to cross the anti-meridian
    # then apply ST_ShiftLongitude to the shape.
    #
    # How can you tell which was intended for an input shape? After your input
    # shape has been normalized by the factory, **you can't**.
    # `intersects_anti_meridian?` (which relies on ST_Intersects) operates on
    # the assumption that the lines between points of your shape are
    # shortest-distance geodesics (i.e. ignores the conventions of ST_Is_Valid
    # etc. described above). That's most likely the interpretation of your shape
    # that was intended, but it means that (at least for the purposes of
    # intersection) !!there's no such thing as an edge spanning more than 180
    # degrees longitude - if that's what you want then you need to break up your
    # edge into shorter segements!!. Watch for this when importing shapes
    # you didn't create.
    #
    # See specs below for evidence supporting these claims.
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

      context 'intersects assumes edges are shortest-length geodesics' do
        specify 'no such thing as an edge spanning more than 180 degrees longitude' do
          expect(GeographicItem.crosses_anti_meridian?(
              # For the purposes of ST_Is_Valid, this edge in a polygon would be
              # interpreted as crossing the meridian (since its coordinates are
              # in [-180, 180]). Here with ST_Intersection it's the
              # shortest-distance edge crossing the anti-meridian.
              'LINESTRING (-170 0, 20 0)'
            )
          ).to be_truthy
        end

        xspecify 'edges with a vertex on the meridian and spanning more than 90 degrees (but < 180) may intersect the anti-meridian' do
          # TODO Why does this happen? What's the logic behind it? The behavior
          # only occurs when one of the endpoints has longitude 0 and seems to
          # require a longitude span of > 90; other factors are undetermined.
          expect(GeographicItem.crosses_anti_meridian?(
             'LINESTRING (91 10, 0 0)'
           )
          ).to be_falsey # as expected

          expect(GeographicItem.crosses_anti_meridian?(
              'LINESTRING (91 0, 0 10)'
            )
          ).to be_truthy # why???
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

        # By comparison if we decode using the default factory which doesn't
        # normalize longitudes:
        s2 = RGeo::GeoJSON.decode(p)
        # then we get
        # s2.geometry.as_text = POLYGON ((-200 -10, -200 10, -160 10, -190 0, -160 -10, -200 -10)) # same as the geojson feature coordinates
        # which **is** valid but cannot be stored in our factory in this form
        # given our factory's normalization conventions - this shape would have
        # to be split in two across the anti-meridian to be stored in our
        # Gis::FACTORY.
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

      context 'covering predicates involving map-drawn anti-meridian wkt' do
        # The leaflet coordinates below are for the case where you create an
        # anti-meridian-crossing rectangle/polygon across the "left" leaflet
        # anti-meridian (i.e. by scrolling the map to the west to a leaflet
        # anti-meridian). If you scroll to the east to a leaflet anti-meridian
        # instead you get all cases resembling leaflet_ur below.

        # Leaflet rectangle drawn crossing the anti-meridian by first clicking
        # the lower left corner and then the upper right.
        let(:leaflet_ll) { # :leaflet_ul would be the same
          'MULTIPOLYGON (((-220 40, -220 70, -140 70, -140 40, -220 40)))'
          # ST_SHIFTs to (140 40, 140 70, 220 70, 220 40, 140 40)
        }

        let(:leaflet_ur) { # :leaflet_lr would be the same
          'MULTIPOLYGON (((140 40, 140 70, 220 70, 220 40, 140 40)))'
        }

        # Longitudes here should be as in the database, in (-180, 180)
        let!(:side_one) {'(140 40, 140 70, 170 70, 170 40, 140 40)'}
        let!(:side_two) {'(-140 40, -170 40, -170 70, -140 70, -140 40)'}

        # "sides" meaning hemispheres...
        let(:wkt_two_sides) {
          "MULTIPOLYGON ((#{side_one}), (#{side_two}))"
        }

        let(:wkt_two_sides_side_one) {
          "MULTIPOLYGON ((#{side_one}))"
        }

        let(:wkt_two_sides_side_two) {
          "MULTIPOLYGON ((#{side_two}))"
        }

        # Google Maps polygon fom the Match Georeferences task, e.g. You can
        # only draw polygons point by point, and GMaps sends those points in the
        # order you click, so they're all just cyclic permutations of each other
        # (and orientation doesn't matter per a geographic_item_spec spec), so
        # we only need to test one.
        let(:gmaps_wkt) {
          # Note POLYGON here, not MULTIPOLYGON
          'POLYGON ((140 40, 140 70, -140 70, -140 40, 140 40))'
          # ST_SHIFTs to (140 40, 140 70, 220 70, 220 40, 140 40)
        }

        let!(:gi_two_sides) {
          FactoryBot.create(:valid_geographic_item, geography:
            wkt_two_sides
          )
        }

        let!(:gi_side_one) {
          FactoryBot.create(:valid_geographic_item, geography:
            wkt_two_sides_side_one
          )
        }

        let!(:gi_side_two) {
          FactoryBot.create(:valid_geographic_item, geography:
            wkt_two_sides_side_two
          )
        }

        # A possible fly in the ointment: this gets shifted to the range (0,
        # 360) and then crosses the anti-meridian, but (lucky for us) it's too
        # "big" to be contained by the leaflet shapes now, even though it does
        # intersect them.
        let!(:meridian_crossing) {
          'MULTIPOLYGON (((-40 40, 40 40, 40 70, -40 70, -40 40)))'
        }
        let!(:meridian_crossing_gi) {
          FactoryBot.create(:valid_geographic_item, geography:
            meridian_crossing
          )
        }

        specify 'covered_by_wkt_sql leaflet_ll' do
          expect(::GeographicItem.where(
            ::GeographicItem.covered_by_wkt_sql(leaflet_ll)).pluck(:id)
          ).to contain_exactly(gi_side_one.id, gi_side_two.id, gi_two_sides.id)
        end

        specify 'covered_by_wkt_sql leaflet_ur' do
          expect(::GeographicItem.where(
            ::GeographicItem.covered_by_wkt_sql(leaflet_ur)).pluck(:id)
          ).to contain_exactly(gi_side_one.id, gi_side_two.id, gi_two_sides.id)
        end

        specify 'covered_by_wkt_sql gmaps_wkt' do
          expect(::GeographicItem.where(
            ::GeographicItem.covered_by_wkt_sql(gmaps_wkt)).pluck(:id)
          ).to contain_exactly(gi_side_one.id, gi_side_two.id, gi_two_sides.id)
        end

        specify 'within_radius_of_wkt_sql 1' do
          wkt = 'POINT (-179.99 50)'
          radius = 40 * Utilities::Geo::ONE_WEST_MEAN # (overkill at this latitiude)
          expect(::GeographicItem.where(
            ::GeographicItem.within_radius_of_wkt_sql(wkt, radius)).pluck(:id)
          ).to contain_exactly(gi_side_one.id, gi_side_two.id, gi_two_sides.id)
        end

        specify 'within_radius_of_wkt_sql 2' do
          wkt = 'POINT (179.99 50)'
          radius = 40 * Utilities::Geo::ONE_WEST_MEAN
          expect(::GeographicItem.where(
            ::GeographicItem.within_radius_of_wkt_sql(wkt, radius)).pluck(:id)
          ).to contain_exactly(gi_side_one.id, gi_side_two.id, gi_two_sides.id)
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

            l = Gis::FACTORY.point(165, 0) # left piece
            ur = Gis::FACTORY.point(-175, 5.5) # upper right piece
            lr = Gis::FACTORY.point(-175, -5.5) # lower right piece

            expect([mp[0].contains?(l), mp[0].contains?(ur), mp[0].contains?(lr)])
              .to contain_exactly(true, false, false)
            expect([mp[1].contains?(l), mp[1].contains?(ur), mp[1].contains?(lr)])
              .to contain_exactly(true, false, false)
            expect([mp[2].contains?(l), mp[2].contains?(ur), mp[2].contains?(lr)])
              .to contain_exactly(true, false, false)
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
