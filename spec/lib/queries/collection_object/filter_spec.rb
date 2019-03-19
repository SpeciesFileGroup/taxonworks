require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::CollectionObject::Filter, type: :model, group: [:geo, :collection_object, :collecting_event, :shared_geo] do
  context 'simple filter' do
    let(:params) { {} }
    let(:query) { Queries::CollectionObject::Filter.new(params) }

    let(:ce1) { CollectingEvent.create(verbatim_locality: 'Out there',
                                       start_date_year: 2010,
                                       start_date_month: 2,
                                       start_date_day: 18) }

    let(:ce2) { CollectingEvent.create(verbatim_locality: 'Out there, under the stars',
                                       verbatim_trip_identifier: 'Foo manchu',
                                       start_date_year: 2000,
                                       start_date_month: 2,
                                       start_date_day: 18,
                                       print_label: 'THERE: under the stars:18-2-2000') }


    let!(:co1) { Specimen.create!(collecting_event: ce1) }

    # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
    # let!(:i1) { Identifier::Local::TripCode.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
    # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }
    specify '#recent' do
      params.merge!({recent: true})
      expect(query.all.map(&:id)).to contain_exactly(co1.id)
    end
  end

  context 'with properly built collection of objects' do
    include_context 'stuff for complex geo tests'

    before { [co_a, co_b, gr_a, gr_b].each }

    context 'area search' do
      context 'named area' do
        let(:params) { {geographic_area_ids: [area_e.id]} }

        specify 'collection objects count' do
          result = Queries::CollectionObject::Filter.new(params).all
          expect(result.count).to eq(2)
        end

        specify 'specific collection objects' do
          result = Queries::CollectionObject::Filter.new(params).all
          expect(result).to include(abra.collection_objects.first,
                                    nuther_dog.collection_objects.first)
        end

      end

      context 'area shapes' do

        context 'area shape area b' do
          let(:params) { {drawn_area_shape: area_b.to_geo_json_feature} }

          specify 'collection objects count' do
            result = Queries::CollectionObject::Filter.new(params).all
            expect(result.count).to eq(1)
          end

          specify 'specific collection objects' do
            result = Queries::CollectionObject::Filter.new(params).all
            expect(result).to include(spooler.collection_objects.first)
          end
        end

        context 'area shape area a' do
          let(:params) { {drawn_area_shape: area_a.to_geo_json_feature} }

          specify 'collection objects count' do
            result = Queries::CollectionObject::Filter.new(params).all
            expect(result.count).to eq(1)
          end

          specify 'specific collection objects' do
            result = Queries::CollectionObject::Filter.new(params).all
            expect(result).to include(otu_a.collection_objects.first)
          end
        end
      end
    end

    context 'otu search' do

      # TODO: need to build a descendant
      specify 'with descendants' do
        params_with = {otu_id: top_dog.id, otu_descendants: 'on'}
        result      = Queries::CollectionObject::Filter.new(params_with).all
        expect(result.first.otus.count).to eq(6)
        expect(result).to contain_exactly(co_a)
      end

      specify 'without descendants' do
        params_without = {otu_id: top_dog.id, otu_descendants: 'off'}
        result         = Queries::CollectionObject::Filter.new(params_without).all
        expect(result).to contain_exactly(top_dog.collection_objects.first)
      end

    end

    context 'collecting event date search' do
      let(:params) { {search_start_date: '1971-01-01', search_end_date: '1980-12-31'} }
      specify 'start and end dates' do
        result = Queries::CollectionObject::Filter.new(params).all
        expect(result.count).to eq(1)
      end
    end

    context 'collecting event date search' do
      let(:params) { {search_start_date: '1975-01-01', search_end_date: '1982-12-31'} }
      specify 'start and end dates' do
        result = Queries::CollectionObject::Filter.new(params).all
        expect(result.count).to eq(1)
      end
    end

    context 'identifier search' do
      # let(:user) { User.find(1) }
      # let(:project) { Project.find(1) }

      let(:co_32) { Specimen.last }
      let(:co_30) { Specimen.find(co_32.id - 2) }
      let(:co_28) { Specimen.find(co_30.id - 2) }
      let(:co_26) { Specimen.find(co_28.id - 2) }
      let(:co_24) { Specimen.find(co_26.id - 2) }

      specify 'numbers' do

        2.times { FactoryBot.create(:valid_namespace, creator: geo_user, updater: geo_user) }
        ns1 = Namespace.first
        ns2 = Namespace.second
        2.times { FactoryBot.create(:valid_specimen, creator: geo_user, updater: geo_user, project: geo_project) }
        (1..10).each { |identifier|
          sp = FactoryBot.create(:valid_specimen, creator: geo_user, updater: geo_user, project: geo_project)
          _id = FactoryBot.create(:identifier_local_catalog_number,
                                  updater: geo_user,
                                  project: geo_project,
                                  creator: geo_user,
                                  identifier_object: sp,
                                  namespace: (identifier.even? ? ns1 : ns2),
                                  identifier: identifier)
        }


        params = {id_namespace: ns1.short_name, id_range_start: '2', id_range_stop: '9'}

        result = Queries::CollectionObject::Filter.new(params).all
        expect(result).to contain_exactly(co_30, co_28, co_26, co_24)
      end
    end

    context 'user/date search' do
      let!(:pat_admin) {
        peep = FactoryBot.create(:valid_user, name: 'Pat Project Administrator', by: joe)
        ProjectMember.create!(project: geo_project, user: peep, by: joe)
        peep
      }
      let!(:pat) {
        peep = FactoryBot.create(:valid_user, name: 'Pat The Other', by: joe)
        ProjectMember.create!(project: geo_project, user: peep, by: joe)
        peep
      }
      let!(:joe) { User.find(1) }
      let!(:joe2) {
        peep = FactoryBot.create(:valid_user, name: 'Joe Number Two', by: joe)
        ProjectMember.create!(project: geo_project, user: peep, by: joe)
        peep
      }

      specify 'selected object' do
        2.times { FactoryBot.create(:valid_specimen, creator: pat, updater: pat_admin, project: geo_project) }
        (1..10).each { |specimen|
          _sp = FactoryBot.create(:valid_specimen,
                                  creator: (specimen.even? ? joe : pat),
                                  created_at: "200#{specimen - 1}/01/#{specimen}",
                                  updated_at: "200#{specimen - 1}/07/#{specimen}",
                                  updater: (specimen.even? ? pat : joe),
                                  project: geo_project)
        }

        params = {user: 'All users', date_type_select: 'created_at'}

        result = Queries::CollectionObject::Filter.new(params).all
        # 2 from previous (simple_world), and (2 + 10) generated above
        expect(result.count).to eq(14)

        params = {user: 'All users', date_type_select: 'created_at',
                  user_date_range_start: '2005-01-01', user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObject::Filter.new(params).all
        expect(result.count).to eq(5)

        params = {user:                  joe, date_type_select: 'created_at',
                  user_date_range_start: '2000/01/01', user_date_range_end: '2001/07/01'}

        result = Queries::CollectionObject::Filter.new(params).all
        # 2 from previous (simple_world), and 1 generated above
        expect(result.count).to eq(3)

        params = {user:                  joe, date_type_select: 'updated_at',
                  user_date_range_start: nil, user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObject::Filter.new(params).all
        expect(result.count).to eq(0)

        params = {user:                  joe.id, date_type_select: 'created_at',
                  user_date_range_start: '2000-01-01', user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObject::Filter.new(params).all
        # 2 from previous (simple_world), and 5 generated above
        expect(result.count).to eq(7)

        params = {user: pat_admin, date_type_select: 'created_at',
                  user_date_range_start: Date.yesterday.to_s, user_date_range_end: Date.yesterday.to_s}

        result = Queries::CollectionObject::Filter.new(params).all
        expect(result.count).to eq(0)
      end
    end

    context 'combined search' do
      let!(:pat_admin) {
        peep = FactoryBot.create(:valid_user, name: 'Pat Project Administrator', by: joe)
        ProjectMember.create!(project: geo_project, user: peep, by: joe)
        peep
      }
      let!(:pat) {
        peep = FactoryBot.create(:valid_user, name: 'Pat The Other', by: joe)
        ProjectMember.create!(project: geo_project, user: peep, by: joe)
        peep
      }
      let!(:joe) { User.find(1) }
      let!(:joe2) {
        peep = FactoryBot.create(:valid_user, name: 'Joe Number Two', by: joe)
        ProjectMember.create!(project: geo_project, user: peep, by: joe)
        peep
      }

      specify 'selected object' do
        c_objs = [co_a, co_b]

        # Specimen creation/update dates and Identifier/namespace
        2.times { FactoryBot.create(:valid_namespace, creator: geo_user, updater: geo_user) }
        ns1 = Namespace.first
        ns2 = Namespace.second
        2.times { FactoryBot.create(:valid_specimen, creator: pat_admin, updater: pat_admin, project: geo_project) }
        c_objs.each_with_index { |sp, index|
          sp.update_column(:created_by_id, (index.odd? ? joe.id : pat.id))
          sp.update_column(:created_at, "200#{index}/01/#{index + 1}")
          sp.update_column(:updated_at, "200#{index}/07/#{index + 1}")
          sp.update_column(:updated_by_id, (index.odd? ? pat.id : joe.id))
          sp.update_column(:project_id, geo_project.id)
          sp.save!
          FactoryBot.create(:identifier_local_catalog_number,
                            updater:           geo_user,
                            project:           geo_project,
                            creator:           geo_user,
                            identifier_object: sp,
                            namespace:         (index.even? ? ns1 : ns2),
                            identifier:        (index + 1).to_s)
        }

# We are expecting to get only one collection_object, the one from QTM2
# when this test is run along with all the rest, there are otus which have been deleted, but are still attached
# to collection objects. As a result, we select the *last* one (the one *most recently* created),
# rather than the first.
        ot        = co_b.otus.order(:id).last
        tn        = ot.taxon_name
        test_name = tn.name
        params    = {}
        params.merge!({otu_id: ot.id})
        params.merge!({user:                  joe,
                       date_type_select:      'created_at',
                       user_date_range_start: '2001-01-01',
                       user_date_range_end:   '2004-02-01'
                      })
        params.merge!({id_namespace:   ns2.short_name,
                       id_range_start: '2',
                       id_range_stop:  '8'
                      })
        params.merge!({geographic_area_ids: [area_b.id]})
        params.merge!({search_start_date: '1970-01-01', search_end_date: '1986-12-31'})

        result = Queries::CollectionObject::Filter.new(params).all
        expect(result).to contain_exactly(co_b)
        expect(result.first.otus.count).to eq(3)
        expect(result.first.otus.order(:id).last.taxon_name.name).to eq(test_name)
      end
    end
  end
end

