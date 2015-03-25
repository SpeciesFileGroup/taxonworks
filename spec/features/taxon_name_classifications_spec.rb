require 'rails_helper'

describe 'TaxonNameClassifications', :type => :feature do
  let(:index_path) { taxon_name_classifications_path }
  let(:page_index_name) { 'taxon name classifications' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      # todo @mjy, need to build object explicitly with user and project
      # 10.times { factory_girl_create_for_user_and_project(:valid_taxon_name_classification, @user, @project) }
    }

    describe 'GET /taxon_name_classifications' do
      before {
        visit taxon_name_classifications_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    # todo @mjy, following lines commented out until we can create a valid object
    # describe 'GET /taxon_name_classifications/list' do
    #   before { visit list_taxon_name_classifications_path }
    #
    #   it_behaves_like 'a_data_model_with_standard_list'
    # end
    #
    # describe 'GET /taxon_name_classifications/n' do
    #   before {
    #     visit taxon_name_classification_path(TaxonNameClassification.second)
    #   }
    #
    #   it_behaves_like 'a_data_model_with_standard_show'
    # end
  end

  context 'resource routes' do
    #  before {
    #    sign_in_user_and_select_project
    #  }

    # The scenario for creating TaxonNameClassifications has not been developed. 
    # It must handle these three calls for logged in/not logged in users.
    # It may be that these features are ultimately tested in a task.
    describe 'POST /create' do
    end

    describe 'PATCH /update' do
    end

    describe 'DELETE /destroy' do
    end

    describe 'the partial form rendered in context of NEW on some other page' do
    end
  end

end




