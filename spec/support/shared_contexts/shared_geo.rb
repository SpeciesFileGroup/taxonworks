# require 'support/shared_contexts/geo/area_a'
# rubocop:disable Metrics/AbcSize

RSPEC_GEO_FACTORY = Gis::FACTORY
shared_context 'stuff for complex geo tests' do

  begin # conversion  of constants to 'let's

    let(:simple_shapes) { {
      point:               'POINT(10 10 0)',
      line_string:         'LINESTRING(0.0 0.0 0.0, 10.0 0.0 0.0)',
      polygon:             'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))',
      multi_point:         'MULTIPOINT((10.0 10.0 0.0), (20.0 20.0 0.0))',
      multi_line_string:   'MULTILINESTRING((0.0 0.0 0.0, 10.0 0.0 0.0), (20.0 0.0 0.0, 30.0 0.0 0.0))',
      multi_polygon:       'MULTIPOLYGON(((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, ' \
                    '0.0 0.0 0.0)),((10.0 10.0 0.0, 20.0 10.0 0.0, 20.0 20.0 0.0, 10.0 20.0 0.0, 10.0 10.0 0.0)))',
      geometry_collection: 'GEOMETRYCOLLECTION( POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, ' \
                    '0.0 10.0 0.0, 0.0 0.0 0.0)), POINT(10 10 0)) '
    }.freeze }

    let(:room2024) { RSPEC_GEO_FACTORY.point(-88.241413, 40.091655, 757) }
    let(:room2020) { RSPEC_GEO_FACTORY.point(-88.241421, 40.091565, 757) }
    let(:room2022) { RSPEC_GEO_FACTORY.point((room2020.x + ((room2024.x - room2020.x) / 2)),
                                             (room2020.y + ((room2024.y - room2020.y) / 2)),
                                             (room2020.z + ((room2024.z - room2020.z) / 2))) }

    let(:rooms20nn) { RSPEC_GEO_FACTORY.multi_point([room2020,
                                                     room2022,
                                                     room2024]) }

    let(:gi_point_a) { RSPEC_GEO_FACTORY.point(-88.241413, 40.091655, 0.0) }
    let(:gi_point_c) { RSPEC_GEO_FACTORY.point(-88.243386, 40.116402, 0.0) }
    let(:gi_point_m) { RSPEC_GEO_FACTORY.point(-88.196736, 40.090091, 0.0) }
    let(:gi_point_u) { RSPEC_GEO_FACTORY.point(-88.204517, 40.110037, 0.0) }
    let(:gi_ls01) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-25, 21, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-25, 16, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-21, 20, 0.0)]) }
    let(:gi_ls02) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-25, 21, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-25, 16, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-21, 20, 0.0)]) }
    let(:gi_polygon) { RSPEC_GEO_FACTORY.polygon(gi_ls02) }
    let(:gi_multi_polygon) { RSPEC_GEO_FACTORY.multi_polygon(
      [RSPEC_GEO_FACTORY.polygon(
        RSPEC_GEO_FACTORY.line_string(
          [RSPEC_GEO_FACTORY.point(-168.16047115799995, -14.520928643999923, 0.0),
           RSPEC_GEO_FACTORY.point(-168.16156979099992, -14.532891533999944, 0.0),
           RSPEC_GEO_FACTORY.point(-168.17308508999994, -14.523695570999877, 0.0),
           RSPEC_GEO_FACTORY.point(-168.16352291599995, -14.519789320999891, 0.0),
           RSPEC_GEO_FACTORY.point(-168.16047115799995, -14.520928643999923, 0.0)]
        )
      ),

       RSPEC_GEO_FACTORY.polygon(
         RSPEC_GEO_FACTORY.line_string(
           [RSPEC_GEO_FACTORY.point(-170.62006588399993, -14.254571221999868, 0.0),
            RSPEC_GEO_FACTORY.point(-170.59101314999987, -14.264825127999885, 0.0),
            RSPEC_GEO_FACTORY.point(-170.5762426419999, -14.252536716999927, 0.0),
            RSPEC_GEO_FACTORY.point(-170.5672501289999, -14.258558851999851, 0.0),
            RSPEC_GEO_FACTORY.point(-170.5684708319999, -14.27092864399988, 0.0),
            RSPEC_GEO_FACTORY.point(-170.58417721299995, -14.2777645809999, 0.0),
            RSPEC_GEO_FACTORY.point(-170.6423233709999, -14.280694268999909, 0.0),
            RSPEC_GEO_FACTORY.point(-170.65929114499988, -14.28525155999995, 0.0),
            RSPEC_GEO_FACTORY.point(-170.68358313699994, -14.302829684999892, 0.0),
            RSPEC_GEO_FACTORY.point(-170.7217911449999, -14.353448174999883, 0.0),
            RSPEC_GEO_FACTORY.point(-170.74864661399988, -14.374688408999873, 0.0),
            RSPEC_GEO_FACTORY.point(-170.75548255099991, -14.367120049999912, 0.0),
            RSPEC_GEO_FACTORY.point(-170.79645748599992, -14.339939059999907, 0.0),
            RSPEC_GEO_FACTORY.point(-170.82282467399992, -14.326755466999956, 0.0),
            RSPEC_GEO_FACTORY.point(-170.83124752499987, -14.319431247999944, 0.0),
            RSPEC_GEO_FACTORY.point(-170.78864498599992, -14.294528903999918, 0.0),
            RSPEC_GEO_FACTORY.point(-170.77257239499986, -14.291436455999929, 0.0),
            RSPEC_GEO_FACTORY.point(-170.7378637359999, -14.292087497999887, 0.0),
            RSPEC_GEO_FACTORY.point(-170.72150631399987, -14.289239190999936, 0.0),
            RSPEC_GEO_FACTORY.point(-170.69847571499992, -14.260511976999894, 0.0),
            RSPEC_GEO_FACTORY.point(-170.66144771999987, -14.252373955999872, 0.0),
            RSPEC_GEO_FACTORY.point(-170.62006588399993, -14.254571221999868, 0.0)]
         )
       ),

       RSPEC_GEO_FACTORY.polygon(
         RSPEC_GEO_FACTORY.line_string(
           [RSPEC_GEO_FACTORY.point(-169.44013424399992, -14.245293877999913, 0.0),
            RSPEC_GEO_FACTORY.point(-169.44713294199988, -14.255629164999917, 0.0),
            RSPEC_GEO_FACTORY.point(-169.46015377499987, -14.250420830999914, 0.0),
            RSPEC_GEO_FACTORY.point(-169.46808834499996, -14.258721612999906, 0.0),
            RSPEC_GEO_FACTORY.point(-169.4761856759999, -14.262383721999853, 0.0),
            RSPEC_GEO_FACTORY.point(-169.48497473899994, -14.261976820999848, 0.0),
            RSPEC_GEO_FACTORY.point(-169.49486243399994, -14.257256768999937, 0.0),
            RSPEC_GEO_FACTORY.point(-169.49836178299995, -14.2660458309999, 0.0),
            RSPEC_GEO_FACTORY.point(-169.50426184799989, -14.270603122999944, 0.0),
            RSPEC_GEO_FACTORY.point(-169.51252193899995, -14.271742445999891, 0.0),
            RSPEC_GEO_FACTORY.point(-169.52281653599988, -14.27092864399988, 0.0),
            RSPEC_GEO_FACTORY.point(-169.52550208199995, -14.258965752999941, 0.0),
            RSPEC_GEO_FACTORY.point(-169.52928626199989, -14.248793226999894, 0.0),
            RSPEC_GEO_FACTORY.point(-169.53477942599991, -14.241143487999878, 0.0),
            RSPEC_GEO_FACTORY.point(-169.54267330599987, -14.236748955999886, 0.0),
            RSPEC_GEO_FACTORY.point(-169.5275365879999, -14.22600676899988, 0.0),
            RSPEC_GEO_FACTORY.point(-169.50645911399988, -14.222263278999932, 0.0),
            RSPEC_GEO_FACTORY.point(-169.4638565749999, -14.223239841999913, 0.0),
            RSPEC_GEO_FACTORY.point(-169.44404049399992, -14.230645440999893, 0.0),
            RSPEC_GEO_FACTORY.point(-169.44013424399992, -14.245293877999913, 0.0)]
         )
       ),

       RSPEC_GEO_FACTORY.polygon(
         RSPEC_GEO_FACTORY.line_string(
           [RSPEC_GEO_FACTORY.point(-169.6356095039999, -14.17701588299991, 0.0),
            RSPEC_GEO_FACTORY.point(-169.6601456369999, -14.189141533999901, 0.0),
            RSPEC_GEO_FACTORY.point(-169.6697485019999, -14.187920830999886, 0.0),
            RSPEC_GEO_FACTORY.point(-169.67621822799987, -14.174899997999901, 0.0),
            RSPEC_GEO_FACTORY.point(-169.67617753799988, -14.174899997999901, 0.0),
            RSPEC_GEO_FACTORY.point(-169.66816158799995, -14.169122002999927, 0.0),
            RSPEC_GEO_FACTORY.point(-169.65819251199994, -14.168877862999892, 0.0),
            RSPEC_GEO_FACTORY.point(-169.6471654939999, -14.172133070999848, 0.0),
            RSPEC_GEO_FACTORY.point(-169.6356095039999, -14.17701588299991, 0.0)]
         )
       ),

       RSPEC_GEO_FACTORY.polygon(
         RSPEC_GEO_FACTORY.line_string(
           [RSPEC_GEO_FACTORY.point(-171.07347571499992, -11.062107028999876, 0.0),
            RSPEC_GEO_FACTORY.point(-171.08153235599985, -11.066094658999859, 0.0),
            RSPEC_GEO_FACTORY.point(-171.08653723899988, -11.060316664999888, 0.0),
            RSPEC_GEO_FACTORY.point(-171.0856420559999, -11.05136484199987, 0.0),
            RSPEC_GEO_FACTORY.point(-171.0728246739999, -11.052504164999903, 0.0),
            RSPEC_GEO_FACTORY.point(-171.07347571499992, -11.062107028999876, 0.0)]
         )
       )
      ]
    ) }

    let(:point0) { RSPEC_GEO_FACTORY.point(0, 0, 0.0) }
    let(:point1) { RSPEC_GEO_FACTORY.point(-29, -16, 0.0) }
    let(:point2) { RSPEC_GEO_FACTORY.point(-25, -18, 0.0) }
    let(:point3) { RSPEC_GEO_FACTORY.point(-28, -21, 0.0) }
    let(:point4) { RSPEC_GEO_FACTORY.point(-19, -18, 0.0) }
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
    let(:point20) { RSPEC_GEO_FACTORY.point(-8, -4, 0.0) }
    let(:point21) { RSPEC_GEO_FACTORY.point(-4, -8, 0.0) }
    let(:point22) { RSPEC_GEO_FACTORY.point(-10, -6, 0.0) }

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

    let(:shape_d) { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-33, 11, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-24, 4, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-26, 13, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-31, 4, 0.0),
                                                   RSPEC_GEO_FACTORY.point(-33, 11, 0.0)]) }

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
                                                  RSPEC_GEO_FACTORY.point(-27, -13, 0.0)]) }

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

    let(:all_shapes) { RSPEC_GEO_FACTORY.collection([rooms20nn,
                                                     point0,
                                                     point1,
                                                     point2,
                                                     point3,
                                                     point4,
                                                     point5,
                                                     point6,
                                                     point7,
                                                     point8,
                                                     point9,
                                                     point10,
                                                     point11,
                                                     point12,
                                                     point13,
                                                     point14,
                                                     point15,
                                                     point16,
                                                     point17,
                                                     point18,
                                                     point19,
                                                     point20,
                                                     point21,
                                                     point22,
                                                     shape_a1,
                                                     shape_b,
                                                     shape_c,
                                                     shape_d,
                                                     shape_e,
                                                     shape_f,
                                                     shape_g,
                                                     shape_h,
                                                     shape_i,
                                                     shape_j,
                                                     shape_k,
                                                     shape_l,
                                                     box_1,
                                                     box_2,
                                                     box_3,
                                                     box_4]) }

    let(:convex_hull) { all_shapes.convex_hull }

    let(:point_m1_p0) { RSPEC_GEO_FACTORY.point(33, 28) } # upper left corner of M1

    let(:all_wkt_names) { [[convex_hull.exterior_ring, 'Outer Limits'],
                           [shape_a1, 'A'],
                           [shape_b, 'B'],
                           [shape_c1, 'C1'],
                           [shape_c2, 'C2'],
                           [shape_c3, 'C3'],
                           [shape_d, 'D'],
                           [shape_e2, 'E2'],
                           [shape_e1, 'E1'],
                           [shape_e3, 'E3'],
                           [shape_e4, 'E4'],
                           [shape_e5, 'E5'],
                           [shape_f1, 'F1'],
                           [shape_f2, 'F2'],
                           [shape_g1, 'G1'],
                           [shape_g2, 'G2'],
                           [shape_g3, 'G3'],
                           [shape_h, 'H'],
                           [shape_i, 'I'],
                           [shape_j, 'J'],
                           [shape_k, 'K'],
                           [shape_l, 'L'],
                           [room2020, 'Room 2020'],
                           [room2022, 'Room 2022'],
                           [room2024, 'Room 2024'],
                           [point0, 'P0'],
                           [point1, 'P1'],
                           [point2, 'P2'],
                           [point3, 'P3'],
                           [point4, 'P4'],
                           [point5, 'P5'],
                           [point6, 'P6'],
                           [point7, 'P7'],
                           [point8, 'P8'],
                           [point9, 'P9'],
                           [point10, 'P10'],
                           [point11, 'P11'],
                           [point12, 'P12'],
                           [point13, 'P13'],
                           [point14, 'P14'],
                           [point15, 'P15'],
                           [point16, 'P16'],
                           [point17, 'P17'],
                           [point18, 'P18'],
                           [point19, 'P19'],
                           [point20, 'P20'],
                           [point21, 'P21'],
                           [point22, 'P22'],
                           [box_1, 'Box_1'],
                           [box_2, 'Box_2'],
                           [box_3, 'Box_3'],
                           [box_4, 'Box_4']
    ].freeze }

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

  end
  let(:geo_user) {
    u = @user.nil? ? User.find(1) : @user
    # $user    = u
    $user_id = u.id
    u
  }
  let(:geo_project) {
    p = @project.nil? ? Project.find(1) : @project
    # $project    = p
    $project_id = p.id
    p
  }
  let(:joe) { geo_user }

# include_context 'stuff for area_a'

  let(:list_box_a) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
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

  let(:list_box_d) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 10, 0.0)])
  }

  let(:list_box_e) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0)])
  }

  let(:list_box_f) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 10, 0.0)])
  }

  let(:list_box_l2) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 10, 0.0)])
  }

  let(:list_box_r2) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0)])
  }

  let(:box_a) { RSPEC_GEO_FACTORY.polygon(list_box_a) }
  let(:box_b) { RSPEC_GEO_FACTORY.polygon(list_box_b) }
  let(:box_c) { RSPEC_GEO_FACTORY.polygon(list_box_c) }
  let(:box_d) { RSPEC_GEO_FACTORY.polygon(list_box_d) }
  let(:box_e) { RSPEC_GEO_FACTORY.polygon(list_box_e) }
  let(:box_f) { RSPEC_GEO_FACTORY.polygon(list_box_f) }
  let(:box_l2) { RSPEC_GEO_FACTORY.polygon(list_box_l2) }
  let(:box_r2) { RSPEC_GEO_FACTORY.polygon(list_box_r2) }

  let(:new_box_a) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_a]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_b) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_b]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_c) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_c]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_d) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_d]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_e) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_e]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_l) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_l]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_f) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_f]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_l2) { FactoryBot.create(:geographic_item_multi_polygon,
                                       multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_l2]),
                                       creator:       geo_user,
                                       updater:       geo_user) }
  let(:new_box_r2) { FactoryBot.create(:geographic_item_multi_polygon,
                                       multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([box_r2]),
                                       creator:       geo_user,
                                       updater:       geo_user) }

# need some areas
  begin
    let(:linestring) {
      RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                     RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                     RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                     RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                     RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
    }
    let(:line_string_a) { FactoryBot.create(:geographic_item_line_string, line_string: linestring.as_binary) }
    let(:area_linestring) {
      area = FactoryBot.create(:level0_geographic_area,
                               name:                 'linestring',
                               geographic_area_type: land_mass_gat,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               earth)
      area.geographic_items << line_string_a
      area.save!
      area
    }
  end

  begin
    let(:polygon_outer) {
      RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(1, -1, 0.0),
                                     RSPEC_GEO_FACTORY.point(9, -1, 0.0),
                                     RSPEC_GEO_FACTORY.point(9, -9, 0.0),
                                     RSPEC_GEO_FACTORY.point(9, -1, 0.0),
                                     RSPEC_GEO_FACTORY.point(1, -1, 0.0)])
    }
    let(:polygon_inner) {
      RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0),
                                     RSPEC_GEO_FACTORY.point(7.5, -2.5, 0.0),
                                     RSPEC_GEO_FACTORY.point(7.5, -7.5, 0.0),
                                     RSPEC_GEO_FACTORY.point(2.5, -7.5, 0.0),
                                     RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0)])
    }
    let(:polygon) { RSPEC_GEO_FACTORY.polygon(polygon_outer, [polygon_inner]) }
    let(:polygon_b) { FactoryBot.create(:geographic_item_polygon, polygon: polygon.as_binary) }

    let(:area_polygon) {
      area = FactoryBot.create(:level0_geographic_area,
                               name:                 'polygon',
                               geographic_area_type: land_mass_gat,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               earth)
      area.geographic_items << polygon_b
      area.save!
      area
    }
  end

  begin
    let(:multipoint) {
      RSPEC_GEO_FACTORY.multi_point([polygon_inner.points[0],
                                     polygon_inner.points[1],
                                     polygon_inner.points[2],
                                     polygon_inner.points[3]])
    }
    let(:multipoint_b) { FactoryBot.create(:geographic_item_multi_point, multi_point: multipoint.as_binary) }

    let(:area_multipoint) {
      area = FactoryBot.create(:level0_geographic_area,
                               name:                 'multipoint',
                               geographic_area_type: land_mass_gat,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               earth)
      area.geographic_items << multipoint_b
      area.save!
      area
    }
  end

  begin
    let(:multilinestring) { RSPEC_GEO_FACTORY.multi_line_string([list_box_a, list_box_b]) }
    let(:multilinestring_b) { FactoryBot.create(:geographic_item_multi_line_string,
                                                multi_line_string: multilinestring.as_binary) }

    let(:area_multilinestring) {
      area = FactoryBot.create(:level0_geographic_area,
                               name:                 'multilinestring',
                               geographic_area_type: land_mass_gat,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               earth)
      area.geographic_items << multilinestring_b
      area.save!
      area
    }
  end

  begin
    let(:multipolygon) { RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(polygon_outer),
                                                          RSPEC_GEO_FACTORY.polygon(polygon_inner)]) }
    let(:multipolygon_b) { FactoryBot.create(:geographic_item_multi_polygon,
                                             multi_polygon: multipolygon.as_binary,
                                             creator:       geo_user,
                                             updater:       geo_user) }

    let(:area_multipolygon) {
      area = FactoryBot.create(:level0_geographic_area,
                               name:                 'multipolygon',
                               geographic_area_type: land_mass_gat,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               earth,
                               creator:              geo_user,
                               updater:              geo_user)
      area.geographic_items << multipolygon_b
      area.save!
      area
    }
  end

  let(:area_a) {
    area = FactoryBot.create(:level1_geographic_area,
                             name:                 'A',
                             geographic_area_type: state_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               area_e,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_a
    area.save!
    area
  }

  let(:area_b) {
    area = FactoryBot.create(:level1_geographic_area,
                             name:                 'B',
                             geographic_area_type: parish_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               area_e,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_b
    area.save!
    area
  }

  let(:area_c) {
    area = FactoryBot.create(:level1_geographic_area,
                             name:                 'C',
                             geographic_area_type: country_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               area_f,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_c
    area.save!
    area
  }

  let(:area_d) {
    area = FactoryBot.create(:level1_geographic_area,
                             name:                 'D',
                             geographic_area_type: country_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               area_f,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_d
    area.save!
    area
  }

  let(:area_e) {
    area = FactoryBot.create(:level0_geographic_area,
                             name:                 'E',
                             geographic_area_type: country_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               earth,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_e
    area.save!
    area
  }

  let(:area_r2) {
    area = FactoryBot.create(:level0_geographic_area,
                             name:                 'R2',
                             geographic_area_type: country_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               earth,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_r2
    area.save!
    area
  }

  let(:area_f) {
    area = FactoryBot.create(:level0_geographic_area,
                             name:                 'F',
                             geographic_area_type: land_mass_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               earth,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_f
    area.save!
    area
  }

  let(:area_l2) {
    area = FactoryBot.create(:level0_geographic_area,
                             name:                 'L2',
                             geographic_area_type: country_gat,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               earth,
                             creator:              geo_user,
                             updater:              geo_user)
    area.geographic_items << new_box_l2
    area.save!
    area
  }

  let(:json_string) { '{"type":"Feature", "properties":{}, "geometry":{"type":"MultiPolygon", ' \
                            '"coordinates":[[[[0, 10, 0], [10, 10, 0], [10, -10, 0], [0, -10, 0], [0, 10, 0]]]]}}' }

  begin # need some collecting events
    let(:ce_p0) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p0') }

    let(:gr00) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr00',
                                   collecting_event:      ce_p0,
                                   error_geographic_item: item_d,
                                   geographic_item:       p0) } #  1
    let(:gr10) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr10',
                                   collecting_event: ce_p0,
                                   geographic_item:  p10) } #  2

    let(:ce_area_d) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_area_d') }
    let(:gr_area_d) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:      'gr_area_d',
                                        collecting_event: ce_area_d,
                                        geographic_item:  item_d) }

    let(:ce_p5) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p5') }
    let(:gr05) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr05',
                                   collecting_event: ce_p5,
                                   geographic_item:  p5) }
    let(:gr15) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr15',
                                   collecting_event: ce_p5,
                                   geographic_item:  p15) }

    let(:ce_area_v) { FactoryBot.create(:collecting_event,
                                        verbatim_label: 'ce_area_v collecting event test') }

    let(:ce_p6) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p6') }
    let(:gr06) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr06',
                                   collecting_event: ce_p6,
                                   geographic_item:  p6) }
    let(:gr16) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr16',
                                   collecting_event: ce_p6,
                                   geographic_item:  p16) }

    let(:ce_p7) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p7') }
    let(:gr07) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr07',
                                   collecting_event: ce_p7,
                                   geographic_item:  p7) }
    let(:gr17) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr17',
                                   collecting_event: ce_p7,
                                   geographic_item:  p17) }

    let(:ce_p8) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p8') }
    let(:gr08) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr08',
                                   collecting_event: ce_p8,
                                   geographic_item:  p8) }
    let(:gr18) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr18',
                                   collecting_event:      ce_p8,
                                   error_geographic_item: b2,
                                   geographic_item:       p18) }

    let(:ce_p9) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p9') }
    let(:gr09) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:      'gr09',
                                   collecting_event: ce_p9,
                                   geographic_item:  p9) }
    let(:gr19) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr19',
                                   collecting_event:      ce_p9,
                                   error_geographic_item: b,
                                   geographic_item:       p19) }

    let(:ce_a) {
      ce = FactoryBot.create(:collecting_event,
                             start_date_year:   1971,
                             start_date_month:  1,
                             start_date_day:    1,
                             verbatim_locality: 'environs of A',
                             verbatim_label:    'Eh?',
                             geographic_area:   area_a,
                             project:           geo_project,
                             updater:           geo_user,
                             creator:           geo_user)
      ce
    }

    let(:ce_b) {
      ce = FactoryBot.create(:collecting_event,
                             start_date_year:   1982,
                             start_date_month:  2,
                             start_date_day:    2,
                             verbatim_locality: 'environs of B',
                             verbatim_label:    'Bah',
                             geographic_area:   area_b,
                             project:           geo_project,
                             updater:           geo_user,
                             creator:           joe)
      ce
    }

    let(:ce_p4s) { FactoryBot.create(:collecting_event,
                                     start_date_year:  1988,
                                     start_date_month: 8,
                                     start_date_day:   8,
                                     verbatim_label:   '@ce_p4s',
                                     geographic_area:  nil) }
    let(:gr_p4s) { FactoryBot.create(:georeference_verbatim_data,
                                     api_request:           'gr_p4s',
                                     collecting_event:      ce_p4s,
                                     error_geographic_item: nil,
                                     geographic_item:       GeographicItem.new(point: new_box_c.st_centroid)) }

# need some collection objects
    let(:co_a) {
      co = FactoryBot.create(:valid_collection_object,
                             created_at:       '2000/01/01',
                             updated_at:       '2000/07/01',
                             collecting_event: ce_a,
                             project:          geo_project,
                             creator:          geo_user,
                             updater:          geo_user)
      # co.reload
      o = FactoryBot.create(:valid_otu_with_taxon_name,
                            name:    'Otu_A',
                            project: geo_project,
                            creator: geo_user,
                            updater: geo_user)
      o.taxon_name.update_column(:name, 'antivitis')
      # o            = Otu.create!(name: 'Otu_A', creator: geo_user, updater: geo_user, project: geo_project)
      # tn           = Protonym.create!(name: 'antivitis', creator: geo_user, updater: geo_user, project: geo_project)
      # o.taxon_name = tn
      co.otus << o

      o = top_dog # this is o1
      o.taxon_name.taxon_name_authors << ted
      co.otus << o

      o            = by_bill
      o.taxon_name = top_dog.taxon_name
      co.otus << o

      o            = FactoryBot.create(:valid_otu, name: 'Abra',
                                       project:          geo_project,
                                       creator:          geo_user,
                                       updater:          geo_user)
      o.taxon_name = tn_abra
      o.taxon_name.taxon_name_authors << ted
      co.otus << o

      o            = FactoryBot.create(:valid_otu, name: 'Abra cadabra',
                                       project:          geo_project,
                                       creator:          geo_user,
                                       updater:          geo_user)
      t_n          = tn_cadabra
      o.taxon_name = t_n
      o.save!
      o.taxon_name.taxon_name_authors << bill
      co.otus << o
      o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam',
                            project:          geo_project,
                            creator:          geo_user,
                            updater:          geo_user)
      co.collecting_event.collectors << bill
      o.taxon_name = tn_alakazam

      o.taxon_name.taxon_name_authors << ted
      co.otus << o
      co
    }

    let(:co_b) {
      co = FactoryBot.create(:valid_collection_object,
                             created_at:       '2001/01/01',
                             updated_at:       '2001/07/01',
                             collecting_event: ce_b,
                             project:          geo_project,
                             creator:          geo_user,
                             updater:          geo_user)
      o  = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P4',
                             project:                          geo_project,
                             creator:                          geo_user,
                             updater:                          geo_user)
      co.collecting_event.collectors << sargon
      co.collecting_event.collectors << daryl
      o.taxon_name.update_column(:name, 'beevitis')
      co.otus << o
      o            = FactoryBot.create(:valid_otu, name: 'Sargon\'s spooler',
                                       project:          geo_project,
                                       creator:          geo_user,
                                       updater:          geo_user)
      o.taxon_name = tn_spooler
      o.taxon_name.taxon_name_authors << sargon
      o.taxon_name.taxon_name_authors << daryl
      co.otus << o
      o = nuther_dog
      o.taxon_name.taxon_name_authors << bill
      o.taxon_name.taxon_name_authors << ted
      o.taxon_name.taxon_name_authors << sargon
      co.otus << o
      co
    }

    let(:co_a_otus) { co_a.otus }

    let(:abra) { co_a_otus.where(name: 'Abra').first }
    let(:otu_a) { co_a_otus.where(name: 'Otu_A').first }
    let(:cadabra) { co_a_otus.where(name: 'Abra cadabra').first }
    let(:alakazam) { co_a_otus.where('name like ?', '%alakazam%').first }

    let(:co_b_otus) { co_b.otus }

    let(:spooler) { co_b_otus.where('name like ?', '%spooler%').first }
    let(:otu_p4) { co_b_otus.where(name: 'P4').first }

    let(:p_a) { GeographicItem::Point.create(point: new_box_a.st_centroid) }
    let(:p_b) { GeographicItem::Point.create(point: new_box_b.st_centroid) }

    let(:gr_a) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'area_a',
                                   collecting_event:      ce_a,
                                   error_geographic_item: new_box_a,
                                   geographic_item:       p_a,
                                   creator:               geo_user,
                                   updater:               geo_user)
    }

    let(:err_b) { GeographicItem::Polygon.create(polygon: RSPEC_GEO_FACTORY.polygon(polygon_inner)) }

    let(:gr_b) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'area_b',
                                   collecting_event:      ce_b,
                                   error_geographic_item: err_b,
                                   geographic_item:       p_b,
                                   creator:               geo_user,
                                   updater:               geo_user)
    }

# need some people
    let(:sargon) { Person.create!(first_name: 'of Akkad', last_name: 'Sargon',
                                  creator:    geo_user,
                                  updater:    geo_user) }
    let(:andy) { Person.create!(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author',
                                creator:    geo_user,
                                updater:    geo_user) }
    let(:daryl) { Person.create!(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon',
                                 creator:    geo_user,
                                 updater:    geo_user) }
    let(:ted) { FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC',
                                  creator:                  geo_user,
                                  updater:                  geo_user) }
    let(:bill) { Person.create!(first_name: 'Bill', last_name: 'Ardson',
                                creator:    geo_user,
                                updater:    geo_user) }

# need some otus
    let(:top_dog) {
      FactoryBot.create(:valid_otu, name: 'Top Dog', taxon_name:
                                          FactoryBot.create(:valid_taxon_name,
                                                            rank_class: Ranks.lookup(:iczn, 'Family'),
                                                            name:       'Topdogidae',
                                                            project:    geo_project,
                                                            creator:    geo_user,
                                                            updater:    geo_user),
                        creator:          geo_user,
                        updater:          geo_user
      )
    }

    let(:nuther_dog) {
      FactoryBot.create(:valid_otu, name: 'Another Dog', taxon_name:
                                          FactoryBot.create(:valid_taxon_name,
                                                            rank_class: Ranks.lookup(:iczn, 'Family'),
                                                            name:       'Nutherdogidae',
                                                            project:    geo_project,
                                                            creator:    geo_user,
                                                            updater:    geo_user),
                        creator:          geo_user,
                        updater:          geo_user
      )
    }

    let(:tn_abra) { Protonym.create!(name:       'Abra',
                                     rank_class: Ranks.lookup(:iczn, 'Genus'),
                                     parent:     top_dog.taxon_name,
                                     creator:    geo_user,
                                     updater:    geo_user)
    }
    let(:tn_spooler) { Protonym.create!(name:       'spooler',
                                        rank_class: Ranks.lookup(:iczn, 'Species'),
                                        parent:     tn_abra,
                                        creator:    geo_user,
                                        updater:    geo_user)
    }
    let(:tn_cadabra) { Protonym.create!(name:                'cadabra',
                                        year_of_publication: 2017,
                                        verbatim_author:     'Bill Ardson',
                                        rank_class:          Ranks.lookup(:iczn, 'Species'),
                                        parent:              tn_abra,
                                        creator:             geo_user,
                                        updater:             geo_user)
    }
    let(:tn_alakazam) { Protonym.create!(name:       'alakazam',
                                         rank_class: Ranks.lookup(:iczn, 'Subspecies'),
                                         parent:     tn_cadabra,
                                         creator:    geo_user,
                                         updater:    geo_user)
    }

    let(:by_bill) { FactoryBot.create(:valid_otu, name: 'Top Dog (by Bill)', taxon_name: top_dog.taxon_name,
                                      creator:          geo_user,
                                      updater:          geo_user) }
  end

  begin # for GeographicItem interaction
    let(:all_items) { FactoryBot.create(:geographic_item_geometry_collection,
                                        geometry_collection: all_shapes.as_binary) } # 54
    let(:outer_limits) { FactoryBot.create(:geographic_item_line_string,
                                           line_string: convex_hull.exterior_ring.as_binary) } # 55


    let(:p0) { FactoryBot.create(:geographic_item_point, point: point0.as_binary) } # 0
    let(:p1) { FactoryBot.create(:geographic_item_point, point: point1.as_binary) }
    let(:p2) { FactoryBot.create(:geographic_item_point, point: point2.as_binary) } # 2
    let(:p3) { FactoryBot.create(:geographic_item_point, point: point3.as_binary) } # 3
    let(:p4) { FactoryBot.create(:geographic_item_point, point: point4.as_binary) } # 3
    let(:p5) { FactoryBot.create(:geographic_item_point, point: point5.as_binary) } # 5
    let(:p6) { FactoryBot.create(:geographic_item_point, point: point6.as_binary) } # 6
    let(:p7) { FactoryBot.create(:geographic_item_point, point: point7.as_binary) } # 7
    let(:p8) { FactoryBot.create(:geographic_item_point, point: point8.as_binary) } # 8
    let(:p9) { FactoryBot.create(:geographic_item_point, point: point9.as_binary) } # 9
    let(:p10) { FactoryBot.create(:geographic_item_point, point: point10.as_binary) } # 10 } #
    let(:p11) { FactoryBot.create(:geographic_item_point, point: point11.as_binary) } # 11 } #
    let(:p12) { FactoryBot.create(:geographic_item_point, point: point12.as_binary) } # 10 } #
    let(:p13) { FactoryBot.create(:geographic_item_point, point: point13.as_binary) } # 10 } #
    let(:p14) { FactoryBot.create(:geographic_item_point, point: point14.as_binary) } # 14 } #
    let(:p15) { FactoryBot.create(:geographic_item_point, point: point15.as_binary) } # 15
    let(:p16) { FactoryBot.create(:geographic_item_point, point: point16.as_binary) } # 16
    let(:p17) { FactoryBot.create(:geographic_item_point, point: point17.as_binary) } # 17
    let(:p18) { FactoryBot.create(:geographic_item_point, point: point18.as_binary) } # 18
    let(:p19) { FactoryBot.create(:geographic_item_point, point: point19.as_binary) } # 19

    let(:a) { FactoryBot.create(:geographic_item_line_string, line_string: shape_a1.as_binary) } # 24 } #
    let(:b) { FactoryBot.create(:geographic_item_polygon, polygon: shape_b.as_binary) } # 27
    let(:c1) { FactoryBot.create(:geographic_item_line_string, line_string: shape_c1) } # 28
    let(:c2) { FactoryBot.create(:geographic_item_line_string, line_string: shape_c2) } # 28
    let(:c3) { FactoryBot.create(:geographic_item_line_string, line_string: shape_c3) } # 29
    let(:c) { FactoryBot.create(:geographic_item_multi_line_string,
                                multi_line_string: shape_c.as_binary) } # 30
    let(:d) { FactoryBot.create(:geographic_item_line_string, line_string: shape_d.as_binary) }
    let(:b1) { FactoryBot.create(:geographic_item_polygon, polygon: shape_b_outer.as_binary) } # 25
    let(:b2) { FactoryBot.create(:geographic_item_polygon, polygon: shape_b_inner.as_binary) } # 26
    let(:e0) { e.geo_object } # a collection of polygons
    let(:e1) { FactoryBot.create(:geographic_item_polygon, polygon: poly_e1.as_binary) } # 35
    let(:e2) { FactoryBot.create(:geographic_item_polygon, polygon: poly_e2.as_binary) } # 33
    let(:e3) { FactoryBot.create(:geographic_item_polygon, polygon: poly_e3.as_binary) } # 34
    let(:e4) { FactoryBot.create(:geographic_item_polygon, polygon: poly_e4.as_binary) } # 35
    let(:e5) { FactoryBot.create(:geographic_item_polygon, polygon: poly_e5.as_binary) } # 35
    let(:e) { FactoryBot.create(:geographic_item_geometry_collection,
                                geometry_collection: shape_e.as_binary) } # 37
    let(:f1) { FactoryBot.create(:geographic_item_line_string, line_string: shape_f1.as_binary) } # 38
    let(:f2) { FactoryBot.create(:geographic_item_line_string, line_string: shape_f2.as_binary) } # 39
    # let(:f1) { f.geo_object.geometry_n(0) } #
    # let(:f2) { f.geo_object.geometry_n(1) } #
    let(:f) { FactoryBot.create(:geographic_item_multi_line_string,
                                multi_line_string: shape_f.as_binary) } # 40
    let(:g1) { FactoryBot.create(:geographic_item_polygon, polygon: shape_g1.as_binary) } # 41
    let(:g2) { FactoryBot.create(:geographic_item_polygon, polygon: shape_g2.as_binary) } # 42
    let(:g3) { FactoryBot.create(:geographic_item_polygon, polygon: shape_g3.as_binary) } # 43
    let(:g) { FactoryBot.create(:geographic_item_multi_polygon,
                                multi_polygon: shape_g.as_binary) } # 44
    let(:h) { FactoryBot.create(:geographic_item_multi_point, multi_point: shape_h.as_binary) } # 45
    let(:j) { FactoryBot.create(:geographic_item_geometry_collection, geometry_collection: shape_j) } # 47
    let(:k) { FactoryBot.create(:geographic_item_polygon, polygon: shape_k.as_binary) }
    let(:l) { FactoryBot.create(:geographic_item_line_string, line_string: shape_l.as_binary) } # 49 } #

    let(:shapeE1) { e0.geometry_n(0) } #
    let(:shapeE2) { e0.geometry_n(1) } #
    let(:shapeE3) { e0.geometry_n(2) } #
    let(:shapeE4) { e0.geometry_n(3) } #
    let(:shapeE5) { e0.geometry_n(4) } #

    let(:r) { a.geo_object.intersection(p16.geo_object) } #

    let(:item_a) { FactoryBot.create(:geographic_item_polygon, polygon: box_1) } # 57
    let(:item_b) { FactoryBot.create(:geographic_item_polygon, polygon: box_2) } # 58
    let(:item_c) { FactoryBot.create(:geographic_item_polygon, polygon: box_3) } # 59
    let(:item_d) { FactoryBot.create(:geographic_item_polygon, polygon: box_4) } # 60

    let(:ce_p1s) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p1s collect_event test') }

    let(:gr01s) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request:           'gr01',
                                    collecting_event:      ce_p1s,
                                    error_geographic_item: k,
                                    geographic_item:       p1) } #  3

    let(:gr11s) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request:           'gr11',
                                    error_geographic_item: e1,
                                    collecting_event:      ce_p1s,
                                    geographic_item:       p11) } #  4

    let(:ce_p2s) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p2s collect_event test') }
    let(:gr02s) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request:           'gr02s',
                                    collecting_event:      ce_p2s,
                                    error_geographic_item: k,
                                    geographic_item:       p2) }
    let(:gr121s) { FactoryBot.create(:georeference_verbatim_data,
                                     api_request:           'gr121s',
                                     collecting_event:      ce_p2s,
                                     error_geographic_item: e1,
                                     geographic_item:       p12) }

    let(:ce_p3s) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p3s collect_event test') }
    let(:gr03s) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request:           'gr03s',
                                    collecting_event:      ce_p3s,
                                    error_geographic_item: k,
                                    geographic_item:       p3) }
    let(:gr13s) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request:           'gr13s',
                                    collecting_event:      ce_p3s,
                                    error_geographic_item: e2,
                                    geographic_item:       p13) }

    # let(:ce_n1) { FactoryBot.create(:collecting_event,
    #                                 start_date_year:  1972,
    #                                 start_date_month: 2,
    #                                 start_date_day:   2,
    #                                 verbatim_label:   '@ce_n1',
    #                                 geographic_area:  area_r2) }

    begin # make some easy-to-use pieces
      let(:gat_list) { GeographicAreaType.all.map(&:name) }
      let(:ga_list) { GeographicArea.all.order(:name).map(&:name) }
    end

    begin # real world objects
      let!(:country_gat) { GeographicAreaType.create!(name: 'Country', creator: geo_user, updater: geo_user) }
      let!(:state_gat) { GeographicAreaType.create!(name: 'State', creator: geo_user, updater: geo_user) }
      let(:province_gat) { GeographicAreaType.create!(name: 'Province', creator: geo_user, updater: geo_user) }
      let!(:county_gat) { GeographicAreaType.create!(name: 'County', creator: geo_user, updater: geo_user) }
      let(:parish_gat) { GeographicAreaType.create!(name: 'Parish', creator: geo_user, updater: geo_user) }
      let(:planet_gat) { GeographicAreaType.create!(name: 'Planet', creator: geo_user, updater: geo_user) }
      let(:land_mass_gat) { GeographicAreaType.create!(name: 'Land Mass', creator: geo_user, updater: geo_user) }

      let(:cc_shape) { GeoBuild::CHAMPAIGN_CO }
      let(:fc_shape) { GeoBuild::FORD_CO }
      let(:il_shape) { GeoBuild::ILLINOIS }

      let(:champaign) {
        cc = FactoryBot.create(:valid_geographic_area_stack)
        cc.geographic_items << GeographicItem::MultiPolygon.create!(multi_polygon: cc_shape)
        cc
      }
      let(:illinois) {
        il = champaign.parent
        il.geographic_items << GeographicItem::MultiPolygon.create!(multi_polygon: il_shape)
        il
      }
      let(:ford) {
        fc = FactoryBot.create(:level2_geographic_area, name: 'Ford', parent: illinois)
        # fc.geographic_items << GeographicItem::MultiPolygon.create!(multi_polygon: fc_shape)
        fc
      }
      let(:usa) { illinois.parent }
      let(:earth) {
        usa.parent
      }

      let(:r2020) { FactoryBot.create(:geographic_item_point, point: room2020.as_binary) } # 50
      let(:r2022) { FactoryBot.create(:geographic_item_point, point: room2022.as_binary) } # 51
      let(:r2024) { FactoryBot.create(:geographic_item_point, point: room2024.as_binary) } # 52
      let(:rooms) { FactoryBot.create(:geographic_item_multi_point, multi_point: rooms20nn.as_binary) } # 53

    end

    begin # objects in Big Boxia

=begin

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
                                 name:                 'Big Boxia',
                                 geographic_area_type: country_gat,
                                 iso_3166_a3:          nil,
                                 iso_3166_a2:          nil,
                                 parent:               area_land_mass)
        area.geographic_items << item_bb
        area.save!
        area
      }

      begin # objects in Q
        let(:area_u) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'QU',
                                   tdwgID:               nil,
                                   geographic_area_type: state_gat,
                                   parent:               area_q)
          area.geographic_items << item_u
          area.save!
          area
        }
        let(:area_q) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'Q',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'QQQ',
                                   iso_3166_a2:          'QQ',
                                   parent:               area_land_mass)
          area.geographic_items << item_q
          area.save!
          area
        }

        let(:area_old_boxia) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'Old Boxia',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'OB1',
                                   iso_3166_a2:          nil,
                                   parent:               area_land_mass)
          area.geographic_items << item_ob
          area.save!
          area
        }
        let(:area_qtm2) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QTM2',
                                   geographic_area_type: county_gat,
                                   parent:               area_t_1)
          area.geographic_items << item_m1
          area.save!
          area
        }
        let(:area_quo1) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QUO1',
                                   geographic_area_type: parish_gat,
                                   parent:               area_u)
          # @area_quo1.geographic_items << @item_o1
          area.save!
          area
        }
        let(:area_quo2) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QUO2',
                                   geographic_area_type: parish_gat,
                                   parent:               area_u)
          area.geographic_items << item_o2
          area.save!
          area
        }
        let(:area_qup1) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QUP1',
                                   tdwgID:               nil,
                                   geographic_area_type: parish_gat,
                                   parent:               area_u)
          area.geographic_items << item_p1
          area.save!
          area
        }
        let(:area_qtn2_1) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QTN2',
                                   geographic_area_type: county_gat,
                                   parent:               area_t_1)
          area.geographic_items << item_n2
          area.save!
          area
        }
        let(:area_qtn2_2) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QTN2',
                                   geographic_area_type: county_gat,
                                   parent:               area_t_2)
          area.geographic_items << item_n2
          area.save!
        }
      end

      begin # objects in S
        let(:area_s) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'S',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'SSS',
                                   iso_3166_a2:          'SS',
                                   parent:               area_land_mass)
          area.geographic_items << item_s
          area.save!
          area
        }

      end

      begin # objects in R
        let(:area_r) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'R',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'RRR',
                                   iso_3166_a2:          'RR',
                                   parent:               area_land_mass)
          area.geographic_items << item_r
          area.save!
          area
        }
        let(:area_rm3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RM3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_m3
          area.save!
          area
        }
        let(:area_rm4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RM4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_m4
          area.save!
          area
        }
        let(:area_rn3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RN3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n3
          area.save!

          area
        }
        let(:area_rn4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RN4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n4
          area.save!
          area
        }

        let(:area_rn3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RN3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n3
          area.save!
          area
        }
        let(:area_rn4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RN4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n4
          area.save!
          area
        }
        let(:area_m3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'M3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_m3
          area.save!
          area
        }
        let(:area_n3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'N3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n3
          area.save!
          area
        }
        let(:area_m4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'M4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_m4
          area.save!
          area
        }
        let(:area_n4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'N4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n4
          area.save!
          area
        }

        let(:gr_n3_ob) { FactoryBot.create(:georeference_verbatim_data,
                                           api_request:           'gr_n3_ob',
                                           collecting_event:      ce_old_boxia_2,
                                           error_geographic_item: item_ob,
                                           geographic_item:       GeographicItem.new(point: item_n3.st_centroid)) }
        let(:ce_old_boxia_2) { FactoryBot.create(:collecting_event,
                                                 start_date_year:  1993,
                                                 start_date_month: 3,
                                                 start_date_day:   3,
                                                 verbatim_label:   '@ce_old_boxia_2',
                                                 geographic_area:  area_old_boxia) }
        let(:item_m4) { FactoryBot.create(:geographic_item, multi_polygon: shape_m4) }
        let(:item_r) { FactoryBot.create(:geographic_item, multi_polygon: shape_r) }
        let(:shape_r) { make_box(shape_m3[0]
                                   .exterior_ring.points[0], 0, 0, 2, 2) }
        let(:shape_m4) { make_box(point_m1_p0, 0, 3, 1, 1) }
      end # building stuff in R
      begin # western big boxia
        let(:west_boxia) { [area_west_boxia_1, area_west_boxia_3].each }
        let(:area_west_boxia_1) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'West Boxia',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'WB1',
                                   iso_3166_a2:          nil,
                                   parent:               area_land_mass)
          area.geographic_items << item_wb
          area.save!
          area
        }
        let(:area_west_boxia_3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'West Boxia',
                                   geographic_area_type: state_gat,
                                   iso_3166_a3:          'WB3',
                                   iso_3166_a2:          nil,
                                   parent:               area_old_boxia)
          area.geographic_items << item_wb
          area.save!
          area
        }
      end

      let(:co_x) { FactoryBot.create(:valid_collection_object) }
      begin
        let(:ce_n3) { FactoryBot.create(:collecting_event,
                                        start_date_year:   1982,
                                        start_date_month:  2,
                                        start_date_day:    2,
                                        end_date_year:     1984,
                                        end_date_month:    9,
                                        end_date_day:      15,
                                        verbatim_locality: 'Greater Boxia Lake',
                                        verbatim_label:    '@ce_n3',
                                        geographic_area:   area_n3) }
        let(:gr_n3) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_n3',
                                        collecting_event:      ce_n3,
                                        error_geographic_item: item_n3,
                                        geographic_item:       GeographicItem.new(point: item_n3.st_centroid)) }
        let(:co_n3) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_n3}) }
        let(:area_n3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'N3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n3
          area.save!
          area
        }
        let(:shape_m3) { make_box(point_m1_p0, 0, 2, 1, 1) }
        let(:item_n3) { FactoryBot.create(:geographic_item, multi_polygon: shape_n3) }
        let(:shape_n3) { make_box(point_m1_p0, 1, 2, 1, 1) }
      end
      begin # build the collecting event for an object in P1(B), part of Big Boxia
        let(:ce_p1b) { FactoryBot.create(:collecting_event,
                                         start_date_year:  1974,
                                         start_date_month: 4,
                                         start_date_day:   4,
                                         verbatim_label:   '@ce_p1b',
                                         geographic_area:  area_p1b) }
        let(:co_p1b) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_p1b}) }
        let(:gr_p1b) { FactoryBot.create(:georeference_verbatim_data,
                                         api_request:           'gr_p1b',
                                         collecting_event:      ce_p1b,
                                         error_geographic_item: item_p1b,
                                         geographic_item:       GeographicItem.new(point: item_p1b.st_centroid)) }
        let(:area_land_mass) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'Great Northern Land Mass',
                                   geographic_area_type: land_mass_gat,
                                   iso_3166_a3:          nil,
                                   iso_3166_a2:          nil,
                                   parent:               earth)
          area.geographic_items << item_w
          area.save!
          area
        }
        let(:area_p1b) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'P1B',
                                          geographic_area_type: parish_gat,
                                          parent:               area_u)
          area.level0 = area_u
          area.geographic_items << item_p1b
          area.save!
          area
        }

        let(:shape_p1b) { make_box(point_m1_p0, 3, 0, 1, 1) }
        let(:shape_q) { make_box(shape_m1[0].exterior_ring.points[0], 0, 0, 4, 2) }
        let(:shape_m1) { make_box(point_m1_p0, 0, 0, 1, 1) }
        let(:shape_ob) { make_box(point_m1_p0, 0, 0, 2, 4) }
        let(:shape_eb_1) { make_box(point_m1_p0, 3, 0, 1, 4) }
        let(:shape_eb_2) { make_box(point_m1_p0, 2, 0, 2, 2) }
        let(:shape_wb) { make_box(point_m1_p0, 0, 0, 1, 4) }
        let(:shape_w) { make_box(point_m1_p0, 0, 0, 4, 4) }
        let(:shape_u) { make_box(shape_o1[0].exterior_ring.points[0], 0, 0, 2, 2) }
        let(:shape_o1) { make_box(point_m1_p0, 2, 0, 1, 1) }


        # secondary country shapes
        # same shape as Q, different object
        let(:item_bb) { FactoryBot.create(:geographic_item, multi_polygon: shape_q) }

        # superseded country shapes
        let(:item_q) { FactoryBot.create(:geographic_item, multi_polygon: shape_q) }
        let(:item_u) { FactoryBot.create(:geographic_item, multi_polygon: shape_u) }
        let(:item_ob) { FactoryBot.create(:geographic_item, multi_polygon: shape_ob) }
        let(:item_eb_1) { FactoryBot.create(:geographic_item, multi_polygon: shape_eb_1) }
        let(:item_eb_2) { FactoryBot.create(:geographic_item, multi_polygon: shape_eb_2) }
        let(:item_wb) { FactoryBot.create(:geographic_item, multi_polygon: shape_wb) }
        let(:item_p1b) { FactoryBot.create(:geographic_item, multi_polygon: shape_p1b) }

        # the entire land mass
        let(:item_w) { FactoryBot.create(:geographic_item, multi_polygon: shape_w) }

        # some other areas
        let(:east_boxia) { [area_east_boxia_1, area_east_boxia_2, area_east_boxia_2] }
        let(:area_east_boxia_1) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'East Boxia',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'EB1',
                                   iso_3166_a2:          nil,
                                   parent:               area_land_mass)
          area.geographic_items << item_eb_1
          area.save!
          area
        }
        let(:area_east_boxia_2) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'East Boxia',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'EB2',
                                   iso_3166_a2:          nil,
                                   parent:               area_land_mass)
          area.geographic_items << item_eb_2
          area.save!
          area
        }
        let(:area_east_boxia_3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'East Boxia',
                                   geographic_area_type: state_gat,
                                   iso_3166_a3:          'EB3',
                                   iso_3166_a2:          nil,
                                   parent:               area_old_boxia)
          area.geographic_items << item_eb_2
          area.save!
          area
        }
      end


      begin # build the collecting event for an object in O1
        let(:ce_o1) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1973,
                                        start_date_month: 3,
                                        start_date_day:   3,
                                        verbatim_label:   '@ce_o1',
                                        geographic_area:  area_o1) }
        let(:co_o1) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_o1}) }
        let(:gr_o1) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_o1',
                                        collecting_event:      ce_o1,
                                        error_geographic_item: item_o1,
                                        geographic_item:       GeographicItem.new(point: item_o1.st_centroid)) }

        let(:area_o1) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'O1',
                                          geographic_area_type: parish_gat,
                                          parent:               area_u)
          area.level0 = area_u
          area.geographic_items << item_o1
          area.save!
          area
        }
        let(:item_o1) { FactoryBot.create(:geographic_item, multi_polygon: shape_o1) }
      end

      begin # build the collecting event for an object in O3
        # @ce_o3 has no georeference
        let(:ce_o3) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1983,
                                        start_date_month: 3,
                                        start_date_day:   3,
                                        verbatim_label:   '@ce_o3',
                                        geographic_area:  area_o3) }
        let(:co_o3) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_o3}) }
        let(:area_o3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'O3',
                                   tdwgID:               nil,
                                   geographic_area_type: state_gat,
                                   parent:               area_s)
          area.geographic_items << item_o3
          area.save!
          area
        }
        let(:area_s) {
          area = FactoryBot.create(:level0_geographic_area,
                                   name:                 'S',
                                   geographic_area_type: country_gat,
                                   iso_3166_a3:          'SSS',
                                   iso_3166_a2:          'SS',
                                   parent:               area_land_mass)
          area.geographic_items << item_s
          area.save!
          area
        }
        let(:item_s) { FactoryBot.create(:geographic_item, multi_polygon: shape_s) }
        let(:shape_s) { make_box(shape_o3[0]
                                   .exterior_ring.points[0], 0, 0, 2, 2) }
        let(:shape_o3) { make_box(point_m1_p0, 2, 2, 1, 1) }
        let(:item_o3) { FactoryBot.create(:geographic_item, multi_polygon: shape_o3) }
        let(:area_so3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'SO3',
                                   tdwgID:               nil,
                                   geographic_area_type: state_gat,
                                   parent:               area_s)
          area.geographic_items << item_o3
          area.save!
          area
        }
      end

      begin # build the collecting event for objects in N2
        # @ce_n2 has two GRs
        let(:ce_n2) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1976,
                                        start_date_month: 6,
                                        start_date_day:   6,
                                        verbatim_label:   '@ce_n2',
                                        geographic_area:  area_n2) }
        let(:co_n2_a) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_n2}) }
        let(:co_n2_b) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_n2}) }
        let(:gr_n2_a) { FactoryBot.create(:georeference_verbatim_data,
                                          api_request:           'gr_n2_a',
                                          collecting_event:      ce_n2,
                                          error_geographic_item: item_n2,
                                          geographic_item:       GeographicItem.new(point: item_n2.st_centroid)) }
        let(:gr_n2_b) { FactoryBot.create(:georeference_verbatim_data,
                                          api_request:           'gr_n2_b',
                                          collecting_event:      ce_n2,
                                          error_geographic_item: item_n2,
                                          geographic_item:       GeographicItem.new(point: item_n2.st_centroid)) }
        let(:area_n2) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'N2',
                                          geographic_area_type: county_gat,
                                          parent:               area_t_1)
          area.level0 = area_t_1
          area.geographic_items << item_n2
          area.save!
          area
        }
        let(:area_t_1) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'QT',
                                   tdwgID:               '10TTT',
                                   geographic_area_type: state_gat,
                                   parent:               area_q)
          area.geographic_items << item_t_1
          area.save!
          area
        }
        let(:item_t_1) { FactoryBot.create(:geographic_item, multi_polygon: shape_t_1) }
        let(:shape_t_1) { make_box(shape_m1[0]
                                     .exterior_ring.points[0], 0, 0, 2, 2) }
        let(:item_n2) { FactoryBot.create(:geographic_item, multi_polygon: shape_n2) }
        let(:shape_n2) { make_box(point_m1_p0, 1, 1, 1, 1) }
        let(:area_t_2) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'QT',
                                   tdwgID:               '20TTT',
                                   geographic_area_type: state_gat,
                                   parent:               area_q)
          area.geographic_items << item_t_2
          area.save!
          area
        }
        let(:item_t_2) { FactoryBot.create(:geographic_item, multi_polygon: shape_t_2) }
        let(:shape_t_2) { make_box(shape_m1[0]
                                     .exterior_ring.points[0], 0, 0, 2, 2) }

      end

      begin # build the collecting event for objects in N4
        let(:ce_n4) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1986,
                                        start_date_month: 6,
                                        start_date_day:   6,
                                        verbatim_label:   '@ce_n4',
                                        geographic_area:  area_old_boxia) }
        let(:gr_n4) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_n4',
                                        collecting_event:      ce_n4,
                                        error_geographic_item: item_n4,
                                        geographic_item:       GeographicItem.new(point: item_n4.st_centroid)) }
        let(:co_n4) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_n4}) }

        let(:area_n4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'N4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n4
          area.save!
          area
        }

        let(:area_rn4) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'RN4',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_n4
          area.save!
          area
        }
        let(:item_n4) { FactoryBot.create(:geographic_item, multi_polygon: shape_n4) }
        let(:shape_n4) { make_box(point_m1_p0, 1, 3, 1, 1) }
      end

      begin # build the collecting events associated with M1 and M1A
        let(:ce_m1) {
          ce             = FactoryBot.create(:collecting_event,
                                             start_date_year:   1971,
                                             start_date_month:  1,
                                             start_date_day:    1,
                                             verbatim_locality: 'Lesser Boxia Lake',
                                             verbatim_label:    '@ce_m1',
                                             geographic_area:   area_m1)
          td_m1          = FactoryBot.create(:valid_taxon_determination)
          co_m1          = td_m1.biological_collection_object
          td_m1.otu.name = 'Find me, I\'m in M1!'
          td_m1.otu.save!
          co_m1.collecting_event = ce
          co_m1.save!
          ce.save!
          ce
        }
        let(:co_m1) { ce_m1.collection_objects.first }
        let(:gr_m1) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_m1',
                                        collecting_event:      ce_m1,
                                        error_geographic_item: item_m1,
                                        geographic_item:       GeographicItem.new(point: item_m1.st_centroid)) }

        let(:ce_m1a) { FactoryBot.create(:collecting_event,
                                         start_date_year:   1971,
                                         start_date_month:  6,
                                         start_date_day:    6,
                                         verbatim_locality: 'Lesser Boxia Lake',
                                         verbatim_label:    '@ce_m1a',
                                         geographic_area:   area_m1) }
        let(:co_m1a) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_m1a}) }
        let(:gr_m1a) { FactoryBot.create(:georeference_verbatim_data,
                                         api_request:           'gr_m1a',
                                         collecting_event:      ce_m1a,
                                         error_geographic_item: item_m1,
                                         geographic_item:       GeographicItem.new(point: item_m1.st_centroid)) }

        let(:area_m1) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'M1',
                                          geographic_area_type: county_gat,
                                          parent:               area_t_1)
          area.level0 = area_t_1
          area.geographic_items << item_m1
          area.save!
          area
        }
        let(:item_m1) { FactoryBot.create(:geographic_item, multi_polygon: shape_m1) }
        let(:area_qtm1) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QTM1',
                                   geographic_area_type: county_gat,
                                   parent:               area_t_1)
          area.geographic_items << item_m1
          area.save!
          area
        }
      end

      begin # build the collecting event for objects in V
        # this one is just a collecting event, no georeferences or geographic_area, so, even though it
        # has an otu, that otu can't be found
        let(:ce_v) { FactoryBot.create(:collecting_event,
                                       start_date_year:  1991,
                                       start_date_month: 1,
                                       start_date_day:   1,
                                       verbatim_label:   '@ce_v',
                                       geographic_area:  nil) }
        let(:co_v) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_v}) }

      end

      begin # build the collection object for objects in P2B
        let(:ce_p2b) { FactoryBot.create(:collecting_event,
                                         start_date_year:  1978,
                                         start_date_month: 8,
                                         start_date_day:   8,
                                         verbatim_label:   '@ce_p2b',
                                         geographic_area:  area_p2b) }
        # @gr_p2   = FactoryBot.create(:georeference_verbatim_data,
        #                               api_request: 'gr_p2',
        #                               collecting_event: @ce_p2,
        #                               error_geographic_item: @item_p2,
        #                               geographic_item: GeographicItem.new(point: @item_p2.st_centroid))
        let(:co_p2b) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_p2b}) }

        let(:area_p2b) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'P2',
                                          geographic_area_type: parish_gat,
                                          parent:               area_u)
          area.level0 = area_u
          area.geographic_items << item_p2b
          area.save!
          area
        }
        let(:item_p2b) { FactoryBot.create(:geographic_item, multi_polygon: shape_p2b) }
        let(:shape_p2b) { make_box(point_m1_p0, 3, 1, 1, 1) }

        let(:area_qup2) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QUP2',
                                   tdwgID:               nil,
                                   geographic_area_type: parish_gat,
                                   parent:               area_u)
          area.geographic_items << item_p2b
          area.save!
          area
        }
      end

      begin # build the collecting event for objects in P3B
        # @ce_p3b has no georeference
        let(:ce_p3b) { FactoryBot.create(:collecting_event,
                                         start_date_year:  1984,
                                         start_date_month: 4,
                                         start_date_day:   4,
                                         verbatim_label:   '@ce_p3b',
                                         geographic_area:  area_s) }
        let(:co_p3b) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_p3b}) }

      end

      begin # buile collecting event for objects in M2
        let(:ce_m2) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1975,
                                        start_date_month: 5,
                                        start_date_day:   5,
                                        verbatim_label:   '@ce_m2 in Big Boxia',
                                        geographic_area:  area_big_boxia) }
        let(:co_m2) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_m2}) }
        let(:gr_m2) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_m2 in Big Boxia',
                                        collecting_event:      ce_m2,
                                        error_geographic_item: item_m2,
                                        geographic_item:       GeographicItem.new(point: item_m2.st_centroid)) }

        let(:area_m2) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'M2',
                                          geographic_area_type: county_gat,
                                          parent:               area_t_1)
          area.level0 = area_t_1
          area.geographic_items << item_m2
          area.save!
          area
        }
        let(:item_m2) { FactoryBot.create(:geographic_item, multi_polygon: shape_m2) }
        let(:shape_m2) { make_box(point_m1_p0, 0, 1, 1, 1) }
      end

      begin # build the collecting event for objects in N1
        let(:ce_n1) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1972,
                                        start_date_month: 2,
                                        start_date_day:   2,
                                        verbatim_label:   '@ce_n1',
                                        geographic_area:  area_n1) }
        let(:co_n1) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_n1}) }
        # @gr_n1 = FactoryBot.create(:georeference_verbatim_data,
        #                             api_request: 'gr_n1',
        #                             collecting_event: @ce_n1,
        #                             error_geographic_item: @item_n1,
        #                             geographic_item: GeographicItem.new(point: @item_n1.st_centroid))

        let(:area_n1) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'N1',
                                          geographic_area_type: county_gat,
                                          parent:               area_t_1)
          area.level0 = area_t_1
          area.geographic_items << item_n1
          area.save!
          area
        }
        let(:item_n1) { FactoryBot.create(:geographic_item, multi_polygon: shape_n1) }
        let(:shape_n1) { make_box(point_m1_p0, 1, 0, 1, 1) }

        let(:area_qtn1) {
          area = FactoryBot.create(:level2_geographic_area,
                                   name:                 'QTN1',
                                   geographic_area_type: county_gat,
                                   parent:               area_t_1)
          area.geographic_items << item_n1
          area.save!
          area
        }
      end

      begin # build the collecting event for objects in O2
        let(:ce_o2) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1977,
                                        start_date_month: 7,
                                        start_date_day:   7,
                                        verbatim_label:   '@ce_o2',
                                        geographic_area:  area_o2) }
        let(:gr_o2) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_o2',
                                        collecting_event:      ce_o2,
                                        error_geographic_item: item_o2,
                                        geographic_item:       GeographicItem.new(point: item_o2.st_centroid)) }
        let(:co_o2) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_o2}) }

        let(:area_o2) {
          area        = FactoryBot.create(:level2_geographic_area,
                                          name:                 'O2',
                                          geographic_area_type: parish_gat,
                                          parent:               area_u)
          area.level0 = area_u
          area.geographic_items << item_o2
          area.save!
          area
        }
        let(:item_o2) { FactoryBot.create(:geographic_item, multi_polygon: shape_o2) }
        let(:shape_o2) { make_box(point_m1_p0, 2, 1, 1, 1) }
      end

      begin # build for collecting event for objects in M3
        let(:ce_m3) { FactoryBot.create(:collecting_event,
                                        start_date_year:  1981,
                                        start_date_month: 1,
                                        start_date_day:   1,
                                        verbatim_label:   '@ce_m3',
                                        geographic_area:  area_m3) }
        let(:gr_m3) { FactoryBot.create(:georeference_verbatim_data,
                                        api_request:           'gr_m3',
                                        collecting_event:      ce_m3,
                                        error_geographic_item: item_m3,
                                        geographic_item:       GeographicItem.new(point: item_m3.st_centroid)) }
        let(:co_m3) { FactoryBot.create(:valid_collection_object, {collecting_event: ce_m3}) }

        let(:area_m3) {
          area = FactoryBot.create(:level1_geographic_area,
                                   name:                 'M3',
                                   tdwgID:               nil,
                                   geographic_area_type: province_gat,
                                   parent:               area_r)
          area.geographic_items << item_m3
          area.save!
          area
        }
        let(:item_m3) { FactoryBot.create(:geographic_item, multi_polygon: shape_m3) }
      end

      begin # shapes

      end

      begin # items

      end

      # b = FactoryBot.build(:geographic_item_polygon, polygon: GeoBuild::SHAPE_B.as_binary) # 27
    end
  end
# before {
#   # @user exists as a result of `sign_in_and _select_project` (i.e., a feature test), othewise nil
#   if @user
#     simple_world(@user.id, @project.id)
#   else
#     simple_world
#   end
# }

# need user and project
#   let(:user) { User.find(1) }
#   let(:project) { Project.find(1) }

# need some people
#   let(:sargon) { Person.where(first_name: 'of Akkad', last_name: 'Sargon').first }
#   let(:andy) { Person.where(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author').first }
#   let(:daryl) { Person.where(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon').first }
#   let(:ted) { Person.where(last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC').first }
#   let(:bill) { Person.where(first_name: 'Bill', last_name: 'Ardson').first }

# need some otus
#   let(:top_dog) { Otu.where(name: 'Top Dog').first }
#   let(:nuther_dog) { Otu.where(name: 'Another Dog').first }
#   let(:spooler) { Otu.where('name like ?', '%spooler%').first }
#   let(:otu_p4) { Otu.where(name: 'P4').first }
#   let(:by_bill) { Otu.where('name like ?', '%by Bill%').first }
#   let(:otu_a) { Otu.where(name: 'Otu_A').first }
#   let(:abra) { Otu.where(name: 'Abra').first }
#   let(:cadabra) { Otu.where('name like ?', '%cadabra%').first }
#   let(:alakazam) { Otu.where('name like ?', '%alakazam%').first }

# need some areas
#   let(:area_linestring) { GeographicArea.where(name: 'linestring').first }
#   let(:area_polygon) { GeographicArea.where(name: 'polygon').first }
#   let(:area_multipoint) { GeographicArea.where(name: 'multipoint').first }
#   let(:area_multilinestring) { GeographicArea.where(name: 'multilinestring').first }
#   let(:area_multipolygon) { GeographicArea.where(name: 'multipolygon').first }
# let(:area_a) { GeographicArea.where(name: 'A').first }
# let(:area_b) { GeographicArea.where(name: 'B').first }
# let(:area_e) { GeographicArea.where(name: 'E').first }
# let(:json_string) { '{"type":"Feature", "properties":{}, "geometry":{"type":"MultiPolygon", ' \
#                             '"coordinates":[[[[0, 10, 0], [10, 10, 0], [10, -10, 0], [0, -10, 0], [0, 10, 0]]]]}}' }

# need some collection objects
#   let(:ce_a) { CollectingEvent.where(verbatim_label: 'Eh?').first }
#   let(:co_a) {
#     object = ce_a
#     object.collection_objects.first
#   }
#
#   let(:ce_b) { CollectingEvent.where(verbatim_label: 'Bah').first }
#   let(:co_b) {
#     object = ce_b
#     object.collection_objects.first
#   }

# rubocop:disable Metrics/MethodLength
  def simple_world(user_id = 1, project_id = 1)
    # temp_user    = $user_id
    # temp_project = $project_id
    #
    # $user_id    = user_id
    # $project_id = project_id
    #
    # user    = User.find($user_id)
    # joe     = user
    # project = Project.find($project_id)

    # planet_gat = GeographicAreaType.create!(name: 'Planet')
    # gat_parish    = GeographicAreaType.create!(name: 'Parish')
    # gat_land_mass = GeographicAreaType.create!(name: 'Land Mass')
    # list_shape_a  = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
    #                                                RSPEC_GEO_FACTORY.point(0, 10, 0.0),
    #                                                RSPEC_GEO_FACTORY.point(10, 10, 0.0),
    #                                                RSPEC_GEO_FACTORY.point(10, 0, 0.0),
    #                                                RSPEC_GEO_FACTORY.point(0, 0, 0.0)])

    # list_shape_b = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(10, 0, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(10, -10, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(0, -10, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
    #
    # list_shape_e = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(10, 10, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(10, -10, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(0, -10, 0.0),
    #                                               RSPEC_GEO_FACTORY.point(0, 10, 0.0)])
    #
    # shape_a = RSPEC_GEO_FACTORY.polygon(list_shape_a)
    # shape_b = RSPEC_GEO_FACTORY.polygon(list_shape_b)
    # shape_e = RSPEC_GEO_FACTORY.polygon(list_shape_e)

    # new_box_a = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_a]))
    # new_box_b = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_b]))
    # new_box_e = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_e]))

    # earth = FactoryBot.create(:earth_geographic_area,
    #                           geographic_area_type: planet_gat)

    # begin
    #   linestring    = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(0, 10, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(10, 10, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(10, 0, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
    #   line_string_a = FactoryBot.build(:geographic_item_line_string, line_string: linestring.as_binary)
    #
    #   area_linestring = FactoryBot.create(:level0_geographic_area,
    #                                       name:                 'linestring',
    #                                       geographic_area_type: gat_land_mass,
    #                                       iso_3166_a3:          nil,
    #                                       iso_3166_a2:          nil,
    #                                       parent:               earth)
    #   area_linestring.geographic_items << line_string_a
    #   area_linestring.save!
    # end
    #
    # begin
    #   polygon_outer = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(1, -1, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(9, -1, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(9, -9, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(9, -1, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(1, -1, 0.0)])
    #
    #   polygon_inner = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(7.5, -2.5, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(7.5, -7.5, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(2.5, -7.5, 0.0),
    #                                                  RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0)])
    #   polygon       = RSPEC_GEO_FACTORY.polygon(polygon_outer, [polygon_inner])
    #   polygon_b     = FactoryBot.build(:geographic_item_polygon, polygon: polygon.as_binary)
    #
    #   area_polygon = FactoryBot.create(:level0_geographic_area,
    #                                    name:                 'polygon',
    #                                    geographic_area_type: gat_land_mass,
    #                                    iso_3166_a3:          nil,
    #                                    iso_3166_a2:          nil,
    #                                    parent:               earth)
    #   area_polygon.geographic_items << polygon_b
    #   area_polygon.save!
    # end
    #
    # begin
    #   multipoint   = RSPEC_GEO_FACTORY.multi_point([polygon_inner.points[0],
    #                                                 polygon_inner.points[1],
    #                                                 polygon_inner.points[2],
    #                                                 polygon_inner.points[3]])
    #   multipoint_b = FactoryBot.build(:geographic_item_multi_point, multi_point: multipoint.as_binary)
    #
    #   area_multipoint = FactoryBot.create(:level0_geographic_area,
    #                                       name:                 'multipoint',
    #                                       geographic_area_type: gat_land_mass,
    #                                       iso_3166_a3:          nil,
    #                                       iso_3166_a2:          nil,
    #                                       parent:               earth)
    #   area_multipoint.geographic_items << multipoint_b
    #   area_multipoint.save!
    # end
    #
    # begin
    #   multilinestring   = RSPEC_GEO_FACTORY.multi_line_string([list_shape_a, list_shape_b])
    #   multilinestring_b = FactoryBot.build(:geographic_item_multi_line_string,
    #                                        multi_line_string: multilinestring.as_binary)
    #
    #   area_multilinestring = FactoryBot.create(:level0_geographic_area,
    #                                            name:                 'multilinestring',
    #                                            geographic_area_type: gat_land_mass,
    #                                            iso_3166_a3:          nil,
    #                                            iso_3166_a2:          nil,
    #                                            parent:               earth)
    #   area_multilinestring.geographic_items << multilinestring_b
    #   area_multilinestring.save!
    # end
    #
    # begin
    #   multipolygon   = RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(polygon_outer),
    #                                                     RSPEC_GEO_FACTORY.polygon(polygon_inner)])
    #   multipolygon_b = FactoryBot.create(:geographic_item_multi_polygon, multi_polygon: multipolygon.as_binary)
    #
    #   area_multipolygon = FactoryBot.create(:level0_geographic_area,
    #                                         name:                 'multipolygon',
    #                                         geographic_area_type: gat_land_mass,
    #                                         iso_3166_a3:          nil,
    #                                         iso_3166_a2:          nil,
    #                                         parent:               earth)
    #   area_multipolygon.geographic_items << multipolygon_b
    #   area_multipolygon.save!
    # end
    #
    # area_e = FactoryBot.create(:level0_geographic_area,
    #                            name:                 'E',
    #                            geographic_area_type: gat_land_mass,
    #                            iso_3166_a3:          nil,
    #                            iso_3166_a2:          nil,
    #                            parent:               earth)
    # area_e.geographic_items << new_box_e
    # area_e.save!
    #
    # area_a = FactoryBot.create(:level1_geographic_area,
    #                            name:                 'A',
    #                            geographic_area_type: gat_parish,
    #                            iso_3166_a3:          nil,
    #                            iso_3166_a2:          nil,
    #                            parent:               area_e)
    # area_a.geographic_items << new_box_a
    # area_a.save!

    # area_b = FactoryBot.create(:level1_geographic_area,
    #                            name:                 'B',
    #                            geographic_area_type: gat_parish,
    #                            iso_3166_a3:          nil,
    #                            iso_3166_a2:          nil,
    #                            parent:               area_e)
    # area_b.geographic_items << new_box_b
    # area_b.save!

    # ce_a = FactoryBot.create(:collecting_event,
    #                          start_date_year:   1971,
    #                          start_date_month:  1,
    #                          start_date_day:    1,
    #                          verbatim_locality: 'environs of A',
    #                          verbatim_label:    'Eh?',
    #                          geographic_area:   area_a)

    # co_a = FactoryBot.create(:valid_collection_object,
    #                          created_at:       '2000/01/01',
    #                          updated_at:       '2000/07/01',
    #                          collecting_event: ce_a)

    # gr_a = FactoryBot.create(:georeference_verbatim_data,
    #                          api_request:           'area_a',
    #                          collecting_event:      ce_a,
    #                          error_geographic_item: new_box_a,
    #                          geographic_item:       GeographicItem.new(point: new_box_a.st_centroid))

    # ce_b = FactoryBot.create(:collecting_event,
    #                          start_date_year:   1982,
    #                          start_date_month:  2,
    #                          start_date_day:    2,
    #                          verbatim_locality: 'environs of B',
    #                          verbatim_label:    'Bah',
    #                          geographic_area:   area_b,
    #                          creator:           joe,
    #                          updater:           user,
    #                          project:           project)

    # co_b = FactoryBot.create(:valid_collection_object,
    #                          created_at:       '2001/01/01',
    #                          updated_at:       '2001/07/01',
    #                          collecting_event: ce_b)

    # gr_b = FactoryBot.create(:georeference_verbatim_data,
    #                          api_request:           'area_b',
    #                          collecting_event:      ce_b,
    #                          error_geographic_item: new_box_b,
    #                          geographic_item:       GeographicItem.new(point: new_box_b.st_centroid))

    # sargon = Person.create!(first_name: 'of Akkad', last_name: 'Sargon')
    # andy   = Person.create!(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author')
    # daryl  = Person.create!(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon')
    # ted    = FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC')
    # bill   = Person.create!(first_name: 'Bill', last_name: 'Ardson')

    # top_dog = FactoryBot.create(:valid_otu, name: 'Top Dog', taxon_name:
    #                                               FactoryBot.create(:valid_taxon_name,
    #                                                                 rank_class: Ranks.lookup(:iczn, 'Family'),
    #                                                                 name:       'Topdogidae')
    # )

    # nuther_dog = FactoryBot.create(:valid_otu, name: 'Another Dog', taxon_name:
    #                                                  FactoryBot.create(:valid_taxon_name,
    #                                                                    rank_class: Ranks.lookup(:iczn, 'Family'),
    #                                                                    name:       'Nutherdogidae')
    # )
    #
    # tn_abra = Protonym.create!(name:       'Abra',
    #                            rank_class: Ranks.lookup(:iczn, 'Genus'),
    #                            parent:     top_dog.taxon_name)
    #
    # tn_spooler = Protonym.create!(name:       'spooler',
    #                               rank_class: Ranks.lookup(:iczn, 'Species'),
    #                               parent:     tn_abra)
    #
    # tn_cadabra  = Protonym.create!(name:                'cadabra',
    #                                year_of_publication: 2017,
    #                                verbatim_author:     'Bill Ardson',
    #                                rank_class:          Ranks.lookup(:iczn, 'Species'),
    #                                parent:              tn_abra)
    # tn_alakazam = Protonym.create!(name:       'alakazam',
    #                                rank_class: Ranks.lookup(:iczn, 'Subspecies'),
    #                                parent:     tn_cadabra)

    # by_bill = FactoryBot.create(:valid_otu, name: 'Top Dog (by Bill)', taxon_name: top_dog.taxon_name)

    # o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'Otu_A')
    # o.taxon_name.update_column(:name, 'antivitis')
    # co_a.otus << o
    #
    # o = top_dog # this is o1
    # o.taxon_name.taxon_name_authors << ted
    # co_a.otus << o
    #
    # o            = by_bill
    # o.taxon_name = top_dog.taxon_name
    # co_a.otus << o
    #
    # o            = FactoryBot.create(:valid_otu, name: 'Abra')
    # o.taxon_name = tn_abra
    # o.taxon_name.taxon_name_authors << ted
    # co_a.otus << o
    #
    # o            = FactoryBot.create(:valid_otu, name: 'Abra cadabra')
    # t_n          = tn_cadabra
    # o.taxon_name = t_n
    # o.save!
    # o.taxon_name.taxon_name_authors << bill
    # co_a.otus << o
    # o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam')
    # co_a.collecting_event.collectors << bill
    # o.taxon_name = tn_alakazam
    #
    # o.taxon_name.taxon_name_authors << ted
    # co_a.otus << o
    # o.taxon_name
    #
    # o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P4')
    # co_b.collecting_event.collectors << sargon
    # co_b.collecting_event.collectors << daryl
    # o.taxon_name.update_column(:name, 'beevitis')
    # co_b.otus << o
    # o            = FactoryBot.create(:valid_otu, name: 'Sargon\'s spooler')
    # o.taxon_name = tn_spooler
    # o.taxon_name.taxon_name_authors << sargon
    # o.taxon_name.taxon_name_authors << daryl
    # co_b.otus << o
    # o = nuther_dog
    # o.taxon_name.taxon_name_authors << bill
    # o.taxon_name.taxon_name_authors << ted
    # o.taxon_name.taxon_name_authors << sargon
    # co_b.otus << o

    # $user_id    = temp_user
    # $project_id = temp_project
  end
  # rubocop:enable Metrics/MethodLength
end

# @return [Multipolygon]
def make_box(base, offset_x, offset_y, size_x, size_y) # rubocop:disable Metrics/AbcSize
  box = RSPEC_GEO_FACTORY.polygon(
    RSPEC_GEO_FACTORY.line_string(
      [
        RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y, 0.0),
        RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y, 0.0),
        RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y - size_y, 0.0),
        RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y - size_y, 0.0)
      ]
    )
  )
  RSPEC_GEO_FACTORY.multi_polygon([box])
end
# rubocop:enable Metrics/AbcSize
