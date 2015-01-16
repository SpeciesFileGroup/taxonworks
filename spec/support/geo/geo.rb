# require 'geo_locate_string'
# require 'illinois'
# require 'indiana'
# require 'iowa'

# http://en.wikiversity.org/wiki/Geographic_coordinate_conversion

LATLONG_USE_CASES = {'w88∫11′43.4″'                  => '-88.195389', #current test case
                     '40º26\'46"N'                   => '40.446111', # using MAC-native symbols
                     '079º58\'56"W'                  => '-79.982222', # using MAC-native symbols
                     '40:26:46.302N'                 => '40.446195',
                     '079:58:55.903W'                => '-79.982195',
                     '40°26′46″N'                    => '40.446111',
                     '079°58′56″W'                   => '-79.982222',
                     '40d 26′ 46″ N'                 => '40.446111',
                     '079d 58′ 56″ W'                => '-79.982222',
                     '40.446195N'                    => '40.446195',
                     '79.982195W'                    => '-79.982195',
                     '40.446195'                     => '40.446195',
                     '-79.982195'                    => '-79.982195',
                     '40° 26.7717'                   => '40.446195',
                     '-79° 58.93172'                 => '-79.982195',
                     'N40:26:46.302'                 => '40.446195',
                     'W079:58:55.903'                => '-79.982195',
                     'N40°26′46″'                    => '40.446111',
                     'W079°58′56″'                   => '-79.982222',
                     'N40d 26′ 46″'                  => '40.446111',
                     'W079d 58′ 56″'                 => '-79.982222',
                     'N40.446195'                    => '40.446195',
                     'W79.982195'                    => '-79.982195',
                     # some special characters for Dmitry
                     "  40\u02da26¥46¥S"             => '-40.446111',
                     '42∞5\'18.1"S'                  => '-42.088361',
                     'w88∞11\'43.3"'                 => '-88.195361',
                     "  42\u02da5¥18.1¥S"            => '-42.088361',
                     "  42º5'18.1'S"                 => '-42.088361',
                     "  42o5\u02b918.1\u02b9\u02b9S" => '-42.088361',
                     'w88∫11′43.3″'                  => '-88.195361',
                     'nan'                           => nil,
                     'NAN'                           => nil

}

# Dmitry's special cases of º, ', "

# case 1:  ]  42∞5'18.1"S[
# "\D(\d+) ?[\*∞∫o\u02DA ] ?(\d+) ?[ '¥\u02B9\u02BC\u02CA] ?(\d+[\.|,]\d+|\d+) ?[ ""\u02BA\u02EE'¥\u02B9\u02BC\u02CA]['¥\u02B9\u02BC\u02CA]? ?([nN]|[sS])"

#  1. Non-digit => dropped
#  2. 1 or more digits
#     => group 0
#  3. 0 or 1 spaces => dropped
#  4. *, ∞, ∫, o, \u02DA, space
#     => match for º
#  5. 0 or 1 spaces => dropped
#  6. 1 or more digits
#     => group 1
#  7. 0 or 1 spaces => dropped
#  8. space, ', ¥, \u02B9, \u02BC, \u02CA
#     => match for '
#  9. 0 or 1 spaces => dropped
# 10.
#     a.
#       1. 1 or more digits
#       2. period, |, comma, => match for period
#       3. 1 or more digits
#     or
#     b. 1 or more digits
#      => group 2
# 11. 0 or 1 spaces => dropped
# 12. space, ", \u02BA, \u02EE, ', ¥, \u02B9, \u02BC, \u02CA, followed by 0 or 1 of ', ¥, \u02B9, \u02BC, \u02CA
#     => match for "
# 13. 0 or 1 spaces => dropped
# 14. N, S, E, W, case-insensitive cardinal letter
#     => group 3

# case 2: ] S42∞5'18.1"[
# "\W([nN]|[sS])\.? ?(\d+) ?[\*∞∫o\u02DA ] ?(\d+) ?[ '¥\u02B9\u02BC\u02CA] ?(\d+[\.|,]\d+|\d+) ?[ ""\u02BA\u02EE'¥\u02B9\u02BC\u02CA]['¥\u02B9\u02BC\u02CA]?[\.,;]?"

# case 3: ] S42∞5.18'[
# "\W([nN]|[sS])\.? ?(\d+) ?[\*∞∫o\u02DA ] ?(\d+[\.|,]\d+|\d+) ?[ '¥\u02B9\u02BC\u02CA][\.,;]?"

# case 4: ]42∞5.18'S[
# "\D(\d+) ?[\*∞∫o\u02DA ] ?(\d+[\.|,]\d+|\d+) ?[ '¥\u02B9\u02BC\u02CA]? ?([nN]|[sS])"
# case 5: ]S42.18∞[
# "\W([nN]|[sS])\.? ?(\d+[\.|,]\d+|\d+) ?[\*∞∫∫o\u02DA ][\.,;]?"

# case 6: ]42.18∞S[
# "\D(\d+[\.|,]\d+|\d+) ?[\*∞∫o\u02DA ] ?([nN]|[sS])"

# case 7: ]-12.263[
# "\D\[(-?\d+[\.|,]\d+|\-?d+)"

#FFI_FACTORY = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_m_coordinate: false, has_z_coordinate: true)

# this is the factory for use *only* by rspec
# for normal build- and run-time, use Georeference::FACTORY

RSPEC_GEO_FACTORY = Georeference::FACTORY

ROOM2024 = RSPEC_GEO_FACTORY.point(-88.241413, 40.091655, 757)

# select count(id) from geographic_items where ST_Distance(multi_polygon, ST_GeographyFromText('srid=4326;POINT(-88.241413 40.091655)')) < 10000 ;
# select count(id) from geographic_items where ST_contains(multi_polygon::geometry, ST_GeomFromText('srid=4326;POINT(-88.241413 40.091655)')) ;

=begin
-- same as geometry example but note units in meters - use sphere for slightly faster less accurate
SELECT ST_Distance(gg1, gg2) As spheroid_dist, ST_Distance(gg1, gg2, false) As sphere_dist
FROM (SELECT
  ST_GeographyFromText('SRID=4326;POINT(-88.241413 40.091655)') As gg1,
  ST_GeographyFromText('SRID=4326;POINT(-88.203595 40.089355)') As gg2
  ) As trial  ;exit
=end

ROOM2020 = RSPEC_GEO_FACTORY.point(-88.241421, 40.091565, 757)
ROOM2022 = RSPEC_GEO_FACTORY.point((ROOM2020.x + ((ROOM2024.x - ROOM2020.x) / 2)),
                                   (ROOM2020.y + ((ROOM2024.y - ROOM2020.y) / 2)),
                                   (ROOM2020.z + ((ROOM2024.z - ROOM2020.z) / 2)))

ROOMS20NN = RSPEC_GEO_FACTORY.multi_point([ROOM2020,
                                           ROOM2022,
                                           ROOM2024])

GI_POINT_A       = RSPEC_GEO_FACTORY.point(-88.241413, 40.091655)
GI_POINT_C       = RSPEC_GEO_FACTORY.point(-88.243386, 40.116402)
GI_POINT_M       = RSPEC_GEO_FACTORY.point(-88.196736, 40.090091)
GI_POINT_U       = RSPEC_GEO_FACTORY.point(-88.204517, 40.110037)
GI_LS01          = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21),
                                                  RSPEC_GEO_FACTORY.point(-25, 21),
                                                  RSPEC_GEO_FACTORY.point(-25, 16),
                                                  RSPEC_GEO_FACTORY.point(-21, 20)])
GI_LS02          = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21),
                                                  RSPEC_GEO_FACTORY.point(-25, 21),
                                                  RSPEC_GEO_FACTORY.point(-25, 16),
                                                  RSPEC_GEO_FACTORY.point(-21, 20)])
GI_POLYGON       = RSPEC_GEO_FACTORY.polygon(GI_LS02)
GI_MULTI_POLYGON = RSPEC_GEO_FACTORY.multi_polygon(
  [RSPEC_GEO_FACTORY.polygon(
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             RSPEC_GEO_FACTORY.line_string(
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               [RSPEC_GEO_FACTORY.point(-168.16047115799995, -14.520928643999923),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                RSPEC_GEO_FACTORY.point(-168.16156979099992, -14.532891533999944),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                RSPEC_GEO_FACTORY.point(-168.17308508999994, -14.523695570999877),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                RSPEC_GEO_FACTORY.point(-168.16352291599995, -14.519789320999891),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                RSPEC_GEO_FACTORY.point(-168.16047115799995, -14.520928643999923)])),

   RSPEC_GEO_FACTORY.polygon(
     RSPEC_GEO_FACTORY.line_string(
       [RSPEC_GEO_FACTORY.point(-170.62006588399993, -14.254571221999868),
        RSPEC_GEO_FACTORY.point(-170.59101314999987, -14.264825127999885),
        RSPEC_GEO_FACTORY.point(-170.5762426419999, -14.252536716999927),
        RSPEC_GEO_FACTORY.point(-170.5672501289999, -14.258558851999851),
        RSPEC_GEO_FACTORY.point(-170.5684708319999, -14.27092864399988),
        RSPEC_GEO_FACTORY.point(-170.58417721299995, -14.2777645809999),
        RSPEC_GEO_FACTORY.point(-170.6423233709999, -14.280694268999909),
        RSPEC_GEO_FACTORY.point(-170.65929114499988, -14.28525155999995),
        RSPEC_GEO_FACTORY.point(-170.68358313699994, -14.302829684999892),
        RSPEC_GEO_FACTORY.point(-170.7217911449999, -14.353448174999883),
        RSPEC_GEO_FACTORY.point(-170.74864661399988, -14.374688408999873),
        RSPEC_GEO_FACTORY.point(-170.75548255099991, -14.367120049999912),
        RSPEC_GEO_FACTORY.point(-170.79645748599992, -14.339939059999907),
        RSPEC_GEO_FACTORY.point(-170.82282467399992, -14.326755466999956),
        RSPEC_GEO_FACTORY.point(-170.83124752499987, -14.319431247999944),
        RSPEC_GEO_FACTORY.point(-170.78864498599992, -14.294528903999918),
        RSPEC_GEO_FACTORY.point(-170.77257239499986, -14.291436455999929),
        RSPEC_GEO_FACTORY.point(-170.7378637359999, -14.292087497999887),
        RSPEC_GEO_FACTORY.point(-170.72150631399987, -14.289239190999936),
        RSPEC_GEO_FACTORY.point(-170.69847571499992, -14.260511976999894),
        RSPEC_GEO_FACTORY.point(-170.66144771999987, -14.252373955999872),
        RSPEC_GEO_FACTORY.point(-170.62006588399993, -14.254571221999868)])),

   RSPEC_GEO_FACTORY.polygon(
     RSPEC_GEO_FACTORY.line_string(
       [RSPEC_GEO_FACTORY.point(-169.44013424399992, -14.245293877999913),
        RSPEC_GEO_FACTORY.point(-169.44713294199988, -14.255629164999917),
        RSPEC_GEO_FACTORY.point(-169.46015377499987, -14.250420830999914),
        RSPEC_GEO_FACTORY.point(-169.46808834499996, -14.258721612999906),
        RSPEC_GEO_FACTORY.point(-169.4761856759999, -14.262383721999853),
        RSPEC_GEO_FACTORY.point(-169.48497473899994, -14.261976820999848),
        RSPEC_GEO_FACTORY.point(-169.49486243399994, -14.257256768999937),
        RSPEC_GEO_FACTORY.point(-169.49836178299995, -14.2660458309999),
        RSPEC_GEO_FACTORY.point(-169.50426184799989, -14.270603122999944),
        RSPEC_GEO_FACTORY.point(-169.51252193899995, -14.271742445999891),
        RSPEC_GEO_FACTORY.point(-169.52281653599988, -14.27092864399988),
        RSPEC_GEO_FACTORY.point(-169.52550208199995, -14.258965752999941),
        RSPEC_GEO_FACTORY.point(-169.52928626199989, -14.248793226999894),
        RSPEC_GEO_FACTORY.point(-169.53477942599991, -14.241143487999878),
        RSPEC_GEO_FACTORY.point(-169.54267330599987, -14.236748955999886),
        RSPEC_GEO_FACTORY.point(-169.5275365879999, -14.22600676899988),
        RSPEC_GEO_FACTORY.point(-169.50645911399988, -14.222263278999932),
        RSPEC_GEO_FACTORY.point(-169.4638565749999, -14.223239841999913),
        RSPEC_GEO_FACTORY.point(-169.44404049399992, -14.230645440999893),
        RSPEC_GEO_FACTORY.point(-169.44013424399992, -14.245293877999913)])),

   RSPEC_GEO_FACTORY.polygon(
     RSPEC_GEO_FACTORY.line_string(
       [RSPEC_GEO_FACTORY.point(-169.6356095039999, -14.17701588299991),
        RSPEC_GEO_FACTORY.point(-169.6601456369999, -14.189141533999901),
        RSPEC_GEO_FACTORY.point(-169.6697485019999, -14.187920830999886),
        RSPEC_GEO_FACTORY.point(-169.67621822799987, -14.174899997999901),
        RSPEC_GEO_FACTORY.point(-169.67617753799988, -14.174899997999901),
        RSPEC_GEO_FACTORY.point(-169.66816158799995, -14.169122002999927),
        RSPEC_GEO_FACTORY.point(-169.65819251199994, -14.168877862999892),
        RSPEC_GEO_FACTORY.point(-169.6471654939999, -14.172133070999848),
        RSPEC_GEO_FACTORY.point(-169.6356095039999, -14.17701588299991)])),

   RSPEC_GEO_FACTORY.polygon(
     RSPEC_GEO_FACTORY.line_string(
       [RSPEC_GEO_FACTORY.point(-171.07347571499992, -11.062107028999876),
        RSPEC_GEO_FACTORY.point(-171.08153235599985, -11.066094658999859),
        RSPEC_GEO_FACTORY.point(-171.08653723899988, -11.060316664999888),
        RSPEC_GEO_FACTORY.point(-171.0856420559999, -11.05136484199987),
        RSPEC_GEO_FACTORY.point(-171.0728246739999, -11.052504164999903),
        RSPEC_GEO_FACTORY.point(-171.07347571499992, -11.062107028999876)]))])

POINT0  = RSPEC_GEO_FACTORY.point(0, 0)
POINT1  = RSPEC_GEO_FACTORY.point(-29, -16)
POINT2  = RSPEC_GEO_FACTORY.point(-25, -18)
POINT3  = RSPEC_GEO_FACTORY.point(-28, -21)
POINT4  = RSPEC_GEO_FACTORY.point(-19, -18)
POINT5  = RSPEC_GEO_FACTORY.point(3, -14)
POINT6  = RSPEC_GEO_FACTORY.point(6, -12.9)
POINT7  = RSPEC_GEO_FACTORY.point(5, -16)
POINT8  = RSPEC_GEO_FACTORY.point(4, -17.9)
POINT9  = RSPEC_GEO_FACTORY.point(7, -17.9)
POINT10 = RSPEC_GEO_FACTORY.point(32.2, 22)
POINT11 = RSPEC_GEO_FACTORY.point(-17, 7)
POINT12 = RSPEC_GEO_FACTORY.point(-9.8, 5)
POINT13 = RSPEC_GEO_FACTORY.point(-10.7, 0)
POINT14 = RSPEC_GEO_FACTORY.point(-30, 21)
POINT15 = RSPEC_GEO_FACTORY.point(-25, 18.3)
POINT16 = RSPEC_GEO_FACTORY.point(-23, 18)
POINT17 = RSPEC_GEO_FACTORY.point(-19.6, -13)
POINT18 = RSPEC_GEO_FACTORY.point(-7.6, 14.2)
POINT19 = RSPEC_GEO_FACTORY.point(-4.6, 11.9)
POINT20 = RSPEC_GEO_FACTORY.point(-8, -4)
POINT21 = RSPEC_GEO_FACTORY.point(-4, -8)
POINT22 = RSPEC_GEO_FACTORY.point(-10, -6)

SHAPE_A = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21),
                                         RSPEC_GEO_FACTORY.point(-25, 21),
                                         RSPEC_GEO_FACTORY.point(-25, 16),
                                         RSPEC_GEO_FACTORY.point(-21, 20)])

LIST_B1 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-14, 23),
                                         RSPEC_GEO_FACTORY.point(-14, 11),
                                         RSPEC_GEO_FACTORY.point(-2, 11),
                                         RSPEC_GEO_FACTORY.point(-2, 23),
                                         RSPEC_GEO_FACTORY.point(-8, 21)])

LIST_B2 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-11, 18),
                                         RSPEC_GEO_FACTORY.point(-8, 17),
                                         RSPEC_GEO_FACTORY.point(-6, 20),
                                         RSPEC_GEO_FACTORY.point(-4, 16),
                                         RSPEC_GEO_FACTORY.point(-7, 13),
                                         RSPEC_GEO_FACTORY.point(-11, 14)])

SHAPE_B       = RSPEC_GEO_FACTORY.polygon(LIST_B1, [LIST_B2])
SHAPE_B_OUTER = RSPEC_GEO_FACTORY.polygon(LIST_B1)
SHAPE_B_INNER = RSPEC_GEO_FACTORY.polygon(LIST_B2)

LIST_C1 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(23, 21),
                                         RSPEC_GEO_FACTORY.point(16, 21),
                                         RSPEC_GEO_FACTORY.point(16, 16),
                                         RSPEC_GEO_FACTORY.point(11, 20)])

LIST_C2 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(4, 12.6),
                                         RSPEC_GEO_FACTORY.point(16, 12.6),
                                         RSPEC_GEO_FACTORY.point(16, 7.6)])

LIST_C3 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(21, 12.6),
                                         RSPEC_GEO_FACTORY.point(26, 12.6),
                                         RSPEC_GEO_FACTORY.point(22, 17.6)])

SHAPE_C  = RSPEC_GEO_FACTORY.multi_line_string([LIST_C1, LIST_C2, LIST_C3])
SHAPE_C1 = SHAPE_C.geometry_n(0)
SHAPE_C2 = SHAPE_C.geometry_n(1)
SHAPE_C3 = SHAPE_C.geometry_n(2)

SHAPE_D = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-33, 11),
                                         RSPEC_GEO_FACTORY.point(-24, 4),
                                         RSPEC_GEO_FACTORY.point(-26, 13),
                                         RSPEC_GEO_FACTORY.point(-31, 4),
                                         RSPEC_GEO_FACTORY.point(-33, 11)])

LIST_E1 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-19, 9),
                                         RSPEC_GEO_FACTORY.point(-9, 9),
                                         RSPEC_GEO_FACTORY.point(-9, 2),
                                         RSPEC_GEO_FACTORY.point(-19, 2),
                                         RSPEC_GEO_FACTORY.point(-19, 9)])

LIST_E2 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(5, -1),
                                         RSPEC_GEO_FACTORY.point(-14, -1),
                                         RSPEC_GEO_FACTORY.point(-14, 6),
                                         RSPEC_GEO_FACTORY.point(5, 6),
                                         RSPEC_GEO_FACTORY.point(5, -1)])

LIST_E3 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-11, -1),
                                         RSPEC_GEO_FACTORY.point(-11, -5),
                                         RSPEC_GEO_FACTORY.point(-7, -5),
                                         RSPEC_GEO_FACTORY.point(-7, -1),
                                         RSPEC_GEO_FACTORY.point(-11, -1)])

LIST_E4 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-3, -9),
                                         RSPEC_GEO_FACTORY.point(-3, -1),
                                         RSPEC_GEO_FACTORY.point(-7, -1),
                                         RSPEC_GEO_FACTORY.point(-7, -9),
                                         RSPEC_GEO_FACTORY.point(-3, -9)])

LIST_E5 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-7, -9),
                                         RSPEC_GEO_FACTORY.point(-7, -5),
                                         RSPEC_GEO_FACTORY.point(-11, -5),
                                         RSPEC_GEO_FACTORY.point(-11, -9),
                                         RSPEC_GEO_FACTORY.point(-7, -9)])

SHAPE_E = RSPEC_GEO_FACTORY.collection([RSPEC_GEO_FACTORY.polygon(LIST_E1),
                                        RSPEC_GEO_FACTORY.polygon(LIST_E2),
                                        RSPEC_GEO_FACTORY.polygon(LIST_E3),
                                        RSPEC_GEO_FACTORY.polygon(LIST_E4),
                                        RSPEC_GEO_FACTORY.polygon(LIST_E5)])

SHAPE_E1 = SHAPE_E.geometry_n(0)
SHAPE_E2 = SHAPE_E.geometry_n(1)
SHAPE_E3 = SHAPE_E.geometry_n(2)
SHAPE_E4 = SHAPE_E.geometry_n(3)
SHAPE_E5 = SHAPE_E.geometry_n(4)

POLY_E1 = RSPEC_GEO_FACTORY.polygon(LIST_E1)
POLY_E2 = RSPEC_GEO_FACTORY.polygon(LIST_E2)
POLY_E3 = RSPEC_GEO_FACTORY.polygon(LIST_E3)
POLY_E4 = RSPEC_GEO_FACTORY.polygon(LIST_E4)
POLY_E5 = RSPEC_GEO_FACTORY.polygon(LIST_E5)

SHAPE_F1 = RSPEC_GEO_FACTORY.line(RSPEC_GEO_FACTORY.point(-20, -1),
                                  RSPEC_GEO_FACTORY.point(-26, -6))

SHAPE_F2 = RSPEC_GEO_FACTORY.line(RSPEC_GEO_FACTORY.point(-21, -4),
                                  RSPEC_GEO_FACTORY.point(-31, -4))

SHAPE_F = RSPEC_GEO_FACTORY.multi_line_string([SHAPE_F1, SHAPE_F2])

LIST_G1 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(28, 2.3),
                                         RSPEC_GEO_FACTORY.point(23, -1.7),
                                         RSPEC_GEO_FACTORY.point(26, -4.8),
                                         RSPEC_GEO_FACTORY.point(28, 2.3)])

LIST_G2 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(22, -6.8),
                                         RSPEC_GEO_FACTORY.point(22, -9.8),
                                         RSPEC_GEO_FACTORY.point(16, -6.8),
                                         RSPEC_GEO_FACTORY.point(22, -6.8)])

LIST_G3 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(16, 2.3),
                                         RSPEC_GEO_FACTORY.point(14, -2.8),
                                         RSPEC_GEO_FACTORY.point(18, -2.8),
                                         RSPEC_GEO_FACTORY.point(16, 2.3)])

SHAPE_G  = RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(LIST_G1), RSPEC_GEO_FACTORY.polygon(LIST_G2), RSPEC_GEO_FACTORY.polygon(LIST_G3)])
SHAPE_G1 = SHAPE_G.geometry_n(0)
SHAPE_G2 = SHAPE_G.geometry_n(1)
SHAPE_G3 = SHAPE_G.geometry_n(2)

SHAPE_H = RSPEC_GEO_FACTORY.multi_point([POINT5,
                                         POINT6,
                                         POINT7,
                                         POINT8,
                                         POINT9])

SHAPE_I = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(27, -14),
                                         RSPEC_GEO_FACTORY.point(18, -21),
                                         RSPEC_GEO_FACTORY.point(20, -12),
                                         RSPEC_GEO_FACTORY.point(25, -23)])

SHAPE_J = RSPEC_GEO_FACTORY.collection([SHAPE_G, SHAPE_H, SHAPE_I])

LIST_K = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-33, -11),
                                        RSPEC_GEO_FACTORY.point(-33, -23),
                                        RSPEC_GEO_FACTORY.point(-21, -23),
                                        RSPEC_GEO_FACTORY.point(-21, -11),
                                        RSPEC_GEO_FACTORY.point(-27, -13)])

SHAPE_K = RSPEC_GEO_FACTORY.polygon(LIST_K)

SHAPE_L = RSPEC_GEO_FACTORY.line(RSPEC_GEO_FACTORY.point(-16, -15.5),
                                 RSPEC_GEO_FACTORY.point(-22, -20.5))

LIST_T1 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-1, 1),
                                         RSPEC_GEO_FACTORY.point(1, 1),
                                         RSPEC_GEO_FACTORY.point(1, -1),
                                         RSPEC_GEO_FACTORY.point(-1, -1)])

LIST_T2 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-2, 2),
                                         RSPEC_GEO_FACTORY.point(2, 2),
                                         RSPEC_GEO_FACTORY.point(2, -2),
                                         RSPEC_GEO_FACTORY.point(-2, -2)])

LIST_T3 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-3, 3),
                                         RSPEC_GEO_FACTORY.point(3, 3),
                                         RSPEC_GEO_FACTORY.point(3, -3),
                                         RSPEC_GEO_FACTORY.point(-3, -3)])

LIST_T4 = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-4, 4),
                                         RSPEC_GEO_FACTORY.point(4, 4),
                                         RSPEC_GEO_FACTORY.point(4, -4),
                                         RSPEC_GEO_FACTORY.point(-4, -4)])

BOX_1 = RSPEC_GEO_FACTORY.polygon(LIST_T1)
BOX_2 = RSPEC_GEO_FACTORY.polygon(LIST_T2)
BOX_3 = RSPEC_GEO_FACTORY.polygon(LIST_T3)
BOX_4 = RSPEC_GEO_FACTORY.polygon(LIST_T4)

ALL_SHAPES = RSPEC_GEO_FACTORY.collection([SHAPE_A,
                                           SHAPE_B,
                                           SHAPE_C,
                                           SHAPE_D,
                                           SHAPE_E,
                                           SHAPE_F,
                                           SHAPE_G,
                                           SHAPE_H,
                                           SHAPE_I,
                                           SHAPE_J,
                                           SHAPE_K,
                                           SHAPE_L,
                                           ROOMS20NN,
                                           POINT0,
                                           POINT1,
                                           POINT2,
                                           POINT3,
                                           POINT4,
                                           POINT5,
                                           POINT6,
                                           POINT7,
                                           POINT8,
                                           POINT9,
                                           POINT10,
                                           POINT11,
                                           POINT12,
                                           POINT13,
                                           POINT14,
                                           POINT15,
                                           POINT16,
                                           POINT17,
                                           POINT18,
                                           POINT19,
                                           POINT20,
                                           POINT21,
                                           POINT22,
                                           BOX_1,
                                           BOX_2,
                                           BOX_3,
                                           BOX_4])

CONVEX_HULL = ALL_SHAPES.convex_hull

POINT_M1_P0 = RSPEC_GEO_FACTORY.point(33, 28) # upper left corner of M1

ALL_WKT_NAMES = [[CONVEX_HULL.exterior_ring, 'Outer Limits'],
                 [SHAPE_A, 'A'],
                 [SHAPE_B, 'B'],
                 [SHAPE_C1, 'C1'],
                 [SHAPE_C2, 'C2'],
                 [SHAPE_C3, 'C3'],
                 [SHAPE_D, 'D'],
                 [SHAPE_E2, 'E2'],
                 [SHAPE_E1, 'E1'],
                 [SHAPE_E3, 'E3'],
                 [SHAPE_E4, 'E4'],
                 [SHAPE_E5, 'E5'],
                 [SHAPE_F1, 'F1'],
                 [SHAPE_F2, 'F2'],
                 [SHAPE_G1, 'G1'],
                 [SHAPE_G2, 'G2'],
                 [SHAPE_G3, 'G3'],
                 [SHAPE_H, 'H'],
                 [SHAPE_I, 'I'],
                 [SHAPE_J, 'J'],
                 [SHAPE_K, 'K'],
                 [SHAPE_L, 'L'],
                 [ROOM2020, 'Room 2020'],
                 [ROOM2022, 'Room 2022'],
                 [ROOM2024, 'Room 2024'],
                 [POINT0, 'P0'],
                 [POINT1, 'P1'],
                 [POINT2, 'P2'],
                 [POINT3, 'P3'],
                 [POINT4, 'P4'],
                 [POINT5, 'P5'],
                 [POINT6, 'P6'],
                 [POINT7, 'P7'],
                 [POINT8, 'P8'],
                 [POINT9, 'P9'],
                 [POINT10, 'P10'],
                 [POINT11, 'P11'],
                 [POINT12, 'P12'],
                 [POINT13, 'P13'],
                 [POINT14, 'P14'],
                 [POINT15, 'P15'],
                 [POINT16, 'P16'],
                 [POINT17, 'P17'],
                 [POINT18, 'P18'],
                 [POINT19, 'P19'],
                 [POINT20, 'P20'],
                 [POINT21, 'P21'],
                 [POINT22, 'P22'],
                 [BOX_1, 'Box_1'],
                 [BOX_2, 'Box_2'],
                 [BOX_3, 'Box_3'],
                 [BOX_4, 'Box_4']
]

E1_AND_E2 = RSPEC_GEO_FACTORY.parse_wkt('POLYGON ((-9.0 6.0 0.0, -9.0 2.0 0.0, -14.0 2.0 0.0, -14.0 6.0 0.0, -9.0 6.0 0.0))')
E1_OR_E2  = RSPEC_GEO_FACTORY.parse_wkt('POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0))')
E1_AND_E4 = RSPEC_GEO_FACTORY.parse_wkt('GEOMETRYCOLLECTION EMPTY')
E1_OR_E5  = RSPEC_GEO_FACTORY.parse_wkt('MULTIPOLYGON (((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))')

P16_ON_A = RSPEC_GEO_FACTORY.parse_wkt("POINT (-23.0 18.0 0.0)")


# IF you call this you have to use and after all to "unprepare"
def prepare_test

  u = User.order(:id).first
  if u.nil?
    u = FactoryGirl.create(:valid_user, id: 1)
  end
  $user_id    = u.id

  p = Project.order(:id).first
  if p.nil?
    p = FactoryGirl.create(:valid_project, id: 1)
  end
  $project_id = p.id

end

def generate_geo_test_objects

  prepare_test

  @p0  = FactoryGirl.build(:geographic_item, :point => POINT0.as_binary) # 0
  @p1  = FactoryGirl.build(:geographic_item, :point => POINT1.as_binary) # 1
  @p2  = FactoryGirl.build(:geographic_item, :point => POINT2.as_binary) # 2
  @p3  = FactoryGirl.build(:geographic_item, :point => POINT3.as_binary) # 3
  @p4  = FactoryGirl.build(:geographic_item, :point => POINT4.as_binary) # 4
  @p5  = FactoryGirl.build(:geographic_item, :point => POINT5.as_binary) # 5
  @p6  = FactoryGirl.build(:geographic_item, :point => POINT6.as_binary) # 6
  @p7  = FactoryGirl.build(:geographic_item, :point => POINT7.as_binary) # 7
  @p8  = FactoryGirl.build(:geographic_item, :point => POINT8.as_binary) # 8
  @p9  = FactoryGirl.build(:geographic_item, :point => POINT9.as_binary) # 9
  @p10 = FactoryGirl.build(:geographic_item, :point => POINT10.as_binary) # 10
  @p11 = FactoryGirl.build(:geographic_item, :point => POINT11.as_binary) # 11
  @p12 = FactoryGirl.build(:geographic_item, :point => POINT12.as_binary) # 12
  @p13 = FactoryGirl.build(:geographic_item, :point => POINT13.as_binary) # 13
  @p14 = FactoryGirl.build(:geographic_item, :point => POINT14.as_binary) # 14
  @p15 = FactoryGirl.build(:geographic_item, :point => POINT15.as_binary) # 15
  @p16 = FactoryGirl.build(:geographic_item, :point => POINT16.as_binary) # 16
  @p17 = FactoryGirl.build(:geographic_item, :point => POINT17.as_binary) # 17
  @p18 = FactoryGirl.build(:geographic_item, :point => POINT18.as_binary) # 18
  @p19 = FactoryGirl.build(:geographic_item, :point => POINT19.as_binary) # 19
  @p20 = FactoryGirl.build(:geographic_item, :point => POINT20.as_binary) # 20
  @p21 = FactoryGirl.build(:geographic_item, :point => POINT21.as_binary) # 21
  @p22 = FactoryGirl.build(:geographic_item, :point => POINT22.as_binary) # 22

  @a  = FactoryGirl.build(:geographic_item, :line_string => SHAPE_A.as_binary) # 23
  @b1 = FactoryGirl.build(:geographic_item, :polygon => SHAPE_B_OUTER.as_binary) # 24
  @b2 = FactoryGirl.build(:geographic_item, :polygon => SHAPE_B_INNER.as_binary) # 25
  @b  = FactoryGirl.build(:geographic_item, :polygon => SHAPE_B.as_binary) # 26
  @c1 = FactoryGirl.build(:geographic_item, :line_string => SHAPE_C1) # 27
  @c2 = FactoryGirl.build(:geographic_item, :line_string => SHAPE_C2) # 28
  @c3 = FactoryGirl.build(:geographic_item, :line_string => SHAPE_C3) # 29
  @c  = FactoryGirl.build(:geographic_item, :multi_line_string => SHAPE_C.as_binary) # 30
  @d  = FactoryGirl.build(:geographic_item, :line_string => SHAPE_D.as_binary) # 31
  @e1 = FactoryGirl.build(:geographic_item, :polygon => POLY_E1.as_binary) # 32
  @e2 = FactoryGirl.build(:geographic_item, :polygon => POLY_E2.as_binary) # 33
  @e3 = FactoryGirl.build(:geographic_item, :polygon => POLY_E3.as_binary) # 34
  @e4 = FactoryGirl.build(:geographic_item, :polygon => POLY_E4.as_binary) # 35
  @e5 = FactoryGirl.build(:geographic_item, :polygon => POLY_E5.as_binary) # 36
  @e  = FactoryGirl.build(:geographic_item, :geometry_collection => SHAPE_E.as_binary) # 37
  @f1 = FactoryGirl.build(:geographic_item, :line_string => SHAPE_F1.as_binary) # 38
  @f2 = FactoryGirl.build(:geographic_item, :line_string => SHAPE_F2.as_binary) # 39
  @f  = FactoryGirl.build(:geographic_item, :multi_line_string => SHAPE_F.as_binary) # 40
  @g1 = FactoryGirl.build(:geographic_item, :polygon => SHAPE_G1.as_binary) # 41
  @g2 = FactoryGirl.build(:geographic_item, :polygon => SHAPE_G2.as_binary) # 42
  @g3 = FactoryGirl.build(:geographic_item, :polygon => SHAPE_G3.as_binary) # 43
  @g  = FactoryGirl.build(:geographic_item, :multi_polygon => SHAPE_G.as_binary) # 44
  @h  = FactoryGirl.build(:geographic_item, :multi_point => SHAPE_H.as_binary) # 45
  @i  = FactoryGirl.build(:geographic_item, :line_string => SHAPE_I) # 46
  @j  = FactoryGirl.build(:geographic_item, :geometry_collection => SHAPE_J) # 47
  @k  = FactoryGirl.build(:geographic_item, :polygon => SHAPE_K.as_binary) # 48
  @l  = FactoryGirl.build(:geographic_item, :line_string => SHAPE_L.as_binary) # 49

  @r2020 = FactoryGirl.build(:geographic_item, :point => ROOM2020.as_binary) # 50
  @r2022 = FactoryGirl.build(:geographic_item, :point => ROOM2022.as_binary) # 51
  @r2024 = FactoryGirl.build(:geographic_item, :point => ROOM2024.as_binary) # 52
  @rooms = FactoryGirl.build(:geographic_item, :multi_point => ROOMS20NN.as_binary) # 53

  @all_items    = FactoryGirl.build(:geographic_item, :geometry_collection => ALL_SHAPES.as_binary) # 54
  @outer_limits = FactoryGirl.build(:geographic_item, :line_string => CONVEX_HULL.exterior_ring.as_binary) # 55

  @item_a = FactoryGirl.build(:geographic_item, polygon: BOX_1)
  @item_b = FactoryGirl.build(:geographic_item, polygon: BOX_2)
  @item_c = FactoryGirl.build(:geographic_item, polygon: BOX_3)
  @item_d = FactoryGirl.build(:geographic_item, polygon: BOX_4)

  @all_gi = [@p0, @p1, @p2, @p3, @p4,
             @p5, @p6, @p7, @p8, @p9,
             @p10, @p11, @p12, @p13, @p14,
             @p15, @p16, @p17, @p18, @p19,
             @p20, @p21, @p22,
             @a,
             @b1, @b2, @b,
             @c1, @c2, @c3, @c,
             @d,
             @e1, @e2, @e3, @e4, @e5, @e,
             @f1, @f2, @f,
             @g1, @g2, @g3, @g,
             @h,
             @i,
             @j,
             @k,
             @l,
             @r2020, @r2022, @r2024, @rooms,
             @all_items, @outer_limits,
             @item_a, @item_b, @item_c, @item_d]

  @all_gi.map(&:save!)

  @debug_names = {
    p0:           @p0.id,
    p1:           @p1.id,
    p2:           @p2.id,
    p3:           @p3.id,
    p4:           @p4.id,
    p5:           @p5.id,
    p6:           @p6.id,
    p7:           @p7.id,
    p8:           @p8.id,
    p9:           @p9.id,
    p10:          @p10.id,
    p11:          @p11.id,
    p12:          @p12.id,
    p13:          @p13.id,
    p14:          @p14.id,
    p15:          @p15.id,
    p16:          @p16.id,
    p17:          @p17.id,
    p18:          @p18.id,
    p19:          @p19.id,
    p20:          @p20.id,
    p21:          @p21.id,
    p22:          @p22.id,

    a:            @a.id,
    b1:           @b1.id,
    b2:           @b2.id,
    b:            @b.id,
    c1:           @c1.id,
    c2:           @c2.id,
    c3:           @c3.id,
    c:            @c.id,
    d:            @d.id,
    e1:           @e1.id,
    e2:           @e2.id,
    e3:           @e3.id,
    e4:           @e4.id,
    e5:           @e5.id,
    e:            @e.id,
    f1:           @f1.id,
    f2:           @f2.id,
    f:            @f.id,
    g1:           @g1.id,
    g2:           @g2.id,
    g3:           @g3.id,
    g:            @g.id,
    h:            @h.id,
    i:            @i.id,
    j:            @j.id,
    k:            @k.id,
    l:            @l.id,

    r2020:        @r2020.id,
    r2022:        @r2022.id,
    r2024:        @r2024.id,
    rooms:        @rooms.id,
    all_items:    @all_items.id,
    outer_limits: @outer_limits.id,

    item_a:       @item_a.id,
    item_b:       @item_b.id,
    item_c:       @item_c.id,
    item_d:       @item_d.id
  }

  my_debug = false

  if my_debug
    puts
    @debug_names.collect { |k, v| print "#{' ' * 4}" + v.to_s + ": " + k.to_s }
    puts @debug_names.invert[@p1]
    all_file = File.new('./tmp/all_file.json', 'w')
    all_file.write(@all_items.to_geo_json_feature)
    all_file.close
  end
  @debug_names
end

def generate_ce_test_objects

  @debug_names = generate_geo_test_objects if @p0.nil?

  @ce_p0 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p0')
  @gr00  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr00',
                              :collecting_event      => @ce_p0,
                              :error_geographic_item => @item_d,
                              :geographic_item       => @p0) #  1
  @gr10  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr10',
                              :collecting_event => @ce_p0,
                              :geographic_item  => @p10) #  2

  gat_land_mass = GeographicAreaType.find_or_create_by(name: 'Land Mass')

  # now, for the areas, top-down
  object        = FactoryGirl.create(:valid_geographic_area_stack)

  # first, level 0 areas
  earth         = GeographicArea.where(:name => 'Earth').first

  @ga_k = FactoryGirl.create(:geographic_area,
                             name:                 'k',
                             level0:               earth,
                             parent:               earth,
                             data_origin:          'ce_test_objects',
                             geographic_area_type: gat_land_mass)
  @ga_k.geographic_items << @k

  @ce_p1 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p1 collect_event test')
  @gr01  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr01',
                              :collecting_event      => @ce_p1,
                              :error_geographic_item => @k,
                              :geographic_item       => @p1) #  3
  @gr11  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr11',
                              :error_geographic_item => @e1,
                              :collecting_event      => @ce_p1,
                              :geographic_item       => @p11) #  4

  @ce_p2 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p2 collect_event test')
  @gr02  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr02',
                              :collecting_event      => @ce_p2,
                              :error_geographic_item => @k,
                              :geographic_item       => @p2)
  @gr121 = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr121',
                              :collecting_event      => @ce_p2,
                              :error_geographic_item => @e1,
                              :geographic_item       => @p12)
  @gr122 = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr122',
                              :collecting_event      => @ce_p2,
                              :error_geographic_item => @e2,
                              :geographic_item       => @p12)

  @ce_p3 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p3 collect_event test')
  @gr03  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr03',
                              :collecting_event      => @ce_p3,
                              :error_geographic_item => @k,
                              :geographic_item       => @p3)
  @gr13  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr13',
                              :collecting_event      => @ce_p3,
                              :error_geographic_item => @e2,
                              :geographic_item       => @p13)

  @ce_p4 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p4 collect_event test')
  @gr04  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr04',
                              :collecting_event => @ce_p4,
                              :geographic_item  => @p4)
  @gr14  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr14',
                              :collecting_event => @ce_p4,
                              :geographic_item  => @p14)

  @ce_p5 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p5')
  @gr05  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr05',
                              :collecting_event => @ce_p5,
                              :geographic_item  => @p5)
  @gr15  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr15',
                              :collecting_event => @ce_p5,
                              :geographic_item  => @p15)

  @ce_p6 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p6')
  @gr06  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr06',
                              :collecting_event => @ce_p6,
                              :geographic_item  => @p6)
  @gr16  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr16',
                              :collecting_event => @ce_p6,
                              :geographic_item  => @p16)

  @ce_p7 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p7')
  @gr07  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr07',
                              :collecting_event => @ce_p7,
                              :geographic_item  => @p7)
  @gr17  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr17',
                              :collecting_event => @ce_p7,
                              :geographic_item  => @p17)

  @ce_p8 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p8')
  @gr08  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr08',
                              :collecting_event => @ce_p8,
                              :geographic_item  => @p8)
  @gr18  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr18',
                              :collecting_event      => @ce_p8,
                              :error_geographic_item => @b2,
                              :geographic_item       => @p18)

  @ce_p9 = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_p9')
  @gr09  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request      => 'gr09',
                              :collecting_event => @ce_p9,
                              :geographic_item  => @p9)
  @gr19  = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr19',
                              :collecting_event      => @ce_p9,
                              :error_geographic_item => @b,
                              :geographic_item       => @p19)

  @ce_area_d = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_area_d')
  @gr_area_d = FactoryGirl.create(:georeference_verbatim_data,
                                  :api_request      => 'gr_area_d',
                                  :collecting_event => @ce_area_d,
                                  :geographic_item  => @item_d)

  @ce_area_v = FactoryGirl.create(:collecting_event, :verbatim_label => '@ce_area_v collecting event test')
  # @gr_area_v = FactoryGirl.create(:georeference_verbatim_data,
  #                                 :api_request      => 'gr_area_v',
  #                                 :collecting_event => @ce_area_v,
  #                                 :geographic_item  => @item_v)

end

def gen_wkt_files_1()
  # using the prebuilt RGeo test objects, write out three QGIS-acceptable WKT files, one each for points, linestrings, and polygons.
  f_point = File.new('./tmp/RGeoPoints.wkt', 'w+')
  f_line  = File.new('./tmp/RGeoLines.wkt', 'w+')
  f_poly  = File.new('./tmp/RGeoPolygons.wkt', 'w+')

  col_header = "id:wkt:name\n"

  f_point.write(col_header)
  f_line.write(col_header)
  f_poly.write(col_header)

  ALL_WKT_NAMES.each_with_index do |it, index|
    wkt  = it[0].as_text
    name = it[1]
    case it[0].geometry_type.type_name
      when 'Point'
        f_type = f_point
      when 'MultiPoint'
        # MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0)
        f_type = $stdout
      when /^Line[S]*/ #when 'Line' or 'LineString'
        f_type = f_line
      when 'MultiLineString'
        # MULTILINESTRING ((-20.0 -1.0 0.0, -26.0 -6.0 0.0), (-21.0 -4.0 0.0, -31.0 -4.0 0.0))
        f_type = $stdout
      when 'Polygon'
        f_type = f_poly
      when 'MultiPolygon'
        # MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0))
        f_type = $stdout
      when 'GeometryCollection'
        # GEOMETRYCOLLECTION (POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), POLYGON ((5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0)), POLYGON ((-11.0 -1.0 0.0, -11.0 -5.0 0.0, -7.0 -5.0 0.0, -7.0 -1.0 0.0, -11.0 -1.0 0.0)), POLYGON ((-3.0 -9.0 0.0, -3.0 -1.0 0.0, -7.0 -1.0 0.0, -7.0 -9.0 0.0, -3.0 -9.0 0.0)), POLYGON ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))
        f_type = $stdout
      else
        f_type = $stdout
      # ignore it for now
    end
    f_type.write("#{index}:#{wkt}: #{name}\n")
  end

  f_point.close
  f_line.close
  f_poly.close
end

def gen_wkt_files()
  # using the prebuilt RGeo test objects, write out three QGIS-acceptable WKT files, one each for points, linestrings, and polygons.
  f_point = File.new('./tmp/RGeoPoints.wkt', 'w+')
  f_line  = File.new('./tmp/RGeoLines.wkt', 'w+')
  f_poly  = File.new('./tmp/RGeoPolygons.wkt', 'w+')

  col_header = "id:wkt:name\n"

  f_point.write(col_header)
  f_line.write(col_header)
  f_poly.write(col_header)

  ALL_WKT_NAMES.each_with_index do |it, index|
    wkt  = it[0].as_text
    name = it[1]
    case it[0].geometry_type.type_name
      when 'Point'
        f_type = f_point
      when 'MultiPoint'
        # MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0)
        f_type = $stdout
      when /^Line[S]*/ #when 'Line' or 'LineString'
        f_type = f_line
      when 'MultiLineString'
        # MULTILINESTRING ((-20.0 -1.0 0.0, -26.0 -6.0 0.0), (-21.0 -4.0 0.0, -31.0 -4.0 0.0))
        f_type = $stdout
      when 'Polygon'
        f_type = f_poly
      when 'MultiPolygon'
        # MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0))
        f_type = $stdout
      when 'GeometryCollection'
        # GEOMETRYCOLLECTION (POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), POLYGON ((5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0)), POLYGON ((-11.0 -1.0 0.0, -11.0 -5.0 0.0, -7.0 -5.0 0.0, -7.0 -1.0 0.0, -11.0 -1.0 0.0)), POLYGON ((-3.0 -9.0 0.0, -3.0 -1.0 0.0, -7.0 -1.0 0.0, -7.0 -9.0 0.0, -3.0 -9.0 0.0)), POLYGON ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))
        f_type = $stdout
      else
        f_type = $stdout
      # ignore it for now
    end
    f_type.write("#{index}:#{wkt}: #{name}\n")
  end

  f_point.close
  f_line.close
  f_poly.close
end

def generate_political_areas_with_collecting_events
  #
  # 4 by 4 matrix of squares:
=begin

Q, R, and S are level 0 spaces, i.e., 'Country'.
M3 through P4, T and U are level 1 spaces, i.e., 'State (Province)'.
M1 through P2 are level 2 spaces, i.e., 'County (Parish)'.

M1-upper_left is at (33, 28).
  
|------|------|------|------| |------|------|------|------|
|      |      |      |      | |      |      |      |      |
|  M1  |  N1  |  O1  |  P1  | | QTM1 | QTN1 | QUO1 | QUP1 |
|      |      |      |      | |      |      |      |      |
|------|------|------|------| |------|------|------|------|
|      |      |      |      | |      |      |      |      |
|  M2  |  N2  |  O2  |  P2  | | QTM2 | QTN2 | QUO2 | QUP2 |
|      |      |      |      | |      |      |      |      |
|------|------|------|------| |------|------|------|------|
|      |      |      |      | |      |      |      |      |
|  M3  |  N3  |  O3  |  P3  | | RM3  | RN3  | SO3  | SP3  |
|      |      |      |      | |      |      |      |      |
|------|------|------|------| |------|------|------|------|
|      |      |      |      | |      |      |      |      |
|  M4  |  N4  |  O4  |  P4  | | RM4  | RN4  | SO4  | SP4  |
|      |      |      |      | |      |      |      |      |
|------|------|------|------| |------|------|------|------|

Big Boxia overlays Q,
Great Northern Land Mass overlays Q, R, and S.

|------|------|------|------| |------|------|------|------|
|                           | |                           |
|                           | |                           |
|                           | |                           |
|       Q, aka Big Boxia    | |                           |
|                           | |                           |
|                           | |                           |
|                           | |                           |
|------|------|------|------| | Great Northern Land Mass  |
|             |             | |                           |
|             |             | |                           |
|             |             | |                           |
|      R      |      S      | |                           |
|             |             | |                           |
|             |             | |                           |
|             |             | |                           |
|------|------|------|------| |------|------|------|------|

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

  prepare_test

  gat_country   = GeographicAreaType.find_or_create_by(name: 'Country')
  gat_state     = GeographicAreaType.find_or_create_by(name: 'State')
  gat_county    = GeographicAreaType.find_or_create_by(name: 'County')
  gat_province  = GeographicAreaType.find_or_create_by(name: 'Province')
  gat_parish    = GeographicAreaType.find_or_create_by(name: 'Parish')
  gat_land_mass = GeographicAreaType.find_or_create_by(name: 'Land Mass')

  shape_m1 = make_box(POINT_M1_P0, 0, 0, 1, 1)
  shape_n1 = make_box(POINT_M1_P0, 1, 0, 1, 1)
  shape_o1 = make_box(POINT_M1_P0, 2, 0, 1, 1)
  shape_p1 = make_box(POINT_M1_P0, 3, 0, 1, 1)

  shape_m2 = make_box(POINT_M1_P0, 0, 1, 1, 1)
  shape_n2 = make_box(POINT_M1_P0, 1, 1, 1, 1)
  shape_o2 = make_box(POINT_M1_P0, 2, 1, 1, 1)
  shape_p2 = make_box(POINT_M1_P0, 3, 1, 1, 1)

  shape_m3 = make_box(POINT_M1_P0, 0, 2, 1, 1)
  shape_n3 = make_box(POINT_M1_P0, 1, 2, 1, 1)
  shape_o3 = make_box(POINT_M1_P0, 2, 2, 1, 1)
  shape_p3 = make_box(POINT_M1_P0, 3, 2, 1, 1)

  shape_m4 = make_box(POINT_M1_P0, 0, 3, 1, 1)
  shape_n4 = make_box(POINT_M1_P0, 1, 3, 1, 1)
  shape_o4 = make_box(POINT_M1_P0, 2, 3, 1, 1)
  shape_p4 = make_box(POINT_M1_P0, 3, 3, 1, 1)

  shape_q   = make_box(shape_m1[0].exterior_ring.points[0], 0, 0, 4, 2)
  shape_t_1 = make_box(shape_m1[0].exterior_ring.points[0], 0, 0, 2, 2)
  shape_t_2 = make_box(shape_m1[0].exterior_ring.points[0], 0, 0, 2, 2)
  shape_u   = make_box(shape_o1[0].exterior_ring.points[0], 0, 0, 2, 2)

  shape_r = make_box(shape_m3[0].exterior_ring.points[0], 0, 0, 2, 2)
  shape_s = make_box(shape_o3[0].exterior_ring.points[0], 0, 0, 2, 2)

  shape_ob   = make_box(POINT_M1_P0, 0, 0, 2, 4)
  shape_eb_1 = make_box(POINT_M1_P0, 3, 0, 1, 4)
  shape_eb_2 = make_box(POINT_M1_P0, 2, 0, 2, 2)
  shape_wb   = make_box(POINT_M1_P0, 0, 0, 1, 4)
  shape_w    = make_box(POINT_M1_P0, 0, 0, 4, 4)

  # first, the basic 16 shapes
  @item_m1   = FactoryGirl.create(:geographic_item, :multi_polygon => shape_m1)
  @item_n1   = FactoryGirl.create(:geographic_item, :multi_polygon => shape_n1)
  @item_o1   = FactoryGirl.create(:geographic_item, :multi_polygon => shape_o1)
  @item_p1   = FactoryGirl.create(:geographic_item, :multi_polygon => shape_p1)

  @item_m2 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_m2)
  @item_n2 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_n2)
  @item_o2 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_o2)
  @item_p2 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_p2)

  @item_m3 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_m3)
  @item_n3 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_n3)
  @item_o3 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_o3)
  @item_p3 = FactoryGirl.create(:geographic_item, :multi_polygon => shape_p3)

  @item_m4        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_m4)
  @item_n4        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_n4)
  @item_o4        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_o4)
  @item_p4        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_p4)

  # next, the big shape, and two sub-shapes
  @item_q         = FactoryGirl.create(:geographic_item, :multi_polygon => shape_q)
  @item_t_1       = FactoryGirl.create(:geographic_item, :multi_polygon => shape_t_1)
  @item_t_2       = FactoryGirl.create(:geographic_item, :multi_polygon => shape_t_2)
  @item_u         = FactoryGirl.create(:geographic_item, :multi_polygon => shape_u)

  # then the medium shapes
  @item_r         = FactoryGirl.create(:geographic_item, :multi_polygon => shape_r)
  @item_s         = FactoryGirl.create(:geographic_item, :multi_polygon => shape_s)

  # secondary country shapes
  # same shape as Q, different object
  @item_bb        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_q)

  # superseded country shapes
  @item_ob        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_ob)
  @item_eb_1      = FactoryGirl.create(:geographic_item, :multi_polygon => shape_eb_1)
  @item_eb_2      = FactoryGirl.create(:geographic_item, :multi_polygon => shape_eb_2)
  @item_wb        = FactoryGirl.create(:geographic_item, :multi_polygon => shape_wb)

  # the entire land mass
  @item_w         = FactoryGirl.create(:geographic_item, :multi_polygon => shape_w)

  # now, for the areas, top-down
  @object         = FactoryGirl.create(:valid_geographic_area_stack)

  # first, level 0 areas
  @earth          = GeographicArea.where(:name => 'Earth').first

  # mimic TDWG North America
  @area_land_mass = FactoryGirl.build(:level0_geographic_area,
                                      :name                 => 'Great Northern Land Mass',
                                      :geographic_area_type => gat_land_mass,
                                      :iso_3166_a3          => nil,
                                      :iso_3166_a2          => nil,
                                      :parent               => @earth)
  @area_land_mass.geographic_items << @item_w
  @area_land_mass.save

  @area_old_boxia = FactoryGirl.build(:level0_geographic_area,
                                      :name                 => 'Old Boxia',
                                      :geographic_area_type => gat_country,
                                      :iso_3166_a3          => nil,
                                      :iso_3166_a2          => nil,
                                      :parent               => @area_land_mass)
  @area_old_boxia.geographic_items << @item_ob
  @area_old_boxia.save
  @area_big_boxia = FactoryGirl.build(:level0_geographic_area,
                                      :name                 => 'Big Boxia',
                                      :geographic_area_type => gat_country,
                                      :iso_3166_a3          => nil,
                                      :iso_3166_a2          => nil,
                                      :parent               => @area_land_mass)
  @area_big_boxia.geographic_items << @item_bb
  @area_big_boxia.save
  @area_q = FactoryGirl.build(:level0_geographic_area,
                              :name                 => 'Q',
                              :geographic_area_type => gat_country,
                              :iso_3166_a3          => 'QQQ',
                              :iso_3166_a2          => 'QQ',
                              :parent               => @area_land_mass)
  @area_q.geographic_items << @item_q
  @area_q.save
  @area_east_boxia_1 = FactoryGirl.build(:level0_geographic_area,
                                         :name                 => 'East Boxia',
                                         :geographic_area_type => gat_country,
                                         :iso_3166_a3          => 'EB1',
                                         :iso_3166_a2          => nil,
                                         :parent               => @area_land_mass)
  @area_east_boxia_1.geographic_items << @item_eb_1
  @area_east_boxia_1.save
  @area_east_boxia_2 = FactoryGirl.build(:level0_geographic_area,
                                         :name                 => 'East Boxia',
                                         :geographic_area_type => gat_country,
                                         :iso_3166_a3          => 'EB2',
                                         :iso_3166_a2          => nil,
                                         :parent               => @area_land_mass)
  @area_east_boxia_2.geographic_items << @item_eb_2
  @area_east_boxia_2.save
  @area_east_boxia_3 = FactoryGirl.build(:level1_geographic_area,
                                         :name                 => 'East Boxia',
                                         :geographic_area_type => gat_state,
                                         :iso_3166_a3          => 'EB3',
                                         :iso_3166_a2          => nil,
                                         :parent               => @area_old_boxia)
  @area_east_boxia_3.geographic_items << @item_eb_2
  @area_east_boxia_3.save
  @area_west_boxia_1 = FactoryGirl.build(:level0_geographic_area,
                                         :name                 => 'West Boxia',
                                         :geographic_area_type => gat_country,
                                         :iso_3166_a3          => 'WB1',
                                         :iso_3166_a2          => nil,
                                         :parent               => @area_land_mass)
  @area_west_boxia_1.geographic_items << @item_wb
  @area_west_boxia_1.save
  @area_west_boxia_3 = FactoryGirl.build(:level1_geographic_area,
                                         :name                 => 'West Boxia',
                                         :geographic_area_type => gat_state,
                                         :iso_3166_a3          => 'WB3',
                                         :iso_3166_a2          => nil,
                                         :parent               => @area_old_boxia)
  @area_west_boxia_3.geographic_items << @item_wb
  @area_west_boxia_3.save
  @area_r = FactoryGirl.build(:level0_geographic_area,
                              :name                 => 'R',
                              :geographic_area_type => gat_country,
                              :iso_3166_a3          => 'RRR',
                              :iso_3166_a2          => 'RR',
                              :parent               => @area_land_mass)
  @area_r.geographic_items << @item_r
  @area_r.save
  @area_s = FactoryGirl.build(:level0_geographic_area,
                              :name                 => 'S',
                              :geographic_area_type => gat_country,
                              :iso_3166_a3          => 'SSS',
                              :iso_3166_a2          => 'SS',
                              :parent               => @area_land_mass)
  @area_s.geographic_items << @item_s
  @area_s.save

  # next, level 1 areas
  @area_t_1 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'T',
                                :tdwgID               => '10TTT',
                                :geographic_area_type => gat_state,
                                :parent               => @area_q)
  @area_t_1.geographic_items << @item_t_1
  @area_t_1.save
  @area_t_2 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'T',
                                :tdwgID               => '20TTT',
                                :geographic_area_type => gat_state,
                                :parent               => @area_q)
  @area_t_2.geographic_items << @item_t_2
  @area_t_2.save
  @area_u = FactoryGirl.build(:level1_geographic_area,
                              :name                 => 'U',
                              :tdwgID               => nil,
                              :geographic_area_type => gat_state,
                              :parent               => @area_q)
  @area_u.geographic_items << @item_u
  @area_u.save

  @area_qtm1 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QTM1',
                                 :geographic_area_type => gat_county,
                                 :parent               => @area_t_1)
  @area_qtm1.geographic_items << @item_m1
  @area_qtm1.save

  @area_qtm2 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QTM2',
                                 :geographic_area_type => gat_county,
                                 :parent               => @area_t_1)
  @area_qtm2.geographic_items << @item_m1
  @area_qtm2.save

  @area_qtn1 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QTN1',
                                 :geographic_area_type => gat_county,
                                 :parent               => @area_t_1)
  @area_qtn1.geographic_items << @item_n1
  @area_qtn1.save

  @area_qtn2_1 = FactoryGirl.build(:level2_geographic_area,
                                   :name                 => 'QTN2',
                                   :geographic_area_type => gat_county,
                                   :parent               => @area_t_1)
  @area_qtn2_1.geographic_items << @item_n2
  @area_qtn2_1.save

  @area_qtn2_2 = FactoryGirl.build(:level2_geographic_area,
                                   :name                 => 'QTN2',
                                   :geographic_area_type => gat_county,
                                   :parent               => @area_t_1)
  @area_qtn2_2.geographic_items << @item_n2
  @area_qtn2_2.save

  @area_quo1 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QUO1',
                                 :geographic_area_type => gat_parish,
                                 :parent               => @area_u)
  # @area_quo1.geographic_items << @item_o1
  # @area_quo1.save

  @area_quo2 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QUO2',
                                 :geographic_area_type => gat_parish,
                                 :parent               => @area_u)
  @area_quo2.geographic_items << @item_o2
  @area_quo2.save

  @area_qup1 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QUP1',
                                 :tdwgID               => nil,
                                 :geographic_area_type => gat_parish,
                                 :parent               => @area_u)
  @area_qup1.geographic_items << @item_p1
  @area_qup1.save

  @area_qup2 = FactoryGirl.build(:level2_geographic_area,
                                 :name                 => 'QUP2',
                                 :tdwgID               => nil,
                                 :geographic_area_type => gat_parish,
                                 :parent               => @area_u)
  @area_qup2.geographic_items << @item_p2
  @area_qup2.save

  @area_rm3 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'RM3',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_province,
                                :parent               => @area_r)
  @area_rm3.geographic_items << @item_m3
  @area_rm3.save

  @area_rm4 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'RM4',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_province,
                                :parent               => @area_r)
  @area_rm4.geographic_items << @item_m4
  @area_rm4.save

  @area_rn3 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'RN3',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_province,
                                :parent               => @area_r)
  @area_rn3.geographic_items << @item_n3
  @area_rn3.save

  @area_rn4 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'RN4',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_province,
                                :parent               => @area_r)
  @area_rn4.geographic_items << @item_n4
  @area_rn4.save

  @area_so3 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'SO3',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_state,
                                :parent               => @area_s)
  @area_so3.geographic_items << @item_o3
  @area_so3.save

  @area_so4 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'SO4',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_state,
                                :parent               => @area_s)
  # @area_so4.geographic_items << @item_o4
  # @area_so4.save

  @area_sp3 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'SP3',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_state,
                                :parent               => @area_s)
  @area_sp3.geographic_items << @item_p3
  @area_sp3.save

  @area_sp4 = FactoryGirl.build(:level1_geographic_area,
                                :name                 => 'SP4',
                                :tdwgID               => nil,
                                :geographic_area_type => gat_state,
                                :parent               => @area_s)
  @area_sp4.geographic_items << @item_p4
  @area_sp4.save

  @area_m3 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'M3',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_province,
                               :parent               => @area_r)
  @area_m3.geographic_items << @item_m3
  @area_m3.save
  @area_n3 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'N3',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_province,
                               :parent               => @area_r)
  @area_n3.geographic_items << @item_n3
  @area_n3.save
  @area_m4 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'M4',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_province,
                               :parent               => @area_r)
  @area_m4.geographic_items << @item_m4
  @area_m4.save
  @area_n4 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'N4',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_province,
                               :parent               => @area_r)
  @area_n4.geographic_items << @item_n4
  @area_n4.save

  @area_o3 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'O3',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_state,
                               :parent               => @area_s)
  @area_o3.geographic_items << @item_o3
  @area_o3.save
  @area_p3 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'P3',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_state,
                               :parent               => @area_s)
  @area_p3.geographic_items << @item_p3
  @area_p3.save
  @area_o4 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'O4',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_state,
                               :parent               => @area_s)
  @area_o4.geographic_items << @item_o4
  @area_o4.save
  @area_p4 = FactoryGirl.build(:level1_geographic_area,
                               :name                 => 'P4',
                               :tdwgID               => nil,
                               :geographic_area_type => gat_state,
                               :parent               => @area_s)
  @area_p4.geographic_items << @item_p4
  @area_p4.save

  # last, for level2
  @area_m1        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'M1',
                                      :geographic_area_type => gat_county,
                                      :parent               => @area_t_1)
  @area_m1.level0 = @area_t_1
  @area_m1.geographic_items << @item_m1
  @area_m1.save
  @area_n1        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'N1',
                                      :geographic_area_type => gat_county,
                                      :parent               => @area_t_1)
  @area_n1.level0 = @area_t_1
  @area_n1.geographic_items << @item_n1
  @area_n1.save
  @area_m2        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'M2',
                                      :geographic_area_type => gat_county,
                                      :parent               => @area_t_1)
  @area_m2.level0 = @area_t_1
  @area_m2.geographic_items << @item_m2
  @area_m2.save
  @area_n2        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'N2',
                                      :geographic_area_type => gat_county,
                                      :parent               => @area_t_1)
  @area_n2.level0 = @area_t_1
  @area_n2.geographic_items << @item_n2
  @area_n2.save

  @area_o1        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'O1',
                                      :geographic_area_type => gat_parish,
                                      :parent               => @area_u)
  @area_o1.level0 = @area_u
  @area_o1.geographic_items << @item_o1
  @area_o1.save
  @area_p1        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'P1',
                                      :geographic_area_type => gat_parish,
                                      :parent               => @area_u)
  @area_p1.level0 = @area_u
  @area_p1.geographic_items << @item_p1
  @area_p1.save
  @area_o2        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'O2',
                                      :geographic_area_type => gat_parish,
                                      :parent               => @area_u)
  @area_o2.level0 = @area_u
  @area_o2.geographic_items << @item_o2
  @area_o2.save
  @area_p2        = FactoryGirl.build(:level2_geographic_area,
                                      :name                 => 'P2',
                                      :geographic_area_type => gat_parish,
                                      :parent               => @area_u)
  @area_p2.level0 = @area_u
  @area_p2.geographic_items << @item_p2
  @area_p2.save

  # now to build the CollectingEvents
  # 16 collecting events, one for each of the smallest boxes

  @ce_m1 = FactoryGirl.create(:collecting_event,
                              :verbatim_locality => 'Lesser Boxia Lake',
                              :verbatim_label    => '@ce_m1',
                              :geographic_area   => @area_m1)
  @gr_m1 = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr_m1',
                              :collecting_event      => @ce_m1,
                              :error_geographic_item => @item_m1,
                              :geographic_item       => GeographicItem.new(:point => @item_m1.st_centroid))
  @ce_n1 = FactoryGirl.create(:collecting_event,
                              :verbatim_label  => '@ce_n1',
                              :geographic_area => @area_n1)
  # @gr_n1 = FactoryGirl.create(:georeference_verbatim_data,
  #                             :api_request           => 'gr_n1',
  #                             :collecting_event      => @ce_n1,
  #                             :error_geographic_item => @item_n1,
  #                             :geographic_item       => GeographicItem.new(:point => @item_n1.st_centroid))
  @ce_o1 = FactoryGirl.create(:collecting_event,
                              :verbatim_label  => '@ce_o1',
                              :geographic_area => @area_o1)
  @gr_o1 = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr_o1',
                              :collecting_event      => @ce_o1,
                              :error_geographic_item => @item_o1,
                              :geographic_item       => GeographicItem.new(:point => @item_o1.st_centroid))
  @ce_p1 = FactoryGirl.create(:collecting_event,
                              :verbatim_label  => '@ce_p1',
                              :geographic_area => @area_p1)
  @gr_p1 = FactoryGirl.create(:georeference_verbatim_data,
                              :api_request           => 'gr_p1',
                              :collecting_event      => @ce_p1,
                              :error_geographic_item => @item_p1,
                              :geographic_item       => GeographicItem.new(:point => @item_p1.st_centroid))

  @ce_m2   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_m2 in Big Boxia',
                                :geographic_area => @area_big_boxia)
  @gr_m2   = FactoryGirl.create(:georeference_verbatim_data,
                                :api_request           => 'gr_m2 in Big Boxia',
                                :collecting_event      => @ce_m2,
                                :error_geographic_item => @item_m2,
                                :geographic_item       => GeographicItem.new(:point => @item_m2.st_centroid))
  # @ce_n2 has two GRs
  @ce_n2   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_n2',
                                :geographic_area => @area_n2)
  @gr_n2_a = FactoryGirl.create(:georeference_verbatim_data,
                                :api_request           => 'gr_n2_a',
                                :collecting_event      => @ce_n2,
                                :error_geographic_item => @item_n2,
                                :geographic_item       => GeographicItem.new(:point => @item_n2.st_centroid))
  @gr_n2_b = FactoryGirl.create(:georeference_verbatim_data,
                                :api_request           => 'gr_n2_b',
                                :collecting_event      => @ce_n2,
                                :error_geographic_item => @item_n2,
                                :geographic_item       => @gr_n2_a.geographic_item)
  @ce_o2   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_o2',
                                :geographic_area => @area_o2)
  @gr_o2   = FactoryGirl.create(:georeference_verbatim_data,
                                :api_request           => 'gr_o2',
                                :collecting_event      => @ce_o2,
                                :error_geographic_item => @item_o2,
                                :geographic_item       => GeographicItem.new(:point => @item_o2.st_centroid))
  @ce_p2   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_p2',
                                :geographic_area => @area_p2)
  # @gr_p2   = FactoryGirl.create(:georeference_verbatim_data,
  #                               :api_request           => 'gr_p2',
  #                               :collecting_event      => @ce_p2,
  #                               :error_geographic_item => @item_p2,
  #                               :geographic_item       => GeographicItem.new(:point => @item_p2.st_centroid))

  @ce_m3   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_m3',
                                :geographic_area => @area_m3)
  @gr_m3   = FactoryGirl.create(:georeference_verbatim_data,
                                :api_request           => 'gr_m3',
                                :collecting_event      => @ce_m3,
                                :error_geographic_item => @item_m3,
                                :geographic_item       => GeographicItem.new(:point => @item_m3.st_centroid))
  @ce_n3   = FactoryGirl.create(:collecting_event,
                                :verbatim_locality => 'Greater Boxia Lake',
                                :verbatim_label    => '@ce_n3',
                                :geographic_area   => @area_n3)
  @gr_n3   = FactoryGirl.create(:georeference_verbatim_data,
                                :api_request           => 'gr_n3',
                                :collecting_event      => @ce_n3,
                                :error_geographic_item => @item_n3,
                                :geographic_item       => GeographicItem.new(:point => @item_n3.st_centroid))
  # @ce_o3 has no georeference
  @ce_o3   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_o3',
                                :geographic_area => @area_o3)
  # @ce_p3 has no georeference
  @ce_p3   = FactoryGirl.create(:collecting_event,
                                :verbatim_label  => '@ce_p3',
                                :geographic_area => @area_s)

  @ce_m4          = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_m4',
                                       :geographic_area => @area_m4)
  @gr_m4          = FactoryGirl.create(:georeference_verbatim_data,
                                       :api_request           => 'gr_m4',
                                       :collecting_event      => @ce_m4,
                                       :error_geographic_item => @item_m4,
                                       :geographic_item       => GeographicItem.new(:point => @item_m4.st_centroid))
  @ce_n4          = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_n4',
                                       :geographic_area => @area_old_boxia)
  @gr_n4          = FactoryGirl.create(:georeference_verbatim_data,
                                       :api_request           => 'gr_n4',
                                       :collecting_event      => @ce_n4,
                                       :error_geographic_item => @item_n4,
                                       :geographic_item       => GeographicItem.new(:point => @item_n4.st_centroid))
  @ce_o4          = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_o4',
                                       :geographic_area => @area_o4)
  @gr_o4          = FactoryGirl.create(:georeference_verbatim_data,
                                       :api_request           => 'gr_o4',
                                       :collecting_event      => @ce_o4,
                                       :error_geographic_item => @item_o4,
                                       :geographic_item       => GeographicItem.new(:point => @item_o4.st_centroid))

  # ce_p4 does not have a geographic_area
  @ce_p4          = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_p4',
                                       :geographic_area => @area_p4)
  @gr_p4          = FactoryGirl.create(:georeference_verbatim_data,
                                       :api_request           => 'gr_p4',
                                       :collecting_event      => @ce_p4,
                                       :error_geographic_item => @item_p4,
                                       :geographic_item       => GeographicItem.new(:point => @item_p4.st_centroid))

  # this one is just a collecting event, no georeferences or geographic_area
  @ce_v           = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_v',
                                       :geographic_area => nil)

  # collecting events in superseded country
  @ce_old_boxia_1 = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_old_boxia_1',
                                       :geographic_area => @area_old_boxia)
  @gr_m2_ob       = FactoryGirl.create(:georeference_verbatim_data,
                                       :api_request           => 'gr_m2_ob',
                                       :collecting_event      => @ce_old_boxia_1,
                                       :error_geographic_item => @item_ob,
                                       :geographic_item       => GeographicItem.new(:point => @item_m2.st_centroid))
  @ce_old_boxia_2 = FactoryGirl.create(:collecting_event,
                                       :verbatim_label  => '@ce_old_boxia_2',
                                       :geographic_area => @area_old_boxia)
  @gr_n3_ob       = FactoryGirl.create(:georeference_verbatim_data,
                                       :api_request           => 'gr_n3_ob',
                                       :collecting_event      => @ce_old_boxia_2,
                                       :error_geographic_item => @item_ob,
                                       :geographic_item       => GeographicItem.new(:point => @item_n3.st_centroid))

  my_debug = false

  if my_debug
    political_names = {
      ce_m1:          @ce_m1,
      ce_o1:          @ce_o1,
      ce_p1:          @ce_p1,
      ce_m2:          @ce_m2,
      ce_n2:          @ce_n2,
      ce_o2:          @ce_o2,
      ce_m3:          @ce_m3,
      ce_n3:          @ce_n3,
      ce_m4:          @ce_m4,
      ce_n4:          @ce_n4,
      ce_o4:          @ce_o4,
      ce_p4:          @ce_p4,
      ce_old_boxia_1: @ce_old_boxia_1,
      ce_old_boxia_2: @ce_old_boxia_2
    }
    item_collection = []

    all_file = File.new('./tmp/political_file.json', 'w')
    political_names.collect { |key, value|
      item_collection.push(value.geographic_area.geographic_items.first)
      item_collection.push(value.georeferences.first.geographic_item)
    }
    all_file.write(Gis::GeoJSON.feature_collection(item_collection).to_json)
    all_file.close
  end

end

def make_box(base, offset_x, offset_y, size_x, size_y)
  box = RSPEC_GEO_FACTORY.polygon(
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y),
                                   RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y),
                                   RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y - size_y),
                                   RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y - size_y)])
  )
  RSPEC_GEO_FACTORY.multi_polygon([box])
end

def clean_slate_geo
  GeographicItem.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('geographic_items')
  GeographicAreaType.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('geographic_area_types')
  GeographicArea.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('geographic_areas')
  GeographicAreasGeographicItem.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('geographic_areas_geographic_items')
  Georeference.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('georeferences')
  CollectingEvent.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('collecting_events')
  # $user_id    = 1
  # $project_id = 1
end

# A temporary place to put debugging aids.  This code is permanently deprecated.
module GeoDev
  def point_methods()
    [:x, :y, :z, :m, :geometry_type, :rep_equals?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
  end

  def line_string_methods()
    [:length, :start_point, :end_point, :is_closed?, :is_ring?, :num_points, :point_n, :points, :factory, :z_geometry, :m_geometry, :dimension, :geometry_type, :srid, :envelope, :as_text, :as_binary, :is_empty?, :is_simple?, :boundary, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :union, :difference, :sym_difference, :rep_equals?, :-, :+, :*, :_copy_state_from, :marshal_dump, :marshal_load, :encode_with, :init_with]
  end

  def line_methods()
    [:geometry_type, :length, :num_points, :point_n, :start_point, :end_point, :points, :is_closed?, :is_ring?, :rep_equals?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
  end

  def linear_ring_methods()
    [:to_i, :to_f, :to_a, :to_h, :&, :|, :^, :to_r, :rationalize, :to_c, :encode_json]
  end

  def polygon_methods()
    [:geometry_type, :area, :centroid, :point_on_surface, :exterior_ring, :num_interior_rings, :interior_ring_n, :interior_rings, :rep_equals?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
  end

  def multi_point_methods()
    [:geometry_type, :rep_equals?, :num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
  end

  def multi_line_string_methods()
    [:geometry_type, :length, :is_closed?, :rep_equals?, :num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
  end

  def multi_polygon_methods
    [:geometry_type, :area, :centroid, :point_on_surface, :rep_equals?, :num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :marshal_dump, :marshal_load, :encode_with, :init_with, :factory, :fg_geom, :_klasses, :srid, :dimension, :prepared?, :prepare!, :envelope, :boundary, :as_text, :as_binary, :is_empty?, :is_simple?, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :*, :union, :+, :difference, :-, :sym_difference, :_detach_fg_geom, :_request_prepared]
  end

  def collection_methods()
    [:num_geometries, :size, :geometry_n, :[], :each, :to_a, :entries, :sort, :sort_by, :grep, :count, :find, :detect, :find_index, :find_all, :reject, :collect, :map, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :first, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object, :zip, :take, :take_while, :drop, :drop_while, :cycle, :chunk, :slice_before, :lazy, :to_set, :sum, :index_by, :many?, :exclude?, :factory, :z_geometry, :m_geometry, :dimension, :geometry_type, :srid, :envelope, :as_text, :as_binary, :is_empty?, :is_simple?, :boundary, :equals?, :disjoint?, :intersects?, :touches?, :crosses?, :within?, :contains?, :overlaps?, :relate?, :relate, :distance, :buffer, :convex_hull, :intersection, :union, :difference, :sym_difference, :rep_equals?, :-, :+, :*, :_copy_state_from, :marshal_dump, :marshal_load, :encode_with, :init_with]
  end

end
