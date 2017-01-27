require 'rails_helper'

describe 'TaxonNameRelationships', :type => :feature do
  let(:page_title) { 'Taxon name relationships' }
  let(:index_path) { taxon_name_relationships_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      root = FactoryGirl.create(:root_taxon_name, project: @project, by: @user)

      genera = []
      %w{Aa Ba Ca Da}.each do |n|
        genera.push Protonym.create!(name: n, parent: root, by: @user, project: @project, rank_class: Ranks.lookup(:iczn, 'genus'))
      end

      [
          [genera[0], genera[1]],
          [genera[1], genera[2]],
          [genera[2], genera[3]]
      ].each do |a, b|

        TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: a, object_taxon_name: b, by: @user, project: @project)
      end
    }

    describe 'GET /taxon_name_relationships' do
      before {
        visit taxon_name_relationships_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /taxon_name_relationships/list' do
      before { visit list_taxon_name_relationships_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /taxon_name_relationships/n' do
      before {
        visit taxon_name_relationship_path(TaxonNameRelationship.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end





