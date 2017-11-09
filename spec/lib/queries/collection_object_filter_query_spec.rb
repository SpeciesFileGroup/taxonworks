require 'rails_helper'

describe Queries::CollectionObjectFilterQuery, type: :model, group: [:geo, :collection_objects] do
  context 'with properly built collection of objects' do

    before(:all) {
      generate_political_areas_with_collecting_events(1, 1)
    }

    let!(:user) { User.find(1) }
    let!(:project) { Project.find(1) }
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
      @co_m2.otus << o
    }
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
      let(:params_with) { {otu_id: otum1.id, otu_descendants: 'on'} }
      let(:params_without) { {otu_id: otum1a.id, otu_descendants: 'off'} }

      # TODO: need to build a descendant
      specify 'with descendants' do
        result = Queries::CollectionObjectFilterQuery.new(params_with).result
        expect(result).to contain_exactly(otum1.collection_objects, otum1a.collection_objects.first)
      end

      specify 'without descendants' do
        result = Queries::CollectionObjectFilterQuery.new(params_without).result
        expect(result).to contain_exactly(otum1a.collection_objects.first)
      end

    end

    context 'collecting event date search' do
      let(:params) { {search_start_date: '1971-01-01', search_end_date: '1980-12-31'} }
      specify 'start and end dates' do
        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(10)
      end
    end

    context 'identifier search' do
      let(:co_32) { Specimen.last }
      let(:co_30) { Specimen.find(co_32.id - 2) }
      let(:co_28) { Specimen.find(co_30.id - 2) }
      let(:co_26) { Specimen.find(co_28.id - 2) }
      let(:co_24) { Specimen.find(co_26.id - 2) }

      specify 'numbers' do

        2.times { FactoryBot.create(:valid_namespace, creator: user, updater: user) }
        ns1 = Namespace.first
        ns2 = Namespace.second
        2.times { FactoryBot.create(:valid_specimen, creator: user, updater: user, project: project) }
        (1..10).each { |identifier|
          sp = FactoryBot.create(:valid_specimen, creator: user, updater: user, project: project)
          id = FactoryBot.create(:identifier_local_catalog_number,
                                 updater:           user,
                                 project:           project,
                                 creator:           user,
                                 identifier_object: sp,
                                 namespace:         ((identifier % 2) == 0 ? ns1 : ns2),
                                 identifier:        identifier)
        }


        params = {id_namespace: ns1.short_name, id_range_start: '2', id_range_stop: '9'}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result).to contain_exactly(co_30, co_28, co_26, co_24)
      end
    end

    context 'user/date search' do
      let!(:pat_admin) {
        peep = FactoryBot.create(:valid_user, name: 'Pat Project Administrator', by: joe)
        ProjectMember.create(project: project, user: peep, by: joe)
        peep
      }
      let!(:pat) {
        peep = FactoryBot.create(:valid_user, name: 'Pat The Other', by: joe)
        ProjectMember.create(project: project, user: peep, by: joe)
        peep
      }
      let!(:joe) { User.find(1) }
      let!(:joe2) {
        peep = FactoryBot.create(:valid_user, name: 'Joe Number Two', by: joe)
        ProjectMember.create(project: project, user: peep, by: joe)
        peep
      }

      specify 'selected object' do
        2.times { FactoryBot.create(:valid_specimen, creator: pat, updater: pat_admin, project: project) }
        (1..10).each { |specimen|
          sp = FactoryBot.create(:valid_specimen,
                                 creator:    ((specimen % 2) == 0 ? joe : pat),
                                 created_at: "200#{specimen - 1}/01/#{specimen}",
                                 updated_at: "200#{specimen - 1}/07/#{specimen}",
                                 updater:    ((specimen % 2) == 0 ? pat : joe),
                                 project:    project)
        }

        params = {user: 'All users', date_type_select: 'created_at'}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(32)

        params = {user:                  'All users', date_type_select: 'created_at',
                  user_date_range_start: '2005-01-01', user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(5)

        params = {user:                  joe, date_type_select: 'created_at',
                  user_date_range_start: Date.today.to_s, user_date_range_end: Date.today.to_s}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(20)

        params = {user:                  joe, date_type_select: 'updated_at',
                  user_date_range_start: nil, user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(0)

        params = {user:                  joe.id, date_type_select: 'created_at',
                  user_date_range_start: '2000-01-01', user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(5)

        params = {user:                  pat_admin, date_type_select: 'created_at',
                  user_date_range_start: Date.yesterday.to_s, user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(0)
      end
    end

    context 'combined search' do
      let!(:pat_admin) {
        peep = FactoryBot.create(:valid_user, name: 'Pat Project Administrator', by: joe)
        ProjectMember.create(project: project, user: peep, by: joe)
        peep
      }
      let!(:pat) {
        peep = FactoryBot.create(:valid_user, name: 'Pat The Other', by: joe)
        ProjectMember.create(project: project, user: peep, by: joe)
        peep
      }
      let!(:joe) { User.find(1) }
      let!(:joe2) {
        peep = FactoryBot.create(:valid_user, name: 'Joe Number Two', by: joe)
        ProjectMember.create(project: project, user: peep, by: joe)
        peep
      }

      specify 'selected object' do
        c_objs   = [@co_m1, @co_n1, @co_o1, @co_p1, @co_m2, @co_n2_a, @co_o2, @co_p2, @co_m3, @co_n3]

# Specimen creation/update dates and Identifier/namespace
        2.times { FactoryBot.create(:valid_namespace, creator: user, updater: user) }
        ns1 = Namespace.first
        ns2 = Namespace.second
        2.times { FactoryBot.create(:valid_specimen, creator: pat_admin, updater: pat_admin, project: project) }
        c_objs.each_with_index { |sp, index|
          sp.update_column(:created_by_id, ((index % 2) == 0 ? joe.id : pat.id))
          sp.update_column(:created_at, "200#{index}/01/#{index + 1}")
          sp.update_column(:updated_at, "200#{index}/07/#{index + 1}")
          sp.update_column(:updated_by_id, ((index % 2) == 0 ? pat.id : joe.id))
          sp.update_column(:project_id, project.id)
          sp.save!
          FactoryBot.create(:identifier_local_catalog_number,
                            updater:           user,
                            project:           project,
                            creator:           user,
                            identifier_object: sp,
                            namespace:         ((index % 2) == 0 ? ns1 : ns2),
                            identifier:        (index + 1).to_s)
        }

#
        params = {}
        params.merge!({user:                  joe,
                       date_type_select:      'created_at',
                       user_date_range_start: '2000-01-01',
                       user_date_range_end:   Date.yesterday.to_s
                      })
        params.merge!({id_namespace:   ns1.short_name,
                       id_range_start: '1',
                       id_range_stop:  '10'
                      })
        params.merge!({geographic_area_ids: [bbxa.id]})

        result = Queries::CollectionObjectFilterQuery.new(params).result
        expect(result.count).to eq(4)
      end
    end
  end
end

