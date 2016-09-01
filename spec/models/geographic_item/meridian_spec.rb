require 'rails_helper'
require_relative '../../support/geo/build_rspec_geo'

# include the subclasses, perhaps move this out
Dir[Rails.root.to_s + '/app/models/geographic_item/**/*.rb'].each { |file| require_dependency file }


# Sanity and depth checks for handling data that crosses the anti-meridian.
# The general goal is to
#
#                A/M
#           X----|---->
#  east/left     |        west/right
#           <----|-----X
#
#
#
describe GeographicItem, type: :model, group: :geo do

  # let(:geographic_item) { GeographicItem.new }

  after(:all) { clean_slate_geo }

  context 'anti-meridian' do
    # containers left side/object A component of ST_Contains(A, B)
    # crosses anti from eastern to western (easterly)
    let(:left_right_anti_box) { 'POLYGON((179.0 27.0, -178.0 27.0, -178.0 25.0, 179.0 25.0, 179.0 27.0))' }
    # crosses anti from western to eastern (westerly)
    let(:right_left_anti_box) { 'POLYGON((-179.0 27.0, 178.0 27.0,  178.0 25.0, -179.0 25.0, -179.0 27.0))' }

    # test/target/found objects, right side/object B component of ST_Contains(A, B)
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
    let(:right_left_anti_line_out) { 'LINESTRING (-170.5 26.0, -165.8 25.5)' }

    #- antimeridian crossing line not contained by anti_box
    # let(:east_west_anti_line_x){  'LINESTRING (178.5 26.0, -179.5 25.5)' }
    #- antimeridian crossing line not contained by anti_box
    # let(:west_east_anti_line_x){  'LINESTRING (-177.5 26.0, 179.5 25.5)' }

    #  let(:east_box){ 'POLYGON((179.9 27.0, 178.0 27.0, 178.0 25.0, 179.9 25.0, 179.9 27.0))' }   # doesn't cross
    #  let(:west_box){ 'POLYGON((-179.9 27.0, -178.0 27.0, -178.0 25.0, -179.9 25.0, -179.9 27.0))' } # doesn't cross

    #  let(:east_line){  'LINESTRING (179.2 26.0, 179.9 25.5)' }              #- eastern line contained by anti_box
    #  let(:west_line){  'LINESTRING (-179.2 26.0, -179.9 25.5)' }            #- western line contained by anti_box

    let(:anti_s) { 'LINESTRING (180 89.0, 180 -89)' } #- antimeridian string

    context 'container crosses the antimeridan' do

      context 'raw SQL' do

        context 'ST_ShiftLongitude NOT applied to parameters/containers of ST_Contains(A, B)' do
          context 'possible results are' do

            context 'entirely enclosed in right-left anti-box' do
              specify 'left-right anti line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_GeomFromText('#{right_left_anti_box}'), ST_GeomFromText('#{left_right_anti_line}')) as r;"
                ).first.r).to be false
              end

              specify 'right-left anti line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_GeomFromText('#{right_left_anti_box}'), ST_GeomFromText('#{right_left_anti_line}')) as r;"
                ).first.r).to be true
              end
            end

            context 'entirely enclosed in left-right anti-box' do
              specify 'left-right anti line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_GeomFromText('#{left_right_anti_box}'), ST_GeomFromText('#{left_right_anti_line}')) as r;"
                ).first.r).to be true
              end

              specify 'west-east line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_GeomFromText('#{left_right_anti_box}'), ST_GeomFromText('#{right_left_anti_line}')) as r;"
                ).first.r).to be false
              end
            end

            context 'not (completely) contained/enclosed' do
              @out = %I{left_right_anti_line_partial right_left_anti_line_partial left_right_anti_line_out right_left_anti_line_out}

              @out.each do |s|
                specify "#{s}" do
                  expect(GeographicItem.find_by_sql(
                    "SELECT ST_Contains(ST_GeomFromText('#{right_left_anti_box}'), ST_GeomFromText('#{send(s)}')) as r;"
                  ).first.r).to be false
                end
              end
            end
          end
        end

        context 'ST_ShiftLongitude applied to parameters/containers of ST_Contains(A, B)' do
          context 'possible results are' do

            context 'entirely enclosed in right-left anti-box' do
              specify 'left-right anti line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_box}')), ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_line}'))) as r;"
                ).first.r).to be true
              end

              specify 'west-east line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_box}')), ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_line}'))) as r;"
                ).first.r).to be true
              end
            end

            context 'entirely enclosed in left-right anti-box' do
              specify 'left-right anti line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_box}')), ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_line}'))) as r;"
                ).first.r).to be true
              end

              specify 'right-left anti line' do
                expect(GeographicItem.find_by_sql(
                  "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{left_right_anti_box}')), ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_line}'))) as r;"
                ).first.r).to be true
              end
            end

            context 'not (completely) contained/enclosed' do
              @out = %I{left_right_anti_line_partial right_left_anti_line_partial left_right_anti_line_out right_left_anti_line_out}

              @out.each do |s|
                specify "#{s}" do
                  expect(GeographicItem.find_by_sql(
                    "SELECT ST_Contains(ST_ShiftLongitude(ST_GeomFromText('#{right_left_anti_box}')), ST_ShiftLongitude(ST_GeomFromText('#{send(s)}'))) as r;"
                  ).first.r).to be false
                end
              end
            end
          end
        end
      end
    end
  end
end
