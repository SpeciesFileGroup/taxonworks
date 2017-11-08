require 'rails_helper'

describe Queries::CollectionObjectFilterQuery, type: :model, group: [:geo, :collection_objects] do
  context 'with properly built collection of objects' do

    before(:all) {
      generate_political_areas_with_collecting_events(1, 1)
    }

    let!(:co_m1a_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M1A')
      @co_m1a.otus << o
    }
    let!(:co_m1_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M1')
      @co_m1.otus << o
    }
    let!(:co_n1_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N1, No georeference')
      @co_n1.otus << o
    }
    let!(:co_o1_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O1')
      @co_o1.otus << o
    }
    let!(:co_p1_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P1')
      @co_p1.otus << o
    }
    let!(:co_m2_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M2')
      @co_m2.otus << o
    }
    let!(:co_n2_a_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N2A')
      @co_n2_a.otus << o
    }
    let!(:co_n2_b_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N2B')
      @co_n2_b.otus << o
    }
    let!(:co_o2_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O2')
      @co_o2.otus << o
    }
    let!(:co_p2_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P2, No georeference')
      @co_p2.otus << o
    }
    let!(:co_m3_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M3')
      @co_m3.otus << o
    }
    let!(:co_n3_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N3')
      @co_n3.otus << o
    }
    let!(:co_o3_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O3, No georeference')
      @co_o3.otus << o
    }
    let!(:co_p3_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P3, No georeference')
      @co_p3.otus << o
    }
    let!(:co_m4_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M4')
      @co_m4.otus << o
    }
    let!(:co_n4_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N4')
      @co_n4.otus << o
    }
    let!(:co_o4_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O4')
      @co_o4.otus << o
    }
    let!(:co_p4_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P4')
      @co_p4.otus << o
    }
    let!(:co_v_o) {
      o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'I can\'t be found!')
      @co_v.otus << o
    }

    let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }
    let!(:bbxa) { GeographicArea.where(name: 'Big Boxia').first }
    let!(:m1) { GeographicArea.where(name: 'M1').first }

    let!(:otum1) { Otu.where(name: 'Find me, I\'m in M1!').first }
    let!(:otum1a) { Otu.where(name: 'M1A').first }

    let(:big_boxia_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }
    let(:m1_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [34, 28, 0], [34, 27, 0], [33, 27, 0], [33, 28, 0]]]}}' }


    after(:all) {
      clean_slate_geo
      CollectionObject.destroy_all
      Namespace.destroy_all
    }

    context 'area search' do
      context 'named area' do
        let(:params) { {geographic_area_ids: [gnlm.id]} }

        specify 'collection objects count' do
          result = Queries::CollectionObjectFilterQuery.new(params).result
          expect(result.count).to eq(16)
        end

        specify 'specific collection objects' do
          result = Queries::CollectionObjectFilterQuery.new(params).result
          expect(result).to include(otum1.collection_objects.first)
        end

      end

      context 'area shapes' do

        context 'area shape big boxia' do
          let(:params) { {drawn_area_shape: big_boxia_string} }

          specify 'collection objects count' do
            result = Queries::CollectionObjectFilterQuery.new(params).result
            expect(result.count).to eq(10)
          end

          specify 'specific collection objects' do
            result = Queries::CollectionObjectFilterQuery.new(params).result
            expect(result).to include(otum1.collection_objects.first)
          end
        end

        context 'area shape m1' do
          let(:params) { {drawn_area_shape: m1_string} }

          specify 'collection objects count' do
            result = Queries::CollectionObjectFilterQuery.new(params).result
            expect(result.count).to eq(2)
          end

          specify 'specific collection objects' do
            result = Queries::CollectionObjectFilterQuery.new(params).result
            expect(result).to include(otum1a.collection_objects.first)
          end
        end
      end
    end

    context 'otu search' do
      let(:params_with) { {otu_id: otum1a.id, otu_descendants: 'on'} }
      let(:params_without) { {otu_id: otum1a.id, otu_descendants: 'off'} }

      specify 'with descendants' do
        result = Queries::CollectionObjectFilterQuery.new(params_with).result
        expect(result).to eq(otum1a.collection_objects)
      end

      # TODO: need to build a descendant
      xspecify 'without descendants' do
        result = Queries::CollectionObjectFilterQuery.new(params_without).result
        expect(result).to include(otum1a.collection_objects.first)
      end

    end

    context 'date search' do

    end

    context 'identifier search' do
      let!(:user) { User.find(1) }
      let!(:project) { Project.find(1) }
      let(:params) {{}}
      specify '' do

        2.times { FactoryGirl.create(:valid_namespace, creator: user, updater: user) }
        ns1 = Namespace.first
        ns2 = Namespace.second
        2.times { FactoryGirl.create(:valid_specimen, creator: user, updater: user, project: project) }
        (1..10).each { |identifier|
          sp = FactoryGirl.create(:valid_specimen, creator: user, updater: user, project: project)
          id = FactoryGirl.create(:identifier_local_catalog_number,
                                  updater:           user,
                                  project:           project,
                                  creator:           user,
                                  identifier_object: sp,
                                  namespace:         ((identifier % 2) == 0 ? ns1 : ns2),
                                  identifier:        identifier)
        }


        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result).to include(otum1, otum1a)
      end
    end

    context 'user/date search' do

    end

    context 'combined search' do

    end
  end
end

