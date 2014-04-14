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
  ) As trial  ;
=end

ROOM2020 = RSPEC_GEO_FACTORY.point(-88.241421, 40.091565, 757)
ROOM2022 = RSPEC_GEO_FACTORY.point((ROOM2020.x + ((ROOM2024.x - ROOM2020.x) / 2)),
                                   (ROOM2020.y + ((ROOM2024.y - ROOM2020.y) / 2)),
                                   (ROOM2020.z + ((ROOM2024.z - ROOM2020.z) / 2)))

ROOMS20NN = RSPEC_GEO_FACTORY.multi_point([ROOM2020,
                                           ROOM2022,
                                           ROOM2024])

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
POINT21 = RSPEC_GEO_FACTORY.point(-4, -3)
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
                                           POINT22])

CONVEX_HULL = ALL_SHAPES.convex_hull

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
                 [POINT22, 'P22']]

E1_AND_E2 = RSPEC_GEO_FACTORY.parse_wkt('POLYGON ((-9.0 6.0 0.0, -9.0 2.0 0.0, -14.0 2.0 0.0, -14.0 6.0 0.0, -9.0 6.0 0.0))')
E1_OR_E2  = RSPEC_GEO_FACTORY.parse_wkt('POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0))')
E1_AND_E4 = RSPEC_GEO_FACTORY.parse_wkt('GEOMETRYCOLLECTION EMPTY')
E1_OR_E5  = RSPEC_GEO_FACTORY.parse_wkt('MULTIPOLYGON (((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))')

P16_ON_A = RSPEC_GEO_FACTORY.parse_wkt("POINT (-23.0 18.0 0.0)")

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

def generate_test_objects


  @p0  = GeographicItem.new # 0
  @p1  = GeographicItem.new # 1
  @p2  = GeographicItem.new # 2
  @p3  = GeographicItem.new # 3
  @p4  = GeographicItem.new # 4
  @p5  = GeographicItem.new # 5
  @p6  = GeographicItem.new # 6
  @p7  = GeographicItem.new # 7
  @p8  = GeographicItem.new # 8
  @p9  = GeographicItem.new # 9
  @p10 = GeographicItem.new # 10
  @p11 = GeographicItem.new # 11
  @p12 = GeographicItem.new # 12
  @p13 = GeographicItem.new # 13
  @p14 = GeographicItem.new # 14
  @p15 = GeographicItem.new # 15
  @p16 = GeographicItem.new # 16
  @p17 = GeographicItem.new # 17
  @p18 = GeographicItem.new # 18
  @p19 = GeographicItem.new # 19
  @p20 = GeographicItem.new # 20
  @p21 = GeographicItem.new # 21
  @p22 = GeographicItem.new # 22

  @a  = GeographicItem.new # 23
  @b1 = GeographicItem.new # 24
  @b2 = GeographicItem.new # 25
  @b  = GeographicItem.new # 26
  @c1 = GeographicItem.new # 27
  @c2 = GeographicItem.new # 28
  @c3 = GeographicItem.new # 29
  @c  = GeographicItem.new # 30
  @d  = GeographicItem.new # 31
  @e1 = GeographicItem.new # 32
  @e2 = GeographicItem.new # 33
  @e3 = GeographicItem.new # 34
  @e4 = GeographicItem.new # 35
  @e5 = GeographicItem.new # 36
  @e  = GeographicItem.new # 37
  @f1 = GeographicItem.new # 38
  @f2 = GeographicItem.new # 39
  @f  = GeographicItem.new # 40
  @g1 = GeographicItem.new # 41
  @g2 = GeographicItem.new # 42
  @g3 = GeographicItem.new # 43
  @g  = GeographicItem.new # 44
  @h  = GeographicItem.new # 45
  @i  = GeographicItem.new # 46
  @j  = GeographicItem.new # 47
  @k  = GeographicItem.new # 48
  @l  = GeographicItem.new # 49

  @r2020 = GeographicItem.new # 50
  @r2022 = GeographicItem.new # 51
  @r2024 = GeographicItem.new # 52
  @rooms = GeographicItem.new # 53

  @all_items    = GeographicItem.new # 54
  @outer_limits = GeographicItem.new # 55

  @r2020.point       = ROOM2020.as_binary
  @r2022.point       = ROOM2022.as_binary
  @r2024.point       = ROOM2024.as_binary
  @rooms.multi_point = ROOMS20NN.as_binary

  @p0.point  = POINT0.as_binary
  @p1.point  = POINT1.as_binary
  @p2.point  = POINT2.as_binary
  @p3.point  = POINT3.as_binary
  @p4.point  = POINT4.as_binary
  @p5.point  = POINT5.as_binary
  @p6.point  = POINT6.as_binary
  @p7.point  = POINT7.as_binary
  @p8.point  = POINT8.as_binary
  @p9.point  = POINT9.as_binary
  @p10.point = POINT10.as_binary
  @p11.point = POINT11.as_binary
  @p12.point = POINT12.as_binary
  @p13.point = POINT13.as_binary
  @p14.point = POINT14.as_binary
  @p15.point = POINT15.as_binary
  @p16.point = POINT16.as_binary
  @p17.point = POINT17.as_binary
  @p18.point = POINT18.as_binary
  @p19.point = POINT19.as_binary
  @p20.point = POINT20.as_binary
  @p21.point = POINT21.as_binary
  @p22.point = POINT22.as_binary

  @a.line_string         = SHAPE_A.as_binary
  @b1.polygon            = SHAPE_B_OUTER.as_binary
  @b2.polygon            = SHAPE_B_INNER.as_binary
  @b.polygon             = SHAPE_B.as_binary
  @c1.line_string        =SHAPE_C1
  @c2.line_string        =SHAPE_C2
  @c3.line_string        =SHAPE_C3
  @c.multi_line_string   = SHAPE_C.as_binary
  @d.line_string         = SHAPE_D.as_binary
  @e1.polygon            = POLY_E1.as_binary
  @e2.polygon            = POLY_E2.as_binary
  @e3.polygon            = POLY_E3.as_binary
  @e4.polygon            = POLY_E4.as_binary
  @e5.polygon            = POLY_E5.as_binary
  @e.geometry_collection = SHAPE_E.as_binary
  @f1.line_string        = SHAPE_F1.as_binary
  @f2.line_string        = SHAPE_F2.as_binary
  @f.multi_line_string   = SHAPE_F.as_binary
  @g1.polygon            = SHAPE_G1.as_binary
  @g2.polygon            = SHAPE_G2.as_binary
  @g3.polygon            = SHAPE_G3.as_binary
  @g.multi_polygon       = SHAPE_G.as_binary
  @h.multi_point         = SHAPE_H.as_binary
  @i.line_string         =SHAPE_I
  @j.geometry_collection =SHAPE_J
  @k.polygon             = SHAPE_K.as_binary
  @l.line_string         = SHAPE_L.as_binary

  @all_items.geometry_collection = ALL_SHAPES.as_binary
  @outer_limits.line_string      = CONVEX_HULL.exterior_ring.as_binary

  [@p0, @p1, @p2, @p3, @p4,
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
   @all_items, @outer_limits].map(&:save!)

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
    p22:          @p21.id,

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
    outer_limits: @outer_limits.id
  }

  @debug_names.collect { |k, v| print "       " + v.to_s + ": " + k.to_s }

  puts @debug_names.invert[@p1]

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
