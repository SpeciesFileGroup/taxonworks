RSPEC_GEO_FACTORY = Gis::FACTORY
shared_context 'stuff for complex geo tests' do
  before {
    # @user exists as a result of `sign_in_and _select_project` (i.e., a feature test), othewise nil
    if @user
      @ret_val = simple_world(@user.id, @project.id)
    else
      @ret_val = simple_world
    end
  }
  # need user and project
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  # need some people
  let(:sargon) { Person.where(first_name: 'of Akkad', last_name: 'Sargon').first }
  let(:andy) { Person.where(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author').first }
  let(:daryl) { Person.where(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon').first }
  let(:ted) { Person.where(last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC').first }
  let(:bill) { Person.where(first_name: 'Bill', last_name: 'Ardson').first }

  # need some otus
  let(:top_dog) { Otu.where(name: 'Top Dog').first }
  let(:nuther_dog) { Otu.where(name: 'Another Dog').first }
  let(:spooler) { Otu.where('name like ?', '%spooler%').first }
  let(:p4) { Otu.where(name: 'P4').first }
  let(:by_bill) { Otu.where('name like ?', '%by Bill%').first }
  let(:otu_a) { Otu.where(name: 'Otu_A').first }
  let(:abra) { Otu.where(name: 'Abra').first }
  let(:cadabra) { Otu.where('name like ?', '%cadabra%').first }
  let(:alakazam) { Otu.where('name like ?', '%alakazam%').first }

  # need some areas
  let(:area_a) { GeographicArea.where(name: 'A').first }
  let(:area_b) { GeographicArea.where(name: 'B').first }
  let(:area_e) { GeographicArea.where(name: 'E').first }
  let(:json_string) { '{"type":"Feature", "properties":{}, "geometry":{"type":"MultiPolygon", ' \
                              '"coordinates":[[[[0, 10, 0], [10, 10, 0], [10, -10, 0], [0, -10, 0], [0, 10, 0]]]]}}' }

  # need some collection objects
  let(:ce_a) { CollectingEvent.where(verbatim_label: 'Eh?').first }
  let(:co_a) {
    object = ce_a
    object.collection_objects.first
  }

  let(:ce_b) { CollectingEvent.where(verbatim_label: 'Bah').first }
  let(:co_b) {
    object = ce_b
    object.collection_objects.first
  }

  # rubocop:disable Metrics/MethodLength
  def simple_world(user_id = 1, project_id = 1)
    ret_val      = {}
    temp_user    = $user_id
    temp_project = $project_id

    $user_id    = user_id
    $project_id = project_id

    user    = User.find($user_id)
    joe     = user
    project = Project.find($project_id)

    planet_gat             = GeographicAreaType.create!(name: 'Planet')
    gat_parish             = GeographicAreaType.create!(name: 'Parish')
    gat_land_mass          = GeographicAreaType.create!(name: 'Land Mass')
    list_shape_a           = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                                            RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                                            RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                                            RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                                            RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
    ret_val[:list_shape_a] = list_shape_a

    list_shape_b = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                                  RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                                  RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                                  RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                                  RSPEC_GEO_FACTORY.point(0, 0, 0.0)])

    list_shape_e = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                                  RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                                  RSPEC_GEO_FACTORY.point(10, -10, 0.0),
                                                  RSPEC_GEO_FACTORY.point(0, -10, 0.0),
                                                  RSPEC_GEO_FACTORY.point(0, 10, 0.0)])

    shape_a           = RSPEC_GEO_FACTORY.polygon(list_shape_a)
    ret_val[:shape_a] = shape_a
    shape_b           = RSPEC_GEO_FACTORY.polygon(list_shape_b)
    shape_e           = RSPEC_GEO_FACTORY.polygon(list_shape_e)

    item_a = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_a]))
    item_b = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_b]))
    item_e = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_e]))

    earth = FactoryBot.create(:earth_geographic_area,
                              geographic_area_type: planet_gat)

    area_e = FactoryBot.create(:level0_geographic_area,
                               name:                 'E',
                               geographic_area_type: gat_land_mass,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               earth)
    area_e.geographic_items << item_e
    area_e.save!

    area_a = FactoryBot.create(:level1_geographic_area,
                               name:                 'A',
                               geographic_area_type: gat_parish,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               area_e)
    area_a.geographic_items << item_a
    shape_a       = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
    line_string_a = FactoryBot.build(:geographic_item_line_string, line_string: shape_a.as_binary)
    area_a.geographic_items << line_string_a
    area_a.save!

    area_b = FactoryBot.create(:level1_geographic_area,
                               name:                 'B',
                               geographic_area_type: gat_parish,
                               iso_3166_a3:          nil,
                               iso_3166_a2:          nil,
                               parent:               area_e)
    area_b.geographic_items << item_b
    list_b2    = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0),
                                                RSPEC_GEO_FACTORY.point(7.5, -2.5, 0.0),
                                                RSPEC_GEO_FACTORY.point(7.5, -7.5, 0.0),
                                                RSPEC_GEO_FACTORY.point(7.5, -7.5, 0.0),
                                                RSPEC_GEO_FACTORY.point(2.5, -2.5, 0.0)])
    poly_b     = RSPEC_GEO_FACTORY.polygon(list_shape_b, [list_b2])
    are_poly_b = FactoryBot.build(:geographic_item_polygon, polygon: shape_b.as_binary)
    area_b.geographic_items << are_poly_b
    area_b.save!

    ce_a = FactoryBot.create(:collecting_event,
                             start_date_year:   1971,
                             start_date_month:  1,
                             start_date_day:    1,
                             verbatim_locality: 'environs of A',
                             verbatim_label:    'Eh?',
                             geographic_area:   area_a)

    co_a = FactoryBot.create(:valid_collection_object,
                             created_at:       '2000/01/01',
                             updated_at:       '2000/07/01',
                             collecting_event: ce_a)

    gr_a = FactoryBot.create(:georeference_verbatim_data,
                             api_request:           'area_a',
                             collecting_event:      ce_a,
                             error_geographic_item: item_a,
                             geographic_item:       GeographicItem.new(point: item_a.st_centroid))

    ce_b = FactoryBot.create(:collecting_event,
                             start_date_year:   1982,
                             start_date_month:  2,
                             start_date_day:    2,
                             verbatim_locality: 'environs of B',
                             verbatim_label:    'Bah',
                             geographic_area:   area_b,
                             creator:           joe,
                             updater:           user,
                             project:           project)

    co_b = FactoryBot.create(:valid_collection_object,
                             created_at:       '2001/01/01',
                             updated_at:       '2001/07/01',
                             collecting_event: ce_b)

    gr_b = FactoryBot.create(:georeference_verbatim_data,
                             api_request:           'area_b',
                             collecting_event:      ce_b,
                             error_geographic_item: item_b,
                             geographic_item:       GeographicItem.new(point: item_b.st_centroid))

    sargon = Person.create!(first_name: 'of Akkad', last_name: 'Sargon')
    andy   = Person.create!(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author')
    daryl  = Person.create!(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon')
    ted    = FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC')
    bill   = Person.create!(first_name: 'Bill', last_name: 'Ardson')

    top_dog = FactoryBot.create(:valid_otu, name: 'Top Dog', taxon_name:
                                                  FactoryBot.create(:valid_taxon_name,
                                                                    rank_class: Ranks.lookup(:iczn, 'Family'),
                                                                    name:       'Topdogidae')
    )

    nuther_dog = FactoryBot.create(:valid_otu, name: 'Another Dog', taxon_name:
                                                     FactoryBot.create(:valid_taxon_name,
                                                                       rank_class: Ranks.lookup(:iczn, 'Family'),
                                                                       name:       'Nutherdogidae')
    )

    tn_abra = Protonym.create!(name:       'Abra',
                               rank_class: Ranks.lookup(:iczn, 'Genus'),
                               parent:     top_dog.taxon_name)

    tn_spooler = Protonym.create!(name:       'spooler',
                                  rank_class: Ranks.lookup(:iczn, 'Species'),
                                  parent:     tn_abra)

    tn_cadabra  = Protonym.create!(name:                'cadabra',
                                   year_of_publication: 2017,
                                   verbatim_author:     'Bill Ardson',
                                   rank_class:          Ranks.lookup(:iczn, 'Species'),
                                   parent:              tn_abra)
    tn_alakazam = Protonym.create!(name:       'alakazam',
                                   rank_class: Ranks.lookup(:iczn, 'Subspecies'),
                                   parent:     tn_cadabra)

    by_bill = FactoryBot.create(:valid_otu, name: 'Top Dog (by Bill)', taxon_name: top_dog.taxon_name)

    o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'Otu_A')
    o.taxon_name.update_column(:name, 'antivitis')
    co_a.otus << o

    o = top_dog # this is o1
    o.taxon_name.taxon_name_authors << ted
    co_a.otus << o

    o            = by_bill
    o.taxon_name = top_dog.taxon_name
    co_a.otus << o

    o            = FactoryBot.create(:valid_otu, name: 'Abra')
    o.taxon_name = tn_abra
    o.taxon_name.taxon_name_authors << ted
    co_a.otus << o

    o            = FactoryBot.create(:valid_otu, name: 'Abra cadabra')
    t_n          = tn_cadabra
    o.taxon_name = t_n
    o.save!
    o.taxon_name.taxon_name_authors << bill
    co_a.otus << o
    o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam')
    co_a.collecting_event.collectors << bill
    o.taxon_name = tn_alakazam

    o.taxon_name.taxon_name_authors << ted
    co_a.otus << o
    o.taxon_name

    o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P4')
    co_b.collecting_event.collectors << sargon
    co_b.collecting_event.collectors << daryl
    o.taxon_name.update_column(:name, 'beevitis')
    co_b.otus << o
    o            = FactoryBot.create(:valid_otu, name: 'Sargon\'s spooler')
    o.taxon_name = tn_spooler
    o.taxon_name.taxon_name_authors << sargon
    o.taxon_name.taxon_name_authors << daryl
    co_b.otus << o
    o = nuther_dog
    o.taxon_name.taxon_name_authors << bill
    o.taxon_name.taxon_name_authors << ted
    o.taxon_name.taxon_name_authors << sargon
    co_b.otus << o

    $user_id    = temp_user
    $project_id = temp_project

    ret_val
  end
  # rubocop:enable Metrics/MethodLength
end
