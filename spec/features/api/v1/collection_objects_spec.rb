require 'rails_helper'

describe 'API::v1::CollectionObjects', type: :feature do

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_girl_create_for_user_and_project(:valid_specimen, @user, @project) }
    }

    # TODO: Refactor this test.
    describe 'GET /api/v1/collection_objects/{id}' do
      before do
        @user.generate_api_access_token
        @user.save!
      end

      let(:valid_attributes) {
        FactoryBot.build(:valid_collection_object).attributes.merge({creator: @user, updater: @user, project: @project})
      }

      let!(:collecting_event) do
        CollectingEvent.create!(by: @user, project: @project)
      end
      
      let!(:geographic_item) do
        FactoryBot.create(:geographic_item_with_polygon,
                           polygon: SHAPE_K,
                           creator: @user,
                           updater: @user)
      end
     
      let!(:georeference) do
        FactoryBot.create(:valid_georeference,
                           creator:          @user,
                           updater:          @user,
                           project:          @project,
                           collecting_event: collecting_event,
                           geographic_item:  geographic_item)
      end

      let(:collection_object) do
        CollectionObject.create! valid_attributes.merge(
          {
            depictions_attributes: [
                                     {
                                       creator:          @user,
                                       updater:          @user,
                                       project:          @project,
                                       image_attributes: {
                                         creator:    @user,
                                         updater:    @user,
                                         project:    @project,
                                         image_file: fixture_file_upload(
                                                       (Rails.root + 'spec/files/images/tiny.png'),
                                                       'image/png')
                                       }
                                     }
                                   ],
            collecting_event:      collecting_event
          }
        )
      end

      # TODO: With the separation of images and geo_json, this path is no longer required.
      it 'Returns a response including URLs to images API endpoint' do
        visit "/api/v1/collection_objects/#{collection_object.to_param}?include[]=images&project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        visit JSON.parse(page.body)['result']['images'].first['url'] + "?project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        expect(JSON.parse(page.body)['result']['id']).to eq(collection_object.images.first.id)
      end

      it 'Returns a response including geo_json' do
        visit "/api/v1/collection_objects/#{collection_object.to_param}/geo_json?project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        expect(JSON.parse(page.body)['result']['geo_json']).to eq(collection_object.collecting_event.to_geo_json_feature)
      end

      it 'Returns a response including images' do
        visit "/api/v1/collection_objects/#{collection_object.to_param}/images?project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        visit JSON.parse(page.body)['result']['images'].first['url'] + "?project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        expect(JSON.parse(page.body)['result']['id']).to eq(collection_object.images.first.id)
      end
    end

    describe 'GET /api/v1/collection_objects/by_identifier/{identifier}' do
      before do
        @user.generate_api_access_token
        @user.save!
      end
      let(:valid_attributes) {
        FactoryBot.build(:valid_collection_object).attributes.merge({creator: @user, updater: @user, project: @project})
      }
      let(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'ABCD', by: @user) }
      let(:collection_object) do
        CollectionObject.create! valid_attributes.merge(
          {identifiers_attributes: [{identifier: '123', type: 'Identifier::Local::CatalogNumber', namespace: namespace, by: @user, project: @project}]})
      end

      it 'Returns a response including URLs to collection objects API endpoint' do
        visit "/api/v1/collection_objects/by_identifier/ABCD%20123?project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        visit JSON.parse(page.body)['result']['collection_objects'].first['url'] + "?project_id=#{collection_object.project.to_param}&token=#{@user.api_access_token}"
        expect(JSON.parse(page.body)['result']['id']).to eq(collection_object.id)
      end
    end

  end

 end
