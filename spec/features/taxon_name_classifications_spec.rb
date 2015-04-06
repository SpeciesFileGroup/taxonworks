require 'rails_helper'

describe 'TaxonNameClassifications', :type => :feature do
  let(:index_path) { taxon_name_classifications_path }
  let(:page_index_name) { 'taxon name classifications' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      root = factory_girl_create_for_user_and_project(:root_taxon_name, @user, @project) 
      taxon_name = Protonym.create!(
        parent: root, 
        name: 'Aus',
        rank_class: Ranks.lookup(:iczn, 'genus'),
        by: @user,
        project: @project
      )

      TaxonNameClassification::Iczn::Available::Valid.create!(taxon_name: taxon_name, by: @user, project: @project)
      TaxonNameClassification::Iczn::Available::Valid::NomenDubium.create!(taxon_name: taxon_name, by: @user, project: @project)
      TaxonNameClassification::Iczn::Available.create!(taxon_name: taxon_name, by: @user, project: @project) 
    }


    describe 'GET /taxon_name_classifications' do
      before { visit taxon_name_classifications_path }
      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /taxon_name_classifications/list' do
      before { visit list_taxon_name_classifications_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end

   # TODO:  there is no GET /taxon_name_classifications, context is to TaxonName
   #describe 'GET /taxon_name_classifications/n' do
   #  before {
   #    visit taxon_name_classification_path(TaxonNameClassification.second)
   #  }
   # 
   #  # it_behaves_like 'a_data_model_with_standard_show'
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




