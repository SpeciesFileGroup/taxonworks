require 'support/vendor/rspec_geo_helpers'

RSPEC_GEO_FACTORY = Gis::FACTORY

shared_context 'stuff for complex geo tests' do

  # Wrapper to pivot b/w model and feature tests
  let(:geo_user) {
    @user.nil? ? User.find(user_id) : @user
  }

  let(:geo_project) {
    @project.nil? ? Project.find(project_id) : @project
  }


  let(:simple_shapes) { {
    point: 'POINT(10 10 0)',
    line_string: 'LINESTRING(0.0 0.0 0.0, 10.0 0.0 0.0)',
    polygon:'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))',
    multi_point: 'MULTIPOINT((10.0 10.0 0.0), (20.0 20.0 0.0))',
    multi_line_string: 'MULTILINESTRING((0.0 0.0 0.0, 10.0 0.0 0.0), (20.0 0.0 0.0, 30.0 0.0 0.0))',
    multi_polygon: 'MULTIPOLYGON(((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, ' \
    '0.0 0.0 0.0)),((10.0 10.0 0.0, 20.0 10.0 0.0, 20.0 20.0 0.0, 10.0 20.0 0.0, 10.0 10.0 0.0)))',
    geometry_collection: 'GEOMETRYCOLLECTION( POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, ' \
    '0.0 10.0 0.0, 0.0 0.0 0.0)), POINT(10 10 0)) ',
    geography:'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))'
  }.freeze }

  let(:point0) { RSPEC_GEO_FACTORY.point(0, 0, 0.0) }
  let(:point1) { RSPEC_GEO_FACTORY.point(-29, -16, 0.0) }
  let(:point2) { RSPEC_GEO_FACTORY.point(-25, -18, 0.0) }
  let(:point3) { RSPEC_GEO_FACTORY.point(-28, -21, 0.0) }
  let(:point5) { RSPEC_GEO_FACTORY.point(3, -14, 0.0) }
  let(:point6) { RSPEC_GEO_FACTORY.point(6, -12.9, 0.0) }
  let(:point7) { RSPEC_GEO_FACTORY.point(5, -16, 0.0) }
  let(:point8) { RSPEC_GEO_FACTORY.point(4, -17.9, 0.0) }
  let(:point9) { RSPEC_GEO_FACTORY.point(7, -17.9, 0.0) }
  let(:point10) { RSPEC_GEO_FACTORY.point(32.2, 22, 0.0) }
  let(:point11) { RSPEC_GEO_FACTORY.point(-17, 7, 0.0) }
  let(:point12) { RSPEC_GEO_FACTORY.point(-9.8, 5, 0.0) }
  let(:point13) { RSPEC_GEO_FACTORY.point(-10.7, 0, 0.0) }
  let(:point14) { RSPEC_GEO_FACTORY.point(-30, 21, 0.0) }
  let(:point15) { RSPEC_GEO_FACTORY.point(-25, 18.3, 0.0) }
  let(:point16) { RSPEC_GEO_FACTORY.point(-23, 18, 0.0) }
  let(:point17) { RSPEC_GEO_FACTORY.point(-19.6, -13, 0.0) }
  let(:point18) { RSPEC_GEO_FACTORY.point(-7.6, 14.2, 0.0) }
  let(:point19) { RSPEC_GEO_FACTORY.point(-4.6, 11.9, 0.0) }

  let(:shape_a1) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21, 0.0),
                                                  RSPEC_GEO_FACTORY.point(-25, 21, 0.0),
                                                  RSPEC_GEO_FACTORY.point(-25, 16, 0.0),
                                                  RSPEC_GEO_FACTORY.point(-21, 20, 0.0)]) }

  let(:list_b1) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-14, 23, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-14, 11, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-2, 11, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-2, 23, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-8, 21, 0.0)]) }

  let(:list_b2) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-11, 18, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-8, 17, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-6, 20, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-4, 16, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, 13, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-11, 14, 0.0)]) }

  let(:shape_b) { RSPEC_GEO_FACTORY.polygon(list_b1, [list_b2]) }
  let(:shape_b_outer) { RSPEC_GEO_FACTORY.polygon(list_b1) }
  let(:shape_b_inner) { RSPEC_GEO_FACTORY.polygon(list_b2) }

  let(:list_c1) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(23, 21, 0.0),
                                                 RSPEC_GEO_FACTORY.point(16, 21, 0.0),
                                                 RSPEC_GEO_FACTORY.point(16, 16, 0.0),
                                                 RSPEC_GEO_FACTORY.point(11, 20, 0.0)]) }

  let(:list_c2) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(4, 12.6, 0.0),
                                                 RSPEC_GEO_FACTORY.point(16, 12.6, 0.0),
                                                 RSPEC_GEO_FACTORY.point(16, 7.6, 0.0)]) }

  let(:list_c3) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(21, 12.6, 0.0),
                                                 RSPEC_GEO_FACTORY.point(26, 12.6, 0.0),
                                                 RSPEC_GEO_FACTORY.point(22, 17.6, 0.0)]) }

  let(:shape_c) { RSPEC_GEO_FACTORY.multi_line_string([list_c1, list_c2, list_c3]) }
  let(:shape_c1) { shape_c.geometry_n(0) }
  let(:shape_c2) { shape_c.geometry_n(1) }
  let(:shape_c3) { shape_c.geometry_n(2) }

  let(:shape_d) { RSPEC_GEO_FACTORY.line_string(
    [RSPEC_GEO_FACTORY.point(-33, 11, 0.0),
     RSPEC_GEO_FACTORY.point(-24, 4, 0.0),
     RSPEC_GEO_FACTORY.point(-26, 13, 0.0),
     RSPEC_GEO_FACTORY.point(-38, 14, 0.0),      # point fixed
     RSPEC_GEO_FACTORY.point(-33, 11, 0.0)]
  )}

  let(:list_e1) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-19, 9, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-9, 9, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-9, 2, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-19, 2, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-19, 9, 0.0)]) }

  let(:list_e2) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(5, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-14, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-14, 6, 0.0),
                                                 RSPEC_GEO_FACTORY.point(5, 6, 0.0),
                                                 RSPEC_GEO_FACTORY.point(5, -1, 0.0)]) }

  let(:list_e3) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-11, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-11, -5, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, -5, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-11, -1, 0.0)]) }

  let(:list_e4) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-3, -9, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-3, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, -9, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-3, -9, 0.0)]) }

  let(:list_e5) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-7, -9, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, -5, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-11, -5, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-11, -9, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-7, -9, 0.0)]) }

  let(:shape_e) { RSPEC_GEO_FACTORY.collection([RSPEC_GEO_FACTORY.polygon(list_e1),
                                                RSPEC_GEO_FACTORY.polygon(list_e2),
                                                RSPEC_GEO_FACTORY.polygon(list_e3),
                                                RSPEC_GEO_FACTORY.polygon(list_e4),
                                                RSPEC_GEO_FACTORY.polygon(list_e5)]) }

  let(:shape_e1) { shape_e.geometry_n(0) }
  let(:shape_e2) { shape_e.geometry_n(1) }
  let(:shape_e3) { shape_e.geometry_n(2) }
  let(:shape_e4) { shape_e.geometry_n(3) }
  let(:shape_e5) { shape_e.geometry_n(4) }

  let(:poly_e1) { RSPEC_GEO_FACTORY.polygon(list_e1) }
  let(:poly_e2) { RSPEC_GEO_FACTORY.polygon(list_e2) }
  let(:poly_e3) { RSPEC_GEO_FACTORY.polygon(list_e3) }
  let(:poly_e4) { RSPEC_GEO_FACTORY.polygon(list_e4) }
  let(:poly_e5) { RSPEC_GEO_FACTORY.polygon(list_e5) }

  let(:shape_f1) { RSPEC_GEO_FACTORY.line(RSPEC_GEO_FACTORY.point(-20, -1, 0.0),
                                          RSPEC_GEO_FACTORY.point(-26, -6, 0.0)) }

  let(:shape_f2) { RSPEC_GEO_FACTORY.line(RSPEC_GEO_FACTORY.point(-21, -4, 0.0),
                                          RSPEC_GEO_FACTORY.point(-31, -4, 0.0)) }

  let(:shape_f) { RSPEC_GEO_FACTORY.multi_line_string([shape_f1, shape_f2]) }

  let(:list_g1) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(28, 2.3, 0.0),
                                                 RSPEC_GEO_FACTORY.point(23, -1.7, 0.0),
                                                 RSPEC_GEO_FACTORY.point(26, -4.8, 0.0),
                                                 RSPEC_GEO_FACTORY.point(28, 2.3, 0.0)]) }

  let(:list_g2) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(22, -6.8, 0.0),
                                                 RSPEC_GEO_FACTORY.point(22, -9.8, 0.0),
                                                 RSPEC_GEO_FACTORY.point(16, -6.8, 0.0),
                                                 RSPEC_GEO_FACTORY.point(22, -6.8, 0.0)]) }

  let(:list_g3) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(16, 2.3, 0.0),
                                                 RSPEC_GEO_FACTORY.point(14, -2.8, 0.0),
                                                 RSPEC_GEO_FACTORY.point(18, -2.8, 0.0),
                                                 RSPEC_GEO_FACTORY.point(16, 2.3, 0.0)]) }

  let(:shape_g) { RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(list_g1),
                                                   RSPEC_GEO_FACTORY.polygon(list_g2),
                                                   RSPEC_GEO_FACTORY.polygon(list_g3)]) }
  let(:shape_g1) { shape_g.geometry_n(0) }
  let(:shape_g2) { shape_g.geometry_n(1) }
  let(:shape_g3) { shape_g.geometry_n(2) }

  let(:shape_h) { RSPEC_GEO_FACTORY.multi_point([point5,
                                                 point6,
                                                 point7,
                                                 point8,
                                                 point9]) }

  let(:shape_i) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(27, -14, 0.0),
                                                 RSPEC_GEO_FACTORY.point(18, -21, 0.0),
                                                 RSPEC_GEO_FACTORY.point(20, -12, 0.0),
                                                 RSPEC_GEO_FACTORY.point(25, -23, 0.0)]) }

  let(:shape_j) { RSPEC_GEO_FACTORY.collection([shape_g, shape_h, shape_i]) }

  let(:list_k) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-33, -11, 0.0),
                                                RSPEC_GEO_FACTORY.point(-33, -23, 0.0),
                                                RSPEC_GEO_FACTORY.point(-21, -23, 0.0),
                                                RSPEC_GEO_FACTORY.point(-21, -11, 0.0),
                                                RSPEC_GEO_FACTORY.point(-27, -13, 0.0),
                                                RSPEC_GEO_FACTORY.point(-33, -11, 0.0),
  ]) }

  let(:shape_k) { RSPEC_GEO_FACTORY.polygon(list_k) }

  let(:shape_l) { RSPEC_GEO_FACTORY.line(RSPEC_GEO_FACTORY.point(-16, -15.5, 0.0),
                                         RSPEC_GEO_FACTORY.point(-22, -20.5, 0.0)) }

  let(:list_t1) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-1, 1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(1, 1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(1, -1, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-1, -1, 0.0)]) }

  let(:list_t2) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-2, 2, 0.0),
                                                 RSPEC_GEO_FACTORY.point(2, 2, 0.0),
                                                 RSPEC_GEO_FACTORY.point(2, -2, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-2, -2, 0.0)]) }

  let(:list_t3) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-3, 3, 0.0),
                                                 RSPEC_GEO_FACTORY.point(3, 3, 0.0),
                                                 RSPEC_GEO_FACTORY.point(3, -3, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-3, -3, 0.0)]) }

  let(:list_t4) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-4, 4, 0.0),
                                                 RSPEC_GEO_FACTORY.point(4, 4, 0.0),
                                                 RSPEC_GEO_FACTORY.point(4, -4, 0.0),
                                                 RSPEC_GEO_FACTORY.point(-4, -4, 0.0)]) }

  let(:box_1) { RSPEC_GEO_FACTORY.polygon(list_t1) }
  let(:box_2) { RSPEC_GEO_FACTORY.polygon(list_t2) }
  let(:box_3) { RSPEC_GEO_FACTORY.polygon(list_t3) }
  let(:box_4) { RSPEC_GEO_FACTORY.polygon(list_t4) }

  let(:point_m1_p0) { RSPEC_GEO_FACTORY.point(33, 28) } # upper left corner of M1

  let(:e1_and_e2) { RSPEC_GEO_FACTORY.parse_wkt('POLYGON ((-9.0 6.0 0.0, -9.0 2.0 0.0, ' \
                                                '-14.0 2.0 0.0, -14.0 6.0 0.0, ' \
                                                '-9.0 6.0 0.0))') }
  let(:e1_or_e2) { RSPEC_GEO_FACTORY.parse_wkt('POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, ' \
                                               '-9.0 6.0 0.0, 5.0 6.0 0.0, ' \
                                               '5.0 -1.0 0.0, -14.0 -1.0 0.0, ' \
                                               '-14.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0))') }
  let(:e1_and_e4) { RSPEC_GEO_FACTORY.parse_wkt('GEOMETRYCOLLECTION EMPTY') }
  let(:e1_or_e5) { RSPEC_GEO_FACTORY.parse_wkt('MULTIPOLYGON (((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, ' \
                                               '-19.0 2.0 0.0, -19.0 9.0 0.0)), ' \
                                               '((-7.0 -9.0 0.0, -7.0 -5.0 0.0, ' \
                                               '-11.0 -5.0 0.0, -11.0 -9.0 0.0, ' \
                                               '-7.0 -9.0 0.0)))') }

  let(:p16_on_a) { RSPEC_GEO_FACTORY.parse_wkt('POINT (-23.0 18.0 0.0)') }

  let(:list_box_a) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  }

  # sub_list_box_a is completely inside list_box_a, specifically so that it can be found in list_box_a
  let(:sub_list_box_a) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0.5, 0.5, 0.0),
                                   RSPEC_GEO_FACTORY.point(0.5, 9.5, 0.0),
                                   RSPEC_GEO_FACTORY.point(9.5, 9.5, 0.0),
                                   RSPEC_GEO_FACTORY.point(9.5, 0.5, 0.0),
                                   RSPEC_GEO_FACTORY.point(0.5, 0.5, 0.0)])
  }

  let(:list_box_b) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  }

  let(:list_box_c) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 0, 0.0)])
  }

  let(:list_box_e) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0)])
  }

  let(:box_a) { RSPEC_GEO_FACTORY.polygon(list_box_a) }
  let(:box_b) { RSPEC_GEO_FACTORY.polygon(list_box_b) }
  let(:box_c) { RSPEC_GEO_FACTORY.polygon(list_box_c) }
  let(:box_e) { RSPEC_GEO_FACTORY.polygon(list_box_e) }

  let(:new_box_a) { FactoryBot.create(
    :geographic_item,
    geography: RSPEC_GEO_FACTORY.multi_polygon([box_a]),
    by: geo_user) }

  let(:new_box_b) { FactoryBot.create(:geographic_item,
                                      geography: RSPEC_GEO_FACTORY.multi_polygon([box_b]),
                                      by: geo_user) }

  let(:new_box_c) { FactoryBot.create(:geographic_item,
                                      geography: RSPEC_GEO_FACTORY.multi_polygon([box_c]),
                                      by: geo_user) }

  let(:new_box_e) { FactoryBot.create(:geographic_item,
                                      geography: RSPEC_GEO_FACTORY.multi_polygon([box_e]),
                                      by: geo_user) }

=begin

  Small World is a 2 by 2 matrix of squares, centered aroung co-ordinates 0, 0, and
  extending 10 degrees in each cardinal direction.

* E and F are level 0, and children of planet_earth
* A and B are level 1, and children of E
* C and D are level 1, and children of F

-10,  10 |-------------------|  10,  10 |---------|---------|  |---------|---------|
         |                   |          |         |         |  |         |         |
         |                   |          |    D    |    A    |  |         |         |
         |                   |          |         |         |  |         |         |
         |                   |          |         |         |  |         |         |
         |       0, 0        |          |---------|---------|  |    F    |    E    |
         |                   |          |         |         |  |         |         |
         |                   |          |    C    |    B    |  |         |         |
         |                   |          |         |         |  |         |         |
         |                   |          |         |         |  |         |         |
-10, -10 |-------------------|  10, -10 |---------|---------|  |---------|---------|

                                        |---------|---------|
                                        |         ||-------||
                                        |         ||sub_box||
                                        |         ||   a   ||
                                        |         ||-------||
                                        |         |---------|
                                        |         ||-------||
                                        |         ||sub_box||
                                        |         ||   b   ||
                                        |         ||-------||
                                        |---------|---------|




=end

  let(:area_a) {
    FactoryBot.create(
      :level1_geographic_area,
      name: 'A',
      geographic_area_type: state_gat,
      iso_3166_a3: nil,
      iso_3166_a2: nil,
      parent: area_e,
      by: geo_user,
      geographic_areas_geographic_items_attributes: [{geographic_item: new_box_a }]) # NOTE: data_origin nil
  }

  let(:area_b) {
    FactoryBot.create(
        :level1_geographic_area,
        name: 'B',
        geographic_area_type: parish_gat,
        iso_3166_a3: nil,
        iso_3166_a2: nil,
        parent: area_e,
        by: geo_user,
        geographic_areas_geographic_items_attributes: [{geographic_item: new_box_b}])
  }

  let(:area_e) {
    FactoryBot.create(
      :level0_geographic_area,
      name: 'E',
      geographic_area_type: country_gat,
      iso_3166_a3: nil,
      iso_3166_a2: nil,
      parent: parent_earth,
      by: geo_user,
      geographic_areas_geographic_items_attributes: [{geographic_item: new_box_e}])
  }

  let(:area_f) {
    FactoryBot.create(
      :level0_geographic_area,
      name: 'F',
      geographic_area_type: land_mass_gat,
      iso_3166_a3: nil,
      iso_3166_a2: nil,
      parent: parent_earth,
      by: geo_user,
      geographic_areas_geographic_items_attributes: [{geographic_item: new_box_e}])
  }

  # Collecting Events
  let(:ce_p0) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p0') }

  let(:gr00) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr00',
                                 collecting_event: ce_p0,
                                 error_geographic_item: item_d,
                                 geographic_item: p0) } #  1
  let(:gr10) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr10',
                                 collecting_event: ce_p0,
                                 geographic_item: p10) } #  2

  let(:ce_area_d) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_area_d') }
  let(:gr_area_d) { FactoryBot.create(:georeference_verbatim_data,
                                      api_request: 'gr_area_d',
                                      collecting_event: ce_area_d,
                                      geographic_item: item_d) }

  let(:ce_p5) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p5') }
  let(:gr05) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr05',
                                 collecting_event: ce_p5,
                                 geographic_item: p5) }

  let(:gr15) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr15',
                                 collecting_event: ce_p5,
                                 geographic_item: p15) }

  let(:ce_area_v) { FactoryBot.create(:collecting_event,
                                      verbatim_label: 'ce_area_v collecting event test') }

  let(:ce_p6) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p6') }

  let(:gr06) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr06',
                                 collecting_event: ce_p6,
                                 geographic_item: p6) }

  let(:gr16) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr16',
                                 collecting_event: ce_p6,
                                 geographic_item: p16) }

  let(:ce_p7) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p7') }

  let(:gr07) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr07',
                                 collecting_event: ce_p7,
                                 geographic_item: p7) }

  let(:gr17) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr17',
                                 collecting_event: ce_p7,
                                 geographic_item: p17) }

  let(:ce_p8) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p8') }

  let(:gr08) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr08',
                                 collecting_event: ce_p8,
                                 geographic_item: p8) }

  let(:gr18) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr18',
                                 collecting_event: ce_p8,
                                 error_geographic_item: b2,
                                 geographic_item: p18) }

  let(:ce_p9) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p9') }

  let(:gr09) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr09',
                                 collecting_event: ce_p9,
                                 geographic_item: p9) }

  let(:gr19) { FactoryBot.create(:georeference_verbatim_data,
                                 api_request: 'gr19',
                                 collecting_event: ce_p9,
                                 error_geographic_item: b,
                                 geographic_item: p19) }


  let(:ce_a) {
    CollectingEvent.create!(
      start_date_year: 1971,
      start_date_month: 1,
      start_date_day: 1,
      verbatim_locality: 'environs of A',
      verbatim_label: 'Eh?',
      geographic_area: area_a,
      project: geo_project,
      by: geo_user)
  }

  # collectors: daryl, saygon
  let(:ce_b) {
    CollectingEvent.create!(
      start_date_year: 1982,
      start_date_month: 2,
      start_date_day: 2,
      verbatim_locality: 'environs of B',
      verbatim_label: 'Bah',
      geographic_area: area_b,
      project: geo_project,
      by: geo_user,
      collector_roles_attributes: [{person: sargon , project: geo_project, by: geo_user},
                                   {person: daryl, project: geo_project, by: geo_user}]
    )
  }

  let(:ce_p4s) { FactoryBot.create(:collecting_event,
                                   start_date_year: 1988,
                                   start_date_month: 8,
                                   start_date_day: 8,
                                   verbatim_label: '@ce_p4s',
                                   geographic_area: nil) }

  let(:gr_p4s) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request: 'gr_p4s',
                                   collecting_event: ce_p4s,
                                   error_geographic_item: nil,
                                   geographic_item: GeographicItem.new(geography: new_box_c.st_centroid, by: geo_user)) }

  # Collection objects
  let(:p_a) { GeographicItem.create!(geography: new_box_a.st_centroid, by: geo_user) }
  let(:p_b) { GeographicItem.create!(geography: new_box_b.st_centroid, by: geo_user) }

  let(:gr_a) { Georeference::VerbatimData.create!(
    api_request: 'area_a',
    collecting_event: ce_a,
    error_geographic_item: new_box_a,
    geographic_item: p_a,
    by: geo_user,
    project: geo_project)
  }

  let(:polygon_inner) {
    RSPEC_GEO_FACTORY.line_string(
      [RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0),
       RSPEC_GEO_FACTORY.point(7.5, -2.5, 0.0),
       RSPEC_GEO_FACTORY.point(7.5, -7.5, 0.0),
       RSPEC_GEO_FACTORY.point(2.5, -7.5, 0.0),
       RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0)])
  }

  let(:err_b) { GeographicItem.create!(geography: RSPEC_GEO_FACTORY.polygon(polygon_inner), by: geo_user) }

  let(:gr_b) {
    Georeference::VerbatimData.create!(
      api_request: 'area_b',
      collecting_event: ce_b,
      error_geographic_item: err_b,
      geographic_item: p_b,
      by: geo_user,
      project: geo_project)
  }

  # need some people
  let(:sargon) { Person.create!(first_name: 'of Akkad', last_name: 'Sargon', by: geo_user) }
  let(:andy) { Person.create!(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author', by: geo_user) }
  let(:daryl) { Person.create!(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon', by: geo_user) }
  let(:ted) { Person.create!(last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC', by: geo_user) }
  let(:bill) { Person.create!(first_name: 'Bill', last_name: 'Ardson', by: geo_user) }

  #
  # Possible logical break (above/below)
  #

  # GeographicItem interactions
  let(:p0) { FactoryBot.create(:geographic_item, geography: point0.as_binary, by: geo_user) } # 0
  let(:p1) { FactoryBot.create(:geographic_item, geography: point1.as_binary, by: geo_user) }
  let(:p2) { FactoryBot.create(:geographic_item, geography: point2.as_binary, by: geo_user) } # 2
  let(:p3) { FactoryBot.create(:geographic_item, geography: point3.as_binary, by: geo_user) } # 3
  let(:p5) { FactoryBot.create(:geographic_item, geography: point5.as_binary, by: geo_user) } # 5
  let(:p6) { FactoryBot.create(:geographic_item, geography: point6.as_binary, by: geo_user) } # 6
  let(:p7) { FactoryBot.create(:geographic_item, geography: point7.as_binary, by: geo_user) } # 7
  let(:p8) { FactoryBot.create(:geographic_item, geography: point8.as_binary, by: geo_user) } # 8
  let(:p9) { FactoryBot.create(:geographic_item, geography: point9.as_binary, by: geo_user) } # 9
  let(:p10) { FactoryBot.create(:geographic_item, geography: point10.as_binary, by: geo_user) } # 10
  let(:p11) { FactoryBot.create(:geographic_item, geography: point11.as_binary, by: geo_user) } # 11
  let(:p12) { FactoryBot.create(:geographic_item, geography: point12.as_binary, by: geo_user) } # 10
  let(:p13) { FactoryBot.create(:geographic_item, geography: point13.as_binary, by: geo_user) } # 10
  let(:p14) { FactoryBot.create(:geographic_item, geography: point14.as_binary, by: geo_user) } # 14
  let(:p15) { FactoryBot.create(:geographic_item, geography: point15.as_binary, by: geo_user) } # 15
  let(:p16) { FactoryBot.create(:geographic_item, geography: point16.as_binary, by: geo_user) } # 16
  let(:p17) { FactoryBot.create(:geographic_item, geography: point17.as_binary, by: geo_user) } # 17
  let(:p18) { FactoryBot.create(:geographic_item, geography: point18.as_binary, by: geo_user) } # 18
  let(:p19) { FactoryBot.create(:geographic_item, geography: point19.as_binary, by: geo_user) } # 19

  let(:a) { FactoryBot.create(:geographic_item, geography: shape_a1.as_binary, by: geo_user) } # 24
  let(:b) { FactoryBot.create(:geographic_item, geography: shape_b.as_binary, by: geo_user) } # 27
  let(:c1) { FactoryBot.create(:geographic_item, geography: shape_c1, by: geo_user) } # 28
  let(:c2) { FactoryBot.create(:geographic_item, geography: shape_c2, by: geo_user) } # 28
  let(:c3) { FactoryBot.create(:geographic_item, geography: shape_c3, by: geo_user) } # 29
  let(:c) { FactoryBot.create(:geographic_item,
                              geography: shape_c.as_binary, by: geo_user) } # 30

  let(:d) { FactoryBot.create(:geographic_item, geography: shape_d.as_binary, by: geo_user) }

  let(:b1) { FactoryBot.create(:geographic_item, geography: shape_b_outer.as_binary, by: geo_user) } # 25
  let(:b2) { FactoryBot.create(:geographic_item, geography: shape_b_inner.as_binary, by: geo_user) } # 26
  let(:e0) { e.geo_object } # a collection of polygons
  let(:e1) { FactoryBot.create(:geographic_item, geography: poly_e1.as_binary, by: geo_user) } # 35
  let(:e2) { FactoryBot.create(:geographic_item, geography: poly_e2.as_binary, by: geo_user) } # 33
  let(:e3) { FactoryBot.create(:geographic_item, geography: poly_e3.as_binary, by: geo_user) } # 34
  let(:e4) { FactoryBot.create(:geographic_item, geography: poly_e4.as_binary, by: geo_user) } # 35
  let(:e5) { FactoryBot.create(:geographic_item, geography: poly_e5.as_binary, by: geo_user) } # 35
  let(:e) { FactoryBot.create(:geographic_item,
                              geography: shape_e.as_binary, by: geo_user) } # 37
  let(:f1) { FactoryBot.create(:geographic_item, geography: shape_f1.as_binary, by: geo_user) } # 38
  let(:f2) { FactoryBot.create(:geographic_item, geography: shape_f2.as_binary, by: geo_user) } # 39

  let(:f) { FactoryBot.create(:geographic_item,
                              geography: shape_f.as_binary, by: geo_user) } # 40
  let(:g1) { FactoryBot.create(:geographic_item, geography: shape_g1.as_binary, by: geo_user) } # 41
  let(:g2) { FactoryBot.create(:geographic_item, geography: shape_g2.as_binary, by: geo_user) } # 42
  let(:g3) { FactoryBot.create(:geographic_item, geography: shape_g3.as_binary, by: geo_user) } # 43
  let(:g) { FactoryBot.create(:geographic_item,
                              geography: shape_g.as_binary, by: geo_user) } # 44
  let(:h) { FactoryBot.create(:geographic_item, geography: shape_h.as_binary, by: geo_user) } # 45
  let(:j) { FactoryBot.create(:geographic_item, geography: shape_j, by: geo_user) } # 47
  let(:k) { FactoryBot.create(:geographic_item, geography: shape_k.as_binary, by: geo_user) }
  let(:l) { FactoryBot.create(:geographic_item, geography: shape_l.as_binary, by: geo_user) } # 49

  let(:r) { a.geo_object.intersection(p16.geo_object) }

  let(:item_a) { FactoryBot.create(:geographic_item, geography: box_1, by: geo_user) } # 57
  let(:item_b) { FactoryBot.create(:geographic_item, geography: box_2, by: geo_user) } # 58
  let(:item_c) { FactoryBot.create(:geographic_item, geography: box_3, by: geo_user) } # 59
  let(:item_d) { FactoryBot.create(:geographic_item, geography: box_4, by: geo_user) } # 60

  let(:ce_p1s) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p1s collect_event test', by: geo_user, project: geo_project) }


  # These will have to be updated for use in Feature specs to specifically reference by, project.

  let(:gr01s) { FactoryBot.create(
    :georeference_verbatim_data,
    api_request: 'gr01',
    collecting_event: ce_p1s,
    error_geographic_item: k,
    geographic_item: p1,
    by: geo_user,
    project: geo_project)
  } #  3

  let(:gr11s) { FactoryBot.create(
    :georeference_verbatim_data,
    api_request: 'gr11',
    error_geographic_item: e1,
    collecting_event: ce_p1s,
    geographic_item: p11,
    by: geo_user,
    project: geo_project)
  } #  4

  let(:ce_p2s) { FactoryBot.create(
    :collecting_event,
    verbatim_label: '@ce_p2s collect_event test',
    by: geo_user,
    project: geo_project)
  }

  let(:gr02s) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr02s',
                                  collecting_event: ce_p2s,
                                  error_geographic_item: k,
                                  geographic_item: p2,   by: geo_user,
    project: geo_project) }

  let(:gr121s) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request: 'gr121s',
                                   collecting_event: ce_p2s,
                                   error_geographic_item: e1,
                                   geographic_item: p12,   by: geo_user,
    project: geo_project) }

  let(:ce_p3s) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p3s collect_event test') }

  let(:gr03s) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr03s',
                                  collecting_event: ce_p3s,
                                  error_geographic_item: k,
                                  geographic_item: p3,   by: geo_user,
    project: geo_project) }

  let(:gr13s) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr13s',
                                  collecting_event: ce_p3s,
                                  error_geographic_item: e2,
                                  geographic_item: p13,   by: geo_user,
    project: geo_project) }

  # real world objects
  let(:ga_data_origin) { 'Test Data' }
  let(:parent_earth) { GeographicArea.create!(
    name: 'Earth',
    parent_id: nil,
    level0_id: nil,
    geographic_area_type: planet_gat,
    data_origin: ga_data_origin,
    by: geo_user)
  }

  let(:parent_country) {
    ga = GeographicArea.create!(
      name: 'United States of America',
      iso_3166_a3: 'USA',
      iso_3166_a2: 'US',
      parent: parent_earth,
      geographic_area_type: country_gat,
      data_origin: ga_data_origin,
      by: geo_user
    )
  ga.level0 = ga
  ga.save!
  ga
  }

  let(:parent_state) {
    ga = GeographicArea.create!(name: 'Illinois',
                                tdwgID: '74ILL-00',
                                parent: parent_country,
                                geographic_area_type: state_gat,
                                data_origin: ga_data_origin,
                                by: geo_user
                               )
  ga.level1 = ga
  ga.level0 = ga.parent
  ga.save!
  ga
  }

  let(:parent_county) {
    ga = GeographicArea.create!(name: 'Champaign',
                                parent: parent_state,
                                geographic_area_type: county_gat,
                                data_origin: ga_data_origin,
                                by: geo_user
                               )
  ga.level2 = ga
  ga.level1 = ga.parent
  ga.level0 = ga.parent.parent
  ga.save!
  ga
  }

  let!(:country_gat) { GeographicAreaType.create!(name: 'Country', by: geo_user) }
  let!(:state_gat) { GeographicAreaType.create!(name: 'State', by: geo_user) }
  let(:province_gat) { GeographicAreaType.create!(name: 'Province', by: geo_user) }
  let!(:county_gat) { GeographicAreaType.create!(name: 'County',by: geo_user) }
  let(:parish_gat) { GeographicAreaType.create!(name: 'Parish', by: geo_user) }
  let(:planet_gat) { GeographicAreaType.create!(name: 'Planet', by: geo_user) }
  let(:land_mass_gat) { GeographicAreaType.create!(name: 'Land Mass', by: geo_user) }

  let(:cc_shape) { GeoBuild::CHAMPAIGN_CO }
  let(:fc_shape) { GeoBuild::FORD_CO }
  let(:il_shape) { GeoBuild::ILLINOIS }

  let(:champaign) {
    cc = parent_county
    cc.geographic_items << GeographicItem.create!(geography: cc_shape, by: geo_user)
    cc
  }

  let(:illinois) {
    il = champaign.parent
    il.geographic_items << GeographicItem.create!(geography: il_shape, by: geo_user)
    il
  }

  let(:ford) {
    FactoryBot.create(:level2_geographic_area, name: 'Ford', parent: illinois, by: geo_user)
  }

  let(:usa) { illinois.parent }
  let(:earth) {
    usa.parent
  }

=begin

 Objects in Big Boxia.

 Big Boxia is a ... .


4 by 4 matrix of squares:

* Q, R, and S are level 0 spaces, i.e., 'Country'.
* M3 through P4, T and U are level 1 spaces, i.e., 'State (Province)'.
* M1 through P2 are level 2 spaces, i.e., 'County (Parish)'.
* M1-upper_left is at (33, 28).

* Great Northern Land Mass overlays Q, R, and S.

!!!! 0,0 = 33, 28 !!!!

|------|------|------|------| |------|------|------|------|
|      |      |      |      | |                           |
|  M1  |  N1  |  O1  |  P1  | |                           |
|      |      |      |      | |                           |
|------|------|------|------| |                           |
|      |      |      |      | |                           |
|  M2  |  N2  |  O2  |  P2  | |                           |
|      |      |      |      | |                           |
|------|------|------|------| | Great Northern Land Mass  |
|      |      |      |      | |                           |
|  M3  |  N3  |  O3  |  P3  | |                           |
|      |      |      |      | |                           |
|------|------|------|------| |                           |
|      |      |      |      | |                           |
|  M4  |  N4  |  O4  |  P4  | |                           |
|      |      |      |      | |                           |
|------|------|------|------| |------|------|------|------|

Big Boxia overlays Q

|------|------|------|------| |------|------|------|------|
|                           | |             |             |
|                           | |             |             |
|                           | |             |             |
|       Q, aka Big Boxia    | |     QT      |     QU      |
|                           | |             |             |
|                           | |             |             |
|                           | |             |             |
|------|------|------|------| |------|------|------|------|
|             |             | |      |      |      |      |
|             |             | | RM3  | RN3  | SO3  | SP3  |
|             |             | |      |      |      |      |
|      R      |      S      | |------|------|------|------|
|             |             | |      |      |      |      |
|             |             | | RM4  | RN4  | SO4  | SP4  |
|             |             | |      |      |      |      |
|------|------|------|------| |------|------|------|------|

|------|------|------|------| -
|      |      |      |      | |
| QTM1 | QTN1 | QUO1 | QUP1 | |
|      |      |      |      | |
|------|------|------|------| | <== Big Boxia overlays Q
|      |      |      |      | |
| QTM2 | QTN2 | QUO2 | QUP2 | |
|      |      |      |      | |
|------|------|------|------| -
|      |      |      |      |
| RM3  | RN3  | SO3  | SP3  |
|      |      |      |      |
|------|------|------|------|
|      |      |      |      |
| RM4  | RN4  | SO4  | SP4  |
|      |      |      |      |
|------|------|------|------|

     /\
     ||

Old Boxia overlays R, and western Q.

|------|------|------|------| |------|------|------|------|
|             |      |      | |      |      |      |      |
|             |  O1  |  P1  | |      | QTN1 | QUO1 |      |
|             |      |      | |      |      |      |      |
|             |------|------| |      |------|------|      |
|             |      |      | |      |      |      |      |
|             |  O2  |  P2  | |      | QTN2 | QUO2 |      |
|     Old     |      |      | | West |      |      | East |
|    Boxia    |------|------| |Boxia |------|------|Boxia |
|             |      |      | |      |      |      |      |
|             |  O3  |  P3  | |      | RN3  | SO3  |      |
|             |      |      | |      |      |      |      |
|             |------|------| |      |------|------|      |
|             |      |      | |      |      |      |      |
|             |  O4  |  P4  | |      | RN4  | SO4  |      |
|             |      |      | |      |      |      |      |
|------|------|------|------| |------|------|------|------|

Two different shapes with the same name, 'East Boxia', and
'East Boxia' (the square) is also listed as a state in
'Old Boxia'.

|------|------|------|------| |------|------|------|------|
|      |      |      |      | |      |      |             |
|  M1  |  N1  |  O1  |      | | QTM1 | QTN1 |             |
|      |      |      |      | |      |      |     East    |
|------|------|------|      | |------|------|    Boxia    |
|      |      |      |      | |      |      |             |
|  M2  |  N2  |  O2  |      | | QTM2 | QTN2 |             |
|      |      |      | East | |      |      |             |
|------|------|------|Boxia | |------|------|------|------|
|      |      |      |      | |      |      |      |      |
|  M3  |  N3  |  O3  |      | | RM3  | RN3  | SO3  | SP3  |
|      |      |      |      | |      |      |      |      |
|------|------|------|      | |------|------|------|------|
|      |      |      |      | |      |      |      |      |
|  M4  |  N4  |  O4  |      | | RM4  | RN4  | SO4  | SP4  |
|      |      |      |      | |      |      |      |      |
|------|------|------|------| |------|------|------|------|

=end


# TODO: All of these need by: and project:

  let(:big_boxia) {
    [area_q, area_qtm1, area_qtm2, area_qtn1, area_qtn2_1, area_qtn2_2,
     area_qup2,
     area_r, area_rm3, area_rm4, area_rn3, area_rn4,
     area_m3, area_n3, area_m4, area_n4, area_n2,
     area_s, area_t_1, area_t_2, area_u,
     area_m1, area_m2, area_n1,
     area_old_boxia, area_big_boxia,
     west_boxia, east_boxia].each
  }

  let(:area_big_boxia) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'Big Boxia',
                             geographic_area_type: country_gat,
                             iso_3166_a3: nil,
                             iso_3166_a2: nil,
                             parent: area_land_mass)
  area.geographic_items << item_bb
  area.save!
  area
  }

  # objects in Q
  let(:area_u) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'QU',
                             tdwgID: nil,
                             geographic_area_type: state_gat,
                             parent: area_q)
  area.geographic_items << item_u
  area.save!
  area
  }
  let(:area_q) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'Q',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'QQQ',
                             iso_3166_a2: 'QQ',
                             parent: area_land_mass)
  area.geographic_items << item_q
  area.save!
  area
  }

  let(:area_old_boxia) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'Old Boxia',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'OB1',
                             iso_3166_a2: nil,
                             parent: area_land_mass)
  area.geographic_items << item_ob
  area.save!
  area
  }
  let(:area_qtm2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QTM2',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.geographic_items << item_m1
  area.save!
  area
  }
  let(:area_quo1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QUO1',
                             geographic_area_type: parish_gat,
                             parent: area_u)
  # @area_quo1.geographic_items << @item_o1
  area.save!
  area
  }
  let(:area_quo2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QUO2',
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.geographic_items << item_o2
  area.save!
  area
  }
  let(:area_qup1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QUP1',
                             tdwgID: nil,
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.geographic_items << item_p1
  area.save!
  area
  }
  let(:area_qtn2_1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QTN2',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.geographic_items << item_n2
  area.save!
  area
  }
  let(:area_qtn2_2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QTN2',
                             geographic_area_type: county_gat,
                             parent: area_t_2)
  area.geographic_items << item_n2
  area.save!
  }

  # objects in S
  let(:area_s) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'S',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'SSS',
                             iso_3166_a2: 'SS',
                             parent: area_land_mass)
  area.geographic_items << item_s
  area.save!
  area
  }

  # objects in R
  let(:area_r) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'R',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'RRR',
                             iso_3166_a2: 'RR',
                             parent: area_land_mass)
  area.geographic_items << item_r
  area.save!
  area
  }
  let(:area_rm3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'RM3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_m3
  area.save!
  area
  }

  let(:area_rm4) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'RM4',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_m4
  area.save!
  area
  }

  let(:area_rn3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'RN3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n3
  area.save!

  area
  }

  let(:area_rn4) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'RN4',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n4
  area.save!
  area
  }

  let(:area_rn3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'RN3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n3
  area.save!
  area
  }

  let(:area_m3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'M3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_m3
  area.save!
  area
  }

  let(:area_n3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'N3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n3
  area.save!
  area
  }

  let(:area_m4) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'M4',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_m4
  area.save!
  area
  }

  let(:area_n4) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'N4',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n4
  area.save!
  area
  }

  let(:gr_n3_ob) { FactoryBot.create(:georeference_verbatim_data,
                                     api_request: 'gr_n3_ob',
                                     collecting_event: ce_old_boxia_2,
                                     error_geographic_item: item_ob,
                                     geographic_item: GeographicItem.new(geography: item_n3.st_centroid)) }
  let(:ce_old_boxia_2) { FactoryBot.create(:collecting_event,
                                           start_date_year: 1993,
                                           start_date_month: 3,
                                           start_date_day: 3,
                                           verbatim_label: '@ce_old_boxia_2',
                                           geographic_area: area_old_boxia) }
  let(:item_m4) { FactoryBot.create(:geographic_item, geography: shape_m4) }
  let(:item_r) { FactoryBot.create(:geographic_item, geography: shape_r) }
  let(:shape_r) { RspecGeoHelpers.make_multipolygon(shape_m3[0]
    .exterior_ring.points[0], 0, 0, 2, 2) }
  let(:shape_m4) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 3, 1, 1) }
  # building stuff in R

  # western big boxia
  let(:west_boxia) { [area_west_boxia_1, area_west_boxia_3].each }
  let(:area_west_boxia_1) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'West Boxia',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'WB1',
                             iso_3166_a2: nil,
                             parent: area_land_mass)
  area.geographic_items << item_wb
  area.save!
  area
  }
  let(:area_west_boxia_3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'West Boxia',
                             geographic_area_type: state_gat,
                             iso_3166_a3: 'WB3',
                             iso_3166_a2: nil,
                             parent: area_old_boxia)
  area.geographic_items << item_wb
  area.save!
  area
  }

  let(:co_x) { FactoryBot.create(:valid_collection_object) }

  let(:ce_n3) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1982,
                                  start_date_month: 2,
                                  start_date_day: 2,
                                  end_date_year: 1984,
                                  end_date_month: 9,
                                  end_date_day: 15,
                                  verbatim_locality: 'Greater Boxia Lake',
                                  verbatim_label: '@ce_n3',
                                  geographic_area: area_n3) }
  let(:gr_n3) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_n3',
                                  collecting_event: ce_n3,
                                  error_geographic_item: item_n3,
                                  geographic_item: GeographicItem.new(geography: item_n3.st_centroid)) }
  let(:co_n3) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_n3 }) }
  let(:area_n3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'N3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n3
  area.save!
  area
  }
  let(:shape_m3) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 2, 1, 1) }
  let(:item_n3) { FactoryBot.create(:geographic_item, geography: shape_n3) }
  let(:shape_n3) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 1, 2, 1, 1) }

  # build the collecting event for an object in P1(B), part of Big Boxia
  let(:ce_p1b) { FactoryBot.create(:collecting_event,
                                   start_date_year: 1974,
                                   start_date_month: 4,
                                   start_date_day: 4,
                                   verbatim_label: '@ce_p1b',
                                   geographic_area: area_p1b) }
  let(:co_p1b) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_p1b }) }
  let(:gr_p1b) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request: 'gr_p1b',
                                   collecting_event: ce_p1b,
                                   error_geographic_item: item_p1b,
                                   geographic_item: GeographicItem.new(geography: item_p1b.st_centroid)) }
  let(:area_land_mass) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'Great Northern Land Mass',
                             geographic_area_type: land_mass_gat,
                             iso_3166_a3: nil,
                             iso_3166_a2: nil,
                             parent: earth)
  area.geographic_items << item_w
  area.save!
  area
  }
  let(:area_p1b) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'P1B',
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.level0 = area_u
  area.geographic_items << item_p1b
  area.save!
  area
  }

  let(:shape_p1b) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 3, 0, 1, 1) }
  let(:shape_q) { RspecGeoHelpers.make_multipolygon(shape_m1[0].exterior_ring.points[0], 0, 0, 4, 2) }
  let(:shape_m1) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 0, 1, 1) }
  let(:shape_ob) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 0, 2, 4) }
  let(:shape_eb_1) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 3, 0, 1, 4) }
  let(:shape_eb_2) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 2, 0, 2, 2) }
  let(:shape_wb) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 0, 1, 4) }
  let(:shape_w) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 0, 4, 4) }
  let(:shape_u) { RspecGeoHelpers.make_multipolygon(shape_o1[0].exterior_ring.points[0], 0, 0, 2, 2) }
  let(:shape_o1) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 2, 0, 1, 1) }

  # secondary country shapes
  # same shape as Q, different object
  let(:item_bb) { FactoryBot.create(:geographic_item, geography: shape_q) }

  # superseded country shapes
  let(:item_q) { FactoryBot.create(:geographic_item, geography: shape_q) }
  let(:item_u) { FactoryBot.create(:geographic_item, geography: shape_u) }
  let(:item_ob) { FactoryBot.create(:geographic_item, geography: shape_ob) }
  let(:item_eb_1) { FactoryBot.create(:geographic_item, geography: shape_eb_1) }
  let(:item_eb_2) { FactoryBot.create(:geographic_item, geography: shape_eb_2) }
  let(:item_wb) { FactoryBot.create(:geographic_item, geography: shape_wb) }
  let(:item_p1b) { FactoryBot.create(:geographic_item, geography: shape_p1b) }

  # the entire land mass
  let(:item_w) { FactoryBot.create(:geographic_item, geography: shape_w) }

  # some other areas
  let(:east_boxia) { [area_east_boxia_1, area_east_boxia_2, area_east_boxia_2] }
  let(:area_east_boxia_1) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'East Boxia',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'EB1',
                             iso_3166_a2: nil,
                             parent: area_land_mass)
  area.geographic_items << item_eb_1
  area.save!
  area
  }
  let(:area_east_boxia_2) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'East Boxia',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'EB2',
                             iso_3166_a2: nil,
                             parent: area_land_mass)
  area.geographic_items << item_eb_2
  area.save!
  area
  }
  let(:area_east_boxia_3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'East Boxia',
                             geographic_area_type: state_gat,
                             iso_3166_a3: 'EB3',
                             iso_3166_a2: nil,
                             parent: area_old_boxia)
  area.geographic_items << item_eb_2
  area.save!
  area
  }


  # build the collecting event for an object in O1
  let(:ce_o1) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1973,
                                  start_date_month: 3,
                                  start_date_day: 3,
                                  verbatim_label: '@ce_o1',
                                  geographic_area: area_o1) }
  let(:co_o1) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_o1 }) }
  let(:gr_o1) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_o1',
                                  collecting_event: ce_o1,
                                  error_geographic_item: item_o1,
                                  geographic_item: GeographicItem.new(geography: item_o1.st_centroid)) }

  let(:area_o1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'O1',
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.level0 = area_u
  area.geographic_items << item_o1
  area.save!
  area
  }
  let(:item_o1) { FactoryBot.create(:geographic_item, geography: shape_o1) }

  # build the collecting event for an object in O3
  # @ce_o3 has no georeference
  let(:ce_o3) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1983,
                                  start_date_month: 3,
                                  start_date_day: 3,
                                  verbatim_label: '@ce_o3',
                                  geographic_area: area_o3) }
  let(:co_o3) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_o3 }) }
  let(:area_o3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'O3',
                             tdwgID: nil,
                             geographic_area_type: state_gat,
                             parent: area_s)
  area.geographic_items << item_o3
  area.save!
  area
  }
  let(:area_s) {
    area = FactoryBot.create(:level0_geographic_area,
                             name: 'S',
                             geographic_area_type: country_gat,
                             iso_3166_a3: 'SSS',
                             iso_3166_a2: 'SS',
                             parent: area_land_mass)
  area.geographic_items << item_s
  area.save!
  area
  }
  let(:item_s) { FactoryBot.create(:geographic_item, geography: shape_s) }
  let(:shape_s) { RspecGeoHelpers.make_multipolygon(shape_o3[0]
    .exterior_ring.points[0], 0, 0, 2, 2) }
  let(:shape_o3) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 2, 2, 1, 1) }
  let(:item_o3) { FactoryBot.create(:geographic_item, geography: shape_o3) }
  let(:area_so3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'SO3',
                             tdwgID: nil,
                             geographic_area_type: state_gat,
                             parent: area_s)
  area.geographic_items << item_o3
  area.save!
  area
  }

  # build the collecting event for objects in N2
  # @ce_n2 has two GRs
  let(:ce_n2) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1976,
                                  start_date_month: 6,
                                  start_date_day: 6,
                                  verbatim_label: '@ce_n2',
                                  geographic_area: area_n2) }
  let(:co_n2_a) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_n2 }) }
  let(:co_n2_b) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_n2 }) }
  let(:gr_n2_a) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request: 'gr_n2_a',
                                    collecting_event: ce_n2,
                                    error_geographic_item: item_n2,
                                    geographic_item: GeographicItem.new(geography: item_n2.st_centroid)) }
  let(:gr_n2_b) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request: 'gr_n2_b',
                                    collecting_event: ce_n2,
                                    error_geographic_item: item_n2,
                                    geographic_item: GeographicItem.new(geography: item_n2.st_centroid)) }
  let(:area_n2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'N2',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.level0 = area_t_1
  area.geographic_items << item_n2
  area.save!
  area
  }
  let(:area_t_1) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'QT',
                             tdwgID: '10TTT',
                             geographic_area_type: state_gat,
                             parent: area_q)
  area.geographic_items << item_t_1
  area.save!
  area
  }
  let(:item_t_1) { FactoryBot.create(:geographic_item, geography: shape_t_1) }
  let(:shape_t_1) { RspecGeoHelpers.make_multipolygon(shape_m1[0]
    .exterior_ring.points[0], 0, 0, 2, 2) }
  let(:item_n2) { FactoryBot.create(:geographic_item, geography: shape_n2) }
  let(:shape_n2) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 1, 1, 1, 1) }
  let(:area_t_2) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'QT',
                             tdwgID: '20TTT',
                             geographic_area_type: state_gat,
                             parent: area_q)
  area.geographic_items << item_t_2
  area.save!
  area
  }
  let(:item_t_2) { FactoryBot.create(:geographic_item, geography: shape_t_2) }
  let(:shape_t_2) { RspecGeoHelpers.make_multipolygon(shape_m1[0]
    .exterior_ring.points[0], 0, 0, 2, 2) }

  # build the collecting event for objects in N4
  let(:ce_n4) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1986,
                                  start_date_month: 6,
                                  start_date_day: 6,
                                  verbatim_label: '@ce_n4',
                                  geographic_area: area_old_boxia) }
  let(:gr_n4) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_n4',
                                  collecting_event: ce_n4,
                                  error_geographic_item: item_n4,
                                  geographic_item: GeographicItem.new(geography: item_n4.st_centroid)) }
  let(:co_n4) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_n4 }) }

  let(:area_n4) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'N4',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n4
  area.save!
  area
  }

  let(:area_rn4) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'RN4',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_n4
  area.save!
  area
  }
  let(:item_n4) { FactoryBot.create(:geographic_item, geography: shape_n4) }
  let(:shape_n4) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 1, 3, 1, 1) }


  # build the collecting events associated with M1 and M1A
  let(:ce_m1) {
    ce = FactoryBot.create(:collecting_event,
                           start_date_year: 1971,
                           start_date_month: 1,
                           start_date_day: 1,
                           verbatim_locality: 'Lesser Boxia Lake',
                           verbatim_label: '@ce_m1',
                           geographic_area: area_m1)
  td_m1 = FactoryBot.create(:valid_taxon_determination)
  co_m1 = td_m1.taxon_determination_object
  td_m1.otu.name = 'Find me, I\'m in M1!'
  td_m1.otu.save!
  co_m1.collecting_event = ce
  co_m1.save!
  ce.save!
  ce
  }
  let(:co_m1) { ce_m1.collection_objects.first }
  let(:gr_m1) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_m1',
                                  collecting_event: ce_m1,
                                  error_geographic_item: item_m1,
                                  geographic_item: GeographicItem.new(geography: item_m1.st_centroid)) }

  let(:ce_m1a) { FactoryBot.create(:collecting_event,
                                   start_date_year: 1971,
                                   start_date_month: 6,
                                   start_date_day: 6,
                                   verbatim_locality: 'Lesser Boxia Lake',
                                   verbatim_label: '@ce_m1a',
                                   geographic_area: area_m1) }
  let(:co_m1a) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_m1a }) }
  let(:gr_m1a) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request: 'gr_m1a',
                                   collecting_event: ce_m1a,
                                   error_geographic_item: item_m1,
                                   geographic_item: GeographicItem.new(geography: item_m1.st_centroid)) }

  let(:area_m1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'M1',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.level0 = area_t_1
  area.geographic_items << item_m1
  area.save!
  area
  }
  let(:item_m1) { FactoryBot.create(:geographic_item, geography: shape_m1) }
  let(:area_qtm1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QTM1',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.geographic_items << item_m1
  area.save!
  area
  }

  # build the collecting event for objects in V
  # this one is just a collecting event, no georeferences or geographic_area, so, even though it
  # has an otu, that otu can't be found
  let(:ce_v) { FactoryBot.create(:collecting_event,
                                 start_date_year: 1991,
                                 start_date_month: 1,
                                 start_date_day: 1,
                                 verbatim_label: '@ce_v',
                                 geographic_area: nil) }
  let(:co_v) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_v }) }


  # build the collection object for objects in P2B
  let(:ce_p2b) { FactoryBot.create(:collecting_event,
                                   start_date_year: 1978,
                                   start_date_month: 8,
                                   start_date_day: 8,
                                   verbatim_label: '@ce_p2b',
                                   geographic_area: area_p2b) }
  # @gr_p2   = FactoryBot.create(:georeference_verbatim_data,
  #                               api_request: 'gr_p2',
  #                               collecting_event: @ce_p2,
  #                               error_geographic_item: @item_p2,
  #                               geographic_item: GeographicItem.new(geography: @item_p2.st_centroid))
  let(:co_p2b) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_p2b }) }

  let(:area_p2b) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'P2',
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.level0 = area_u
  area.geographic_items << item_p2b
  area.save!
  area
  }
  let(:item_p2b) { FactoryBot.create(:geographic_item, geography: shape_p2b) }
  let(:shape_p2b) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 3, 1, 1, 1) }

  let(:area_qup2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QUP2',
                             tdwgID: nil,
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.geographic_items << item_p2b
  area.save!
  area
  }

  # build the collecting event for objects in P3B
  # @ce_p3b has no georeference
  let(:ce_p3b) { FactoryBot.create(:collecting_event,
                                   start_date_year: 1984,
                                   start_date_month: 4,
                                   start_date_day: 4,
                                   verbatim_label: '@ce_p3b',
                                   geographic_area: area_s) }
  let(:co_p3b) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_p3b }) }


  # buile collecting event for objects in M2
  let(:ce_m2) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1975,
                                  start_date_month: 5,
                                  start_date_day: 5,
                                  verbatim_label: '@ce_m2 in Big Boxia',
                                  geographic_area: area_big_boxia) }
  let(:co_m2) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_m2 }) }
  let(:gr_m2) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_m2 in Big Boxia',
                                  collecting_event: ce_m2,
                                  error_geographic_item: item_m2,
                                  geographic_item: GeographicItem.new(geography: item_m2.st_centroid)) }

  let(:area_m2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'M2',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.level0 = area_t_1
  area.geographic_items << item_m2
  area.save!
  area
  }
  let(:item_m2) { FactoryBot.create(:geographic_item, geography: shape_m2) }
  let(:shape_m2) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 0, 1, 1, 1) }

  # build the collecting event for objects in N1
  let(:ce_n1) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1972,
                                  start_date_month: 2,
                                  start_date_day: 2,
                                  verbatim_label: '@ce_n1',
                                  geographic_area: area_n1) }
  let(:co_n1) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_n1 }) }
  # @gr_n1 = FactoryBot.create(:georeference_verbatim_data,
  #                             api_request: 'gr_n1',
  #                             collecting_event: @ce_n1,
  #                             error_geographic_item: @item_n1,
  #                             geographic_item: GeographicItem.new(geography: @item_n1.st_centroid))

  let(:area_n1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'N1',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.level0 = area_t_1
  area.geographic_items << item_n1
  area.save!
  area
  }
  let(:item_n1) { FactoryBot.create(:geographic_item, geography: shape_n1) }
  let(:shape_n1) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 1, 0, 1, 1) }

  let(:area_qtn1) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'QTN1',
                             geographic_area_type: county_gat,
                             parent: area_t_1)
  area.geographic_items << item_n1
  area.save!
  area
  }

  # build the collecting event for objects in O2
  let(:ce_o2) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1977,
                                  start_date_month: 7,
                                  start_date_day: 7,
                                  verbatim_label: '@ce_o2',
                                  geographic_area: area_o2) }

  let(:gr_o2) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_o2',
                                  collecting_event: ce_o2,
                                  error_geographic_item: item_o2,
                                  geographic_item: GeographicItem.new(geography: item_o2.st_centroid)) }

  let(:co_o2) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_o2 }) }

  let(:area_o2) {
    area = FactoryBot.create(:level2_geographic_area,
                             name: 'O2',
                             geographic_area_type: parish_gat,
                             parent: area_u)
  area.level0 = area_u
  area.geographic_items << item_o2
  area.save!
  area
  }

  let(:item_o2) { FactoryBot.create(:geographic_item, geography: shape_o2, by: geo_user) }
  let(:shape_o2) { RspecGeoHelpers.make_multipolygon(point_m1_p0, 2, 1, 1, 1) }

  # build for collecting event for objects in M3
  let(:ce_m3) { FactoryBot.create(:collecting_event,
                                  start_date_year: 1981,
                                  start_date_month: 1,
                                  start_date_day: 1,
                                  verbatim_label: '@ce_m3',
                                  geographic_area: area_m3) }
  let(:gr_m3) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request: 'gr_m3',
                                  collecting_event: ce_m3,
                                  error_geographic_item: item_m3,
                                  geographic_item: GeographicItem.new(geography: item_m3.st_centroid)) }
  let(:co_m3) { FactoryBot.create(:valid_collection_object, { collecting_event: ce_m3 }) }

  let(:area_m3) {
    area = FactoryBot.create(:level1_geographic_area,
                             name: 'M3',
                             tdwgID: nil,
                             geographic_area_type: province_gat,
                             parent: area_r)
  area.geographic_items << item_m3
  area.save!
  area
  }
  let(:item_m3) { FactoryBot.create(:geographic_item, geography: shape_m3, by: geo_user) }

end
