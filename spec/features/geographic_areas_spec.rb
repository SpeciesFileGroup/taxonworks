require 'rails_helper'

describe 'GeographicAreas', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { geographic_areas_path }
    let(:page_index_name) { 'Geographic Areas' }
  end

  describe 'GET /geographic_areas' do
    before {
      sign_in_user_and_select_project
      visit geographic_areas_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Areas')
    end
  end

  context 'visiting with some records created' do

    before do
      sign_in_user_and_select_project
      # this is so that there are more than one page of geographic_areas
      30.times { factory_girl_create_for_user(:valid_geographic_area, @user) }
      visit list_geographic_areas_path
    end

    describe 'GET /geographic_areas/list' do
      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Geographic Areas'
      end

    end

    describe 'GET /geographic_areas/n' do
      before {
        visit geographic_area_path(GeographicArea.second)
      }

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end

    end
  end

end




