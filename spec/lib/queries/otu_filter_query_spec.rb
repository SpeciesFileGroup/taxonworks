require 'rails_helper'

describe Queries::OtuFilterQuery, type: :model, group: [:geo, :collection_objects, :otus] do

  before(:all) {
    generate_political_areas_with_collecting_events(1, 1)
  }

  after(:all) {
    clean_slate_geo
    CollectionObject.destroy_all
    Namespace.destroy_all
  }

  context 'with properly built collection of objects' do

    let!(:user) { User.find(1) }
    let!(:project) { Project.find(1) }
    # need some people
    let(:ted) { FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC') }
    let(:bill) { Person.find_or_create_by(first_name: 'Bill', last_name: 'Ardson') }

    #need an apex
    let(:top_dog) { o = FactoryBot.create(:valid_otu, name: 'Top Dog')
    o.taxon_name      = FactoryBot.create(:valid_taxon_name,
                                          rank_class: Ranks.lookup(:iczn, 'Family'),
                                          name:       'Topdogidae')
    o
    }

    let(:abra) {Otu.where(name: 'Abra').first}
    let(:cadabra) {Otu.where(name: 'Abra cadabra').first}
    let(:alakazam) {Otu.where(name: 'Abra cadabra alakazam').first}
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
      o = top_dog
      o.taxon_name.taxon_name_authors << ted
      @co_m2.otus << o
      o            = FactoryBot.create(:valid_otu, name: 'Abra')
      o.taxon_name = Protonym.find_or_create_by(name:       'Abra',
                                                rank_class: Ranks.lookup(:iczn, 'Genus'),
                                                parent:     top_dog.taxon_name)
      parent = o.taxon_name
      o.taxon_name.taxon_name_authors << ted
      @co_m2.otus << o
      o            = FactoryBot.create(:valid_otu, name: 'Abra cadabra')
      o.taxon_name = Protonym.find_or_create_by(name:       'cadabra',
                                                rank_class: Ranks.lookup(:iczn, 'Species'),
                                                parent:     parent)
      parent = o.taxon_name
      o.taxon_name.taxon_name_authors << bill
      @co_m2.otus << o
      o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam')
      @co_m2.collecting_event.collectors << bill
      o.taxon_name = Protonym.find_or_create_by(name: 'alakazam',
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
      o.taxon_name.update_column(:name, 'P4 antivitis')
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
          expect(result.count).to eq(19)
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
            expect(result.count).to eq(13)
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

      # TODO: need to build a descendant
      specify 'with descendants' do
        params_with = {nomen_id: top_dog.taxon_name_id, descendants: 'on'}
        result      = Queries::OtuFilterQuery.new(params_with).result
        expect(result.count).to eq(4)
        expect(result).to contain_exactly(top_dog, abra, cadabra, alakazam)
      end

      specify 'without descendants' do
        params_without = {nomen_id: top_dog.taxon_name_id, descendants: 'off'}
        result         = Queries::OtuFilterQuery.new(params_without).result
        expect(result).to contain_exactly(top_dog)
      end

    end

    context 'author search' do
      # need some taxon names and otus
      specify 'otus by author' do
        params = {author_ids: ted.id}

        expect(Role.where(type: 'TaxonNameAuthor').count).to eq(4)
        expect(Person.with_role('TaxonNameAuthor').count).to eq(2)  # Bill and Ted
        expect(Protonym.named('Topdogidae').count).to eq(1)

        result = Queries::OtuFilterQuery.new(params).result
        expect(result.count).to eq(3)
      end
    end

    context 'combined search' do
      specify 'geo_area, nomen (taxon name), author' do
        tn = @co_m2.taxon_names.select {|t| t if t.name == 'cadabra'}.first
        params = {}
        params.merge!({author_ids: ted.id})
        params.merge!({geographic_area_ids: [bbxa.id]})
        params.merge!({nomen_id: tn.id, descendants: 'off'})

        result = Queries::OtuFilterQuery.new(params).result
        expect(result.count).to eq(1)
      end

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
    end
  end
end

