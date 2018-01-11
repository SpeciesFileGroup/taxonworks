require 'rails_helper'
require 'make_simple_world'

describe Queries::OtuFilterQuery, type: :model, group: [:geo, :collection_objects, :otus] do

  context 'with properly built collection of objects' do
    before {
      simple_world
    }
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

    # need some collection objects
    let(:co_a) {
      object = CollectingEvent.where(verbatim_label: 'Eh?').first
      object.collection_objects.first
    }

    context 'area search' do
      context 'named area' do
        let(:params) { {geographic_area_ids: [area_b.id]} }

        specify 'nomen count' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(3)
        end

        specify 'specific nomen' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to contain_exactly(p4, spooler, nuther_dog)
        end
      end

      context 'area shapes' do
        let(:params) { {drawn_area_shape: area_a.to_simple_json_feature} }

        specify 'nomen count' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(6)
        end

        specify 'specific nomen' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to include(top_dog, by_bill, otu_a, abra, cadabra, alakazam)
        end
      end
    end

    context 'nomen search' do
      context 'with descendants' do
        specify 'with rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'}
          result      = Queries::OtuFilterQuery.new(params_with).result
          expect(result).to contain_exactly(spooler, cadabra)
        end

        specify 'with same rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class:  'NomenclaturalRank::Iczn::FamilyGroup::Family'}
          result      = Queries::OtuFilterQuery.new(params_with).result
          expect(result).to contain_exactly(top_dog, by_bill)
        end

        specify 'without rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class: nil}
          result      = Queries::OtuFilterQuery.new(params_with).result
          expect(result).to contain_exactly(spooler, top_dog, abra, by_bill, cadabra, alakazam)
        end
      end

      specify 'without descendants' do
        params_without = {nomen_id:    top_dog.taxon_name_id,
                          # descendants: nil,
                          rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'}
        result         = Queries::OtuFilterQuery.new(params_without).result
        expect(result).to contain_exactly(top_dog, by_bill)
      end
    end

    context 'author search' do

      specify 'constructs' do
        expect(Role.where(type: 'TaxonNameAuthor').count).to eq(9)
        expect(Person.with_role('TaxonNameAuthor').count).to eq(4) # Bill, Ted, Daryl, and Sargon
        expect(Protonym.named('Topdogidae').count).to eq(1)
      end

      context 'and' do
        specify 'otus by bill, ted, and daryl' do
          params = {author_ids: [bill.id, ted.id, daryl.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(0)
        end

        specify 'otus by daryl and sargon' do
          params = {author_ids: [sargon.id, daryl.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(1)
        end

        specify 'otus by sargon (single author)' do
          params = {author_ids: [sargon.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(2)
        end

        specify 'otus two out of three authors)' do
          params = {author_ids: [sargon.id, ted.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(1)
        end
      end

      context 'or' do
        specify 'otus by authors' do
          params = {author_ids: [bill.id, sargon.id, daryl.id], and_or_select: '_or_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to contain_exactly(spooler, cadabra, nuther_dog)
        end
      end
    end

    context 'combined test' do
      specify 'author, author string, geaographic area, taxon name' do

        tn     = co_a.taxon_names.select { |t| t if t.name == 'cadabra' }.first
        params = {}
        params.merge!({author_ids: [bill.id, daryl.id], and_or_select: '_or_'})
        params.merge!({verbatim_author_string: 'Bill A'})
        params.merge!({geographic_area_ids: [area_a.id]})
        params.merge!({nomen_id:    top_dog.taxon_name_id,
                       descendants: '1',
                       rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'})

        result = Queries::OtuFilterQuery.new(params).result
        expect(result).to contain_exactly(tn.otus.first)
      end
    end
  end
end

def simple_world_x
  gat_parish    = GeographicAreaType.find_or_create_by(name: 'Parish')
  gat_land_mass = GeographicAreaType.find_or_create_by(name: 'Land Mass')
  list_shape_a  = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                                 RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                                 RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                                 RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                                 RSPEC_GEO_FACTORY.point(0, 0, 0.0)])

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

  shape_a = RSPEC_GEO_FACTORY.polygon(list_shape_a)
  shape_b = RSPEC_GEO_FACTORY.polygon(list_shape_b)
  shape_e = RSPEC_GEO_FACTORY.polygon(list_shape_e)

  item_a = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_a]))
  item_b = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_b]))
  item_e = FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_e]))

  earth = FactoryBot.create(:earth_geographic_area)

  area_e = FactoryBot.create(:level0_geographic_area,
                             name:                 'E',
                             geographic_area_type: gat_land_mass,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               earth)
  area_e.geographic_items << item_e
  area_e.save

  @area_a = FactoryBot.create(:level1_geographic_area,
                              name:                 'A',
                              geographic_area_type: gat_parish,
                              iso_3166_a3:          nil,
                              iso_3166_a2:          nil,
                              parent:               area_e)
  @area_a.geographic_items << item_a
  @area_a.save

  area_b = FactoryBot.create(:level1_geographic_area,
                             name:                 'B',
                             geographic_area_type: gat_parish,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               area_e)
  area_b.geographic_items << item_b
  area_b.save

  ce_a  = FactoryBot.create(:collecting_event,
                            start_date_year:   1971,
                            start_date_month:  1,
                            start_date_day:    1,
                            verbatim_locality: 'environs of A',
                            verbatim_label:    'Eh?',
                            geographic_area:   @area_a)
  @co_a = FactoryBot.create(:valid_collection_object, {collecting_event: ce_a})

  @gr_a = FactoryBot.create(:georeference_verbatim_data,
                            api_request:           'area_a',
                            collecting_event:      ce_a,
                            error_geographic_item: item_a,
                            geographic_item:       GeographicItem.new(point: item_a.st_centroid))

  ce_b  = FactoryBot.create(:collecting_event,
                            start_date_year:   1971,
                            start_date_month:  1,
                            start_date_day:    1,
                            verbatim_locality: 'environs of B',
                            verbatim_label:    'Bah',
                            geographic_area:   area_b)
  @co_b = FactoryBot.create(:valid_collection_object, {collecting_event: ce_b})

  @gr_b = FactoryBot.create(:georeference_verbatim_data,
                            api_request:           'area_b',
                            collecting_event:      ce_b,
                            error_geographic_item: item_b,
                            geographic_item:       GeographicItem.new(point: item_b.st_centroid))

  sargon = Person.find_or_create_by(first_name: 'of Akkad', last_name: 'Sargon')
  andy   = Person.find_or_create_by(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author')
  daryl  = Person.find_or_create_by(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon')
  ted    = FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC')
  bill   = Person.find_or_create_by(first_name: 'Bill', last_name: 'Ardson')

  @top_dog = FactoryBot.create(:valid_otu, name: 'Top Dog', taxon_name:
                                                 FactoryBot.create(:valid_taxon_name,
                                                                   rank_class: Ranks.lookup(:iczn, 'Family'),
                                                                   name:       'Topdogidae')
  )

  nuther_dog = FactoryBot.create(:valid_otu, name: 'Another Dog', taxon_name:
                                                   FactoryBot.create(:valid_taxon_name,
                                                                     rank_class: Ranks.lookup(:iczn, 'Family'),
                                                                     name:       'Nutherdogidae')
  )

  tn_abra = Protonym.find_or_create_by(name:       'Abra',
                                       rank_class: Ranks.lookup(:iczn, 'Genus'),
                                       parent:     @top_dog.taxon_name)

  tn_spooler = Protonym.find_or_create_by(name:       'spooler',
                                          rank_class: Ranks.lookup(:iczn, 'Species'),
                                          parent:     tn_abra)

  tn_cadabra  = Protonym.find_or_create_by(name:                'cadabra',
                                           year_of_publication: 2017,
                                           verbatim_author:     'Bill Ardson',
                                           rank_class:          Ranks.lookup(:iczn, 'Species'),
                                           parent:              tn_abra)
  tn_alakazam = Protonym.find_or_create_by(name:       'alakazam',
                                           rank_class: Ranks.lookup(:iczn, 'Subspecies'),
                                           parent:     tn_cadabra)

  by_bill = FactoryBot.create(:valid_otu, name: 'Top Dog (by Bill)', taxon_name: @top_dog.taxon_name)

  o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'Otu_A')
  o.taxon_name.update_column(:name, 'antivitis')
  @co_a.otus << o

  o = @top_dog # this is o1
  o.taxon_name.taxon_name_authors << ted
  @co_a.otus << o

  o            = by_bill
  o.taxon_name = @top_dog.taxon_name
  @co_a.otus << o

  o            = FactoryBot.create(:valid_otu, name: 'Abra')
  o.taxon_name = tn_abra
  o.taxon_name.taxon_name_authors << ted
  @co_a.otus << o
  o   = FactoryBot.create(:valid_otu, name: 'Abra cadabra')
  t_n = tn_cadabra

  o.taxon_name = t_n
  o.save!
  o.taxon_name.taxon_name_authors << bill
  @co_a.otus << o
  o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam')
  @co_a.collecting_event.collectors << bill
  o.taxon_name = tn_alakazam

  o.taxon_name.taxon_name_authors << ted
  @co_a.otus << o
  o.taxon_name

  o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P4')
  @co_b.collecting_event.collectors << sargon
  @co_b.collecting_event.collectors << daryl
  o.taxon_name.update_column(:name, 'beevitis')
  @co_b.otus << o
  o            = FactoryBot.create(:valid_otu, name: 'Sargon\'s spooler')
  o.taxon_name = tn_spooler
  o.taxon_name.taxon_name_authors << sargon
  o.taxon_name.taxon_name_authors << daryl
  @co_b.otus << o
  o = nuther_dog
  o.taxon_name.taxon_name_authors << bill
  o.taxon_name.taxon_name_authors << ted
  o.taxon_name.taxon_name_authors << sargon
  @co_b.otus << o

end

