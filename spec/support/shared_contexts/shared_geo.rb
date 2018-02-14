# require 'support/shared_contexts/geo/area_a'

RSPEC_GEO_FACTORY = Gis::FACTORY
shared_context 'stuff for complex geo tests' do

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

  let(:country_gat) { GeographicAreaType.create!(name: 'Country', creator: geo_user, updater: geo_user) }
  let(:state_gat) { GeographicAreaType.create!(name: 'State', creator: geo_user, updater: geo_user) }
  let(:province_gat) { GeographicAreaType.create!(name: 'Province', creator: geo_user, updater: geo_user) }
  let(:county_gat) { GeographicAreaType.create!(name: 'County', creator: geo_user, updater: geo_user) }
  let(:parish_gat) { GeographicAreaType.create!(name: 'Parish', creator: geo_user, updater: geo_user) }
  let(:planet_gat) { GeographicAreaType.create!(name: 'Planet', creator: geo_user, updater: geo_user) }
  let(:land_mass_gat) { GeographicAreaType.create!(name: 'Land Mass', creator: geo_user, updater: geo_user) }

# include_context 'stuff for area_a'

  let(:list_shape_a) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  }

  let(:list_shape_b) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  }

  let(:list_shape_c) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 0, 0.0)])
  }

  let(:list_shape_d) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 10, 0.0)])
  }

  let(:list_shape_e) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0)])
  }

  let(:list_shape_f) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 10, 0.0)])
  }

  let(:list_shape_l2) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(-10, 10, 0.0)])
  }

  let(:list_shape_r2) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0)])
  }

  let(:shape_a) { RSPEC_GEO_FACTORY.polygon(list_shape_a) }
  let(:shape_b) { RSPEC_GEO_FACTORY.polygon(list_shape_b) }
  let(:shape_c) { RSPEC_GEO_FACTORY.polygon(list_shape_c) }
  let(:shape_d) { RSPEC_GEO_FACTORY.polygon(list_shape_d) }
  let(:shape_e) { RSPEC_GEO_FACTORY.polygon(list_shape_e) }
  let(:shape_f) { RSPEC_GEO_FACTORY.polygon(list_shape_f) }
  let(:shape_l2) { RSPEC_GEO_FACTORY.polygon(list_shape_l2) }
  let(:shape_r2) { RSPEC_GEO_FACTORY.polygon(list_shape_r2) }

  let(:new_box_a) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_a]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_b) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_b]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_c) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_c]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_d) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_d]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_e) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_e]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_l) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_l]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_f) { FactoryBot.create(:geographic_item_multi_polygon,
                                      multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_f]),
                                      creator:       geo_user,
                                      updater:       geo_user) }
  let(:new_box_l2) { FactoryBot.create(:geographic_item_multi_polygon,
                                       multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_l2]),
                                       creator:       geo_user,
                                       updater:       geo_user) }
  let(:new_box_r2) { FactoryBot.create(:geographic_item_multi_polygon,
                                       multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_r2]),
                                       creator:       geo_user,
                                       updater:       geo_user) }

  let(:earth) { FactoryBot.create(:earth_geographic_area,
                                  geographic_area_type: planet_gat,
                                  creator:              geo_user,
                                  updater:              geo_user) }

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
    let(:multilinestring) { RSPEC_GEO_FACTORY.multi_line_string([list_shape_a, list_shape_b]) }
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

# need some collecting events
  let(:ce_area_v) { FactoryBot.create(:collecting_event,
                                      verbatim_label: 'ce_area_v collecting event test') }

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
    # ce.reload
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
    # ce.save!
    # ce.reload
    ce
  }

  let(:ce_p4) { FactoryBot.create(:collecting_event,
                                  start_date_year:  1988,
                                  start_date_month: 8,
                                  start_date_day:   8,
                                  verbatim_label:   '@ce_p4',
                                  geographic_area:  nil) }
  let(:gr_p4) { FactoryBot.create(:georeference_verbatim_data,
                                  api_request:           'gr_p4',
                                  collecting_event:      ce_p4,
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

  begin # for GeographicItem interaction
    let(:all_items) { FactoryBot.create(:geographic_item_geometry_collection,
                                        geometry_collection: GeoBuild::ALL_SHAPES.as_binary) } # 54
    let(:outer_limits) { FactoryBot.create(:geographic_item_line_string,
                                           line_string: GeoBuild::CONVEX_HULL.exterior_ring.as_binary) } # 55

    let(:p0) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT0.as_binary) } # 0
    let(:p1) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT1.as_binary) }
    let(:p2) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT2.as_binary) } # 2
    let(:p3) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT3.as_binary) } # 3
    let(:p4) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT4.as_binary) } # 3
    let(:p10) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT10.as_binary) } # 10 } #
    let(:p11) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT11.as_binary) } # 11 } #
    let(:p12) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT12.as_binary) } # 10 } #
    let(:p13) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT13.as_binary) } # 10 } #
    let(:p14) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT14.as_binary) } # 14 } #
    let(:p16) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT16.as_binary) } # 16 } #
    let(:p17) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT17.as_binary) } # 17
    let(:p18) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT18.as_binary) } # 17
    let(:p19) { FactoryBot.create(:geographic_item_point, point: GeoBuild::POINT19.as_binary) } # 17

    let(:a) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_A.as_binary) } # 24 } #
    let(:b) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_B.as_binary) } # 27
    let(:c1) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_C1) } # 28
    let(:c2) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_C2) } # 28
    let(:c3) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_C3) } # 29
    let(:c) { FactoryBot.create(:geographic_item_multi_line_string,
                                multi_line_string: GeoBuild::SHAPE_C.as_binary) } # 30
    let(:d) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_D.as_binary) }
    let(:b1) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_B_OUTER.as_binary) } # 25
    let(:b2) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_B_INNER.as_binary) } # 26
    let(:e0) { e.geo_object } # a collection of polygons
    let(:e1) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::POLY_E1.as_binary) } # 35
    let(:e2) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::POLY_E2.as_binary) } # 33
    let(:e3) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::POLY_E3.as_binary) } # 34
    let(:e4) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::POLY_E4.as_binary) } # 35
    let(:e5) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::POLY_E5.as_binary) } # 35
    let(:e) { FactoryBot.create(:geographic_item_geometry_collection,
                                geometry_collection: GeoBuild::SHAPE_E.as_binary) } # 37
    let(:f1) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_F1.as_binary) } # 38
    let(:f2) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_F2.as_binary) } # 39
    # let(:f1) { f.geo_object.geometry_n(0) } #
    # let(:f2) { f.geo_object.geometry_n(1) } #
    let(:f) { FactoryBot.create(:geographic_item_multi_line_string,
                                multi_line_string: GeoBuild::SHAPE_F.as_binary) } # 40
    let(:g1) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_G1.as_binary) } # 41
    let(:g2) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_G2.as_binary) } # 42
    let(:g3) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_G3.as_binary) } # 43
    let(:g) { FactoryBot.create(:geographic_item_multi_polygon,
                                multi_polygon: GeoBuild::SHAPE_G.as_binary) } # 44
    let(:h) { FactoryBot.create(:geographic_item_multi_point, multi_point: GeoBuild::SHAPE_H.as_binary) } # 45
    let(:j) { FactoryBot.create(:geographic_item_geometry_collection, geometry_collection: GeoBuild::SHAPE_J) } # 47
    let(:k) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::SHAPE_K.as_binary) }
    let(:l) { FactoryBot.create(:geographic_item_line_string, line_string: GeoBuild::SHAPE_L.as_binary) } # 49 } #

    let(:r2020) { FactoryBot.create(:geographic_item_point, point: GeoBuild::ROOM2020.as_binary) } # 50
    let(:r2022) { FactoryBot.create(:geographic_item_point, point: GeoBuild::ROOM2022.as_binary) } # 51
    let(:r2024) { FactoryBot.create(:geographic_item_point, point: GeoBuild::ROOM2024.as_binary) } # 52
    let(:rooms) { FactoryBot.create(:geographic_item_multi_point, multi_point: GeoBuild::ROOMS20NN.as_binary) } # 53

    let(:shapeE1) { e0.geometry_n(0) } #
    let(:shapeE2) { e0.geometry_n(1) } #
    let(:shapeE3) { e0.geometry_n(2) } #
    let(:shapeE4) { e0.geometry_n(3) } #
    let(:shapeE5) { e0.geometry_n(4) } #

    let(:r) { a.geo_object.intersection(p16.geo_object) } #
    let(:p16_on_a) { GeoBuild::P16_ON_A } #

    let(:item_a) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::BOX_1) } # 57
    let(:item_b) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::BOX_2) } # 58
    let(:item_c) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::BOX_3) } # 59
    let(:item_d) { FactoryBot.create(:geographic_item_polygon, polygon: GeoBuild::BOX_4) } # 60

    let(:ce_p1) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p1 collect_event test') }

    let(:gr01) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr01',
                                   collecting_event:      ce_p1,
                                   error_geographic_item: k,
                                   geographic_item:       p1) } #  3

    let(:gr11) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr11',
                                   error_geographic_item: e1,
                                   collecting_event:      ce_p1,
                                   geographic_item:       p11) } #  4

    let(:ce_p2) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p2 collect_event test') }
    let(:gr02) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr02',
                                   collecting_event:      ce_p2,
                                   error_geographic_item: k,
                                   geographic_item:       p2) }
    let(:gr121) { FactoryBot.create(:georeference_verbatim_data,
                                    api_request:           'gr121',
                                    collecting_event:      ce_p2,
                                    error_geographic_item: e1,
                                    geographic_item:       p12) }

    let(:ce_p3) { FactoryBot.create(:collecting_event, verbatim_label: '@ce_p3 collect_event test') }
    let(:gr03) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr03',
                                   collecting_event:      ce_p3,
                                   error_geographic_item: k,
                                   geographic_item:       p3) }
    let(:gr13) { FactoryBot.create(:georeference_verbatim_data,
                                   api_request:           'gr13',
                                   collecting_event:      ce_p3,
                                   error_geographic_item: e2,
                                   geographic_item:       p13) }

    let(:ce_n1) { FactoryBot.create(:collecting_event,
                                    start_date_year:  1972,
                                    start_date_month: 2,
                                    start_date_day:   2,
                                    verbatim_label:   '@ce_n1',
                                    geographic_area:  area_r2) }

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
      let(:item_r) { FactoryBot.create(:geographic_item, multi_polygon: shape_r) }
      let(:shape_r) { GeoBuild.make_box(shape_m3[0]
                                          .exterior_ring.points[0], 0, 0, 2, 2) }
      let(:shape_m3) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 0, 2, 1, 1) }
      let(:item_n3) { FactoryBot.create(:geographic_item, multi_polygon: shape_n3) }
      let(:shape_n3) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 1, 2, 1, 1) }
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

      let(:shape_p1b) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 3, 0, 1, 1) }
      let(:shape_q) { GeoBuild.make_box(shape_m1[0].exterior_ring.points[0], 0, 0, 4, 2) }
      let(:shape_m1) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 0, 0, 1, 1) }
      let(:shape_ob) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 0, 0, 2, 4) }
      let(:shape_eb_1) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 3, 0, 1, 4) }
      let(:shape_eb_2) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 2, 0, 2, 2) }
      let(:shape_wb) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 0, 0, 1, 4) }
      let(:shape_w) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 0, 0, 4, 4) }
      let(:shape_u) { GeoBuild.make_box(shape_o1[0].exterior_ring.points[0], 0, 0, 2, 2) }
      let(:shape_o1) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 2, 0, 1, 1) }


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
        area }
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
      let(:shape_s) { GeoBuild.make_box(shape_o3[0]
                                          .exterior_ring.points[0], 0, 0, 2, 2) }
      let(:shape_o3) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 2, 2, 1, 1) }
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
      let(:shape_t_1) { GeoBuild.make_box(shape_m1[0]
                                            .exterior_ring.points[0], 0, 0, 2, 2) }
      let(:item_n2) { FactoryBot.create(:geographic_item, multi_polygon: shape_n2) }
      let(:shape_n2) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 1, 1, 1, 1) }
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
      let(:shape_t_2) { GeoBuild.make_box(shape_m1[0].exterior_ring.points[0], 0, 0, 2, 2) }
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
      let(:shape_n4) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 1, 3, 1, 1) }
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
      let(:shape_p2b) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 3, 1, 1, 1) }

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
      let(:shape_m2) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 0, 1, 1, 1) }
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
      let(:shape_n1) { GeoBuild.make_box(GeoBuild::POINT_M1_P0, 1, 0, 1, 1) }

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
        area.level0 = @area_u
        area.geographic_items << item_o2
        area.save!
        area
      }
      let(:item_o2) { FactoryBot.create(:geographic_item, multi_polygon: shape_o2) }
      let(:shape_o2) {GeoBuild. make_box(GeoBuild::POINT_M1_P0, 2, 1, 1, 1) }
    end

    b = FactoryBot.build(:geographic_item_polygon, polygon: GeoBuild::SHAPE_B.as_binary) # 27

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
