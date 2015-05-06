require 'rails_helper'

describe 'GeographicAreas', type: :feature do
  let(:page_index_name) { 'geographic areas' }
  let(:index_path) { geographic_areas_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      5.times { factory_girl_create_for_user(:valid_geographic_area, @user) }
    }

    describe 'GET /geographic_areas' do
      before { visit geographic_areas_path }
       it_behaves_like 'a_data_model_with_standard_index', true # <- this true says "no new link" 
    end

    describe 'GET /geographic_areas/list' do
      before { visit list_geographic_areas_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /geographic_areas/n' do
      before {
        visit geographic_area_path(GeographicArea.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end

