require 'rails_helper'

describe Queries::OtuFilterQuery, type: :model, group: [:geo, :collection_objects, :otus] do

  before(:all) {
    generate_political_areas_with_collecting_events(1, 1)
  }

  after(:all) do
    clean_slate_geo
    CollectionObject.destroy_all
    Namespace.destroy_all
  end

  context 'with properly built collection of objects' do
    # need some people
    let!(:sargon) { Person.find_or_create_by(first_name: 'of Akkad', last_name: 'Sargon') }
    let!(:andy) { Person.find_or_create_by(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author') }
    let!(:daryl) { Person.find_or_create_by(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon') }
    let!(:ted) { FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC') }
    let!(:bill) { Person.find_or_create_by(first_name: 'Bill', last_name: 'Ardson') }

    #need an apex
    let!(:top_dog) {
      FactoryBot.create(:valid_otu, name: 'Top Dog', taxon_name:
                                          FactoryBot.create(:valid_taxon_name,
                                                            rank_class: Ranks.lookup(:iczn, 'Family'),
                                                            name:       'Topdogidae')
      )
    }

    let!(:nuther_dog) {
      FactoryBot.create(:valid_otu, name: 'Another Dog', taxon_name:
                                          FactoryBot.create(:valid_taxon_name,
                                                            rank_class: Ranks.lookup(:iczn, 'Family'),
                                                            name:       'Nutherdogidae')
      )
    }

    let!(:by_bill) {
      FactoryBot.create(:valid_otu, name: 'Top Dog (by Bill)', taxon_name: top_dog.taxon_name)
    }

    let(:abra) { Otu.where(name: 'Abra').first }
    let(:cadabra) { Otu.where(name: 'Abra cadabra').first }
    let(:alakazam) { Otu.where(name: 'Abra cadabra alakazam').first }
    let(:spooler) { Otu.where('name like \'%spooler%\'').first }

    # need some otus
    let!(:co_m1a_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M1A')
      @co_m1a.otus << o
    }

    let!(:co_m1_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M1')
      @co_m1.otus << o
    }

    let!(:co_n1_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N1, No georeference')
      @co_n1.otus << o
    }

    let!(:co_o1_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O1')
      @co_o1.otus << o
    }

    let!(:co_p1_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P1')
      @co_p1.otus << o
    }

    let!(:co_m2_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M2')
      o.taxon_name.update_column(:name, 'M2 antivitis')
      @co_m2.otus << o

      o = top_dog # this is o1
      o.taxon_name.taxon_name_authors << ted
      @co_m2.otus << o

      o            = Otu.where('name like \'%(by Bill)%\'').first # this is o2
      o.taxon_name = top_dog.taxon_name
      @co_m2.otus << o

      o            = FactoryBot.create(:valid_otu, name: 'Abra')
      o.taxon_name = Protonym.find_or_create_by(name:       'Abra',
                                                rank_class: Ranks.lookup(:iczn, 'Genus'),
                                                parent:     top_dog.taxon_name)
      parent       = o.taxon_name
      o.taxon_name.taxon_name_authors << ted
      @co_m2.otus << o
      o            = FactoryBot.create(:valid_otu, name: 'Abra cadabra')
      t_n          = Protonym.find_or_create_by(name:                'cadabra',
                                                year_of_publication: 2017,
                                                verbatim_author:     'Bill Ardson',
                                                rank_class:          Ranks.lookup(:iczn, 'Species'),
                                                parent:              parent)
      o.taxon_name = t_n
      o.save!
      parent       = o.taxon_name
      o.taxon_name.taxon_name_authors << bill
      @co_m2.otus << o
      o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam')
      @co_m2.collecting_event.collectors << bill
      o.taxon_name = Protonym.find_or_create_by(name:       'alakazam',
                                                rank_class: Ranks.lookup(:iczn, 'Subspecies'),
                                                parent:     parent)
      o.taxon_name.taxon_name_authors << ted
      @co_m2.otus << o
      o.taxon_name }
    let!(:co_n2_a_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N2A')
      @co_n2_a.otus << o
    }
    let!(:co_n2_b_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N2B')
      @co_n2_b.otus << o
    }
    let!(:co_o2_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O2')
      @co_o2.otus << o
    }
    let!(:co_p2_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P2, No georeference')
      @co_p2.otus << o
    }
    let!(:co_m3_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M3')
      @co_m3.otus << o
    }
    let!(:co_n3_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N3')
      @co_n3.otus << o
    }
    let!(:co_o3_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O3, No georeference')
      @co_o3.otus << o
    }
    let!(:co_p3_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P3, No georeference')
      @co_p3.otus << o
    }
    let!(:co_m4_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M4')
      @co_m4.otus << o
    }
    let!(:co_n4_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N4')
      @co_n4.otus << o
    }
    let!(:co_o4_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O4')
      @co_o4.otus << o
    }
    let!(:co_p4_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P4')
      @co_p4.collecting_event.collectors << sargon
      @co_p4.collecting_event.collectors << daryl
      o.taxon_name.update_column(:name, 'P4 antivitis')
      @co_p4.otus << o
      o            = FactoryBot.create(:valid_otu, name: 'Sargon\'s spooler')
      o.taxon_name = Protonym.find_or_create_by(name:       'spooler',
                                                rank_class: Ranks.lookup(:iczn, 'Species'),
                                                parent:     abra.taxon_name)
      o.taxon_name.taxon_name_authors << sargon
      o.taxon_name.taxon_name_authors << daryl
      @co_p4.otus << o
      o = nuther_dog
      o.taxon_name.taxon_name_authors << bill
      o.taxon_name.taxon_name_authors << ted
      o.taxon_name.taxon_name_authors << sargon
      @co_p4.otus << o
    }
    let!(:co_v_o) {
      o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'I can\'t be found!')
      @co_v.otus << o
    }

    let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }
    let!(:bbxa) { GeographicArea.where(name: 'Big Boxia').first }
    let!(:m1) { GeographicArea.where(name: 'M1').first }

    let!(:otum1) { Otu.where(name: 'Find me, I\'m in M1!').first }
    let!(:otum1a) { Otu.where(name: 'M1A').first }
    let!(:otum2) { Otu.where(name: 'M2').first }
    let!(:otup4) { Otu.where(name: 'P4').first }

    let(:big_boxia_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }
    let(:m1_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [34, 28, 0], [34, 27, 0], [33, 27, 0], [33, 28, 0]]]}}' }

    context 'area search' do
      context 'named area' do
        let(:params) { {geographic_area_ids: [gnlm.id]} }

        specify 'nomen count' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(22)
        end

        specify 'specific nomen' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to include(otum1)
        end

      end

      context 'area shapes' do

        context 'area shape big boxia' do
          let(:params) { {drawn_area_shape: big_boxia_string} }

          specify 'nomen count' do
            result = Queries::OtuFilterQuery.new(params).result
            expect(result.count).to eq(14)
          end

          specify 'specific nomen' do
            result = Queries::OtuFilterQuery.new(params).result
            expect(result).to include(otum1)
          end
        end

        context 'area shape m1' do
          let(:params) { {drawn_area_shape: m1_string} }

          specify 'nomen count' do
            result = Queries::OtuFilterQuery.new(params).result
            expect(result.count).to eq(3)
          end

          specify 'specific nomen' do
            result = Queries::OtuFilterQuery.new(params).result
            expect(result).to include(otum1a)
          end
        end
      end
    end

    context 'nomen search' do

      # TODO: need to build multiple otus with the same taxon_name
      specify 'with descendants' do
        params_with = {nomen_id: top_dog.taxon_name_id, descendants: '_on_'}
        result      = Queries::OtuFilterQuery.new(params_with).result
        expect(result).to contain_exactly(spooler, top_dog, abra, by_bill, cadabra, alakazam)
      end

      specify 'without descendants' do
        params_without = {nomen_id: top_dog.taxon_name_id, descendants: '_off_'}
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

    context 'author string search' do
      specify 'otus by author string' do
        tn     = @co_m2.taxon_names.select { |t| t if t.name == 'cadabra' }.first
        params = ({verbatim_author_string: 'Ardson'})

        result = Queries::OtuFilterQuery.new(params).result
        expect(result.first).to eq(tn.otus.first)
      end
    end

    context 'combined search' do

      specify 'returning none' do
        ot = @co_p4.taxon_names.last
        # tn        = ot.taxon_name
        # test_name = tn.name
        params = {}
        params.merge!({geographic_area_ids: [bbxa.id]})
        params.merge!({nomen_id: ot.id})

        result = Queries::OtuFilterQuery.new(params).result
        expect(result.count).to eq(0)
      end

      specify 'geo_area, nomen (taxon name), author, verbatim author string' do
        tn     = @co_m2.taxon_names.select { |t| t if t.name == 'cadabra' }.first
        params = {}
        params.merge!({author_ids: [bill.id, daryl.id], and_or_select: '_or_'})
        # params.merge!({verbatim_author_string: 'Bill A'})
        params.merge!({geographic_area_ids: [bbxa.id]})
        params.merge!({nomen_id: top_dog.taxon_name_id, descendants: '_on_'})


        result = Queries::OtuFilterQuery.new(params).result
        expect(result).to contain_exactly(tn.otus.first)
      end
    end
  end

  def simple_world
    gat_parish    = GeographicAreaType.find_or_create_by(name: 'Parish')
    gat_land_mass = GeographicAreaType.find_or_create_by(name: 'Land Mass')

  end
end

