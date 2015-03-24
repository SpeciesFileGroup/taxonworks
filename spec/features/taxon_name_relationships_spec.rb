require 'rails_helper'

describe 'TaxonNameRelationships', :type => :feature do
  let(:page_index_name) { 'taxon name relationships' }
  let(:index_path) { taxon_name_relationships_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      # todo @mjy, need to build object explicitly with user and project
      # 10.times { factory_girl_create_for_user_and_project(:valid_taxon_name_relationship, @user, @project) }
    }

    describe 'GET /taxon_name_relationships' do
      before {
        visit taxon_name_relationships_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    # todo @mjy, following lines commented out until we can create a valid object
    # describe 'GET /taxon_name_relationships/list' do
    #   before { visit list_taxon_name_relationships_path }
    #
    #   it_behaves_like 'a_data_model_with_standard_list'
    # end
    #
    # describe 'GET /taxon_name_relationships/n' do
    #   before {
    #     visit taxon_name_relationship_path(TaxonNameRelationship.second)
    #   }
    #
    #   it_behaves_like 'a_data_model_with_standard_show'
    # end
  end
end





