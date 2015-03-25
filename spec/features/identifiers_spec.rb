require 'rails_helper'

describe 'Identifiers', :type => :feature do
  let(:page_index_name) { 'identifiers' }
  let(:index_path) { identifiers_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      # todo @mjy, need to build object explicitly with user and project
      # 10.times { factory_girl_create_for_user_and_project(:valid_identifier, @user, @project) }
    }

    describe 'GET /identifiers' do
      before {
        visit identifiers_path
      }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    # todo @mjy, following lines commented out until we can create a valid object
    # describe 'GET /identifiers/list' do
    #   before { visit list_identifiers_path }
    #
    #   it_behaves_like 'a_data_model_with_standard_list'
    # end
  end
end







