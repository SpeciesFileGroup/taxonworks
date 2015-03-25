require 'rails_helper'

describe 'Georeferences', :type => :feature do
  let(:index_path) { georeferences_path }
  let(:page_index_name) { 'georeferences' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      # todo @mjy, cannot use following to create a georeference object with all the dependencies (georeference created other objects, that reference $user_id, which is not set)
      # 10.times { factory_girl_create_for_user_and_project(:valid_georeference, @user, @project) }
    }

    describe 'GET /georeferences' do
      before {
        visit georeferences_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    # todo @mjy, following lines commented out until we can create a valid object
    # describe 'GET /georeferences/list' do
    #   before { visit list_georeferences_path }
    #
    #   it_behaves_like 'a_data_model_with_standard_list'
    # end
    #
    # describe 'GET /georeferences/n' do
    #   before {
    #     visit georeference_path(Georeference.second)
    #   }
    #
    #   it_behaves_like 'a_data_model_with_standard_show'
    # end
  end
end


