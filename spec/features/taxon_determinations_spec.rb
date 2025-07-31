require 'rails_helper'

describe 'TaxonDeterminations', type: :feature do
  let(:page_title) { 'Taxon determinations' }
  let(:index_path) { taxon_determinations_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      # Create taxon determination via specimen.
      otu = factory_bot_create_for_user_and_project(:valid_otu, @user, @project)
      3.times {
        Specimen.create!(
            taxon_determinations_attributes: [{otu_id: otu.id, by: @user, project: @project}],
            by: @user,
            project: @project
        )
      }
    }

    describe 'GET /taxon_determinations' do
      before {
        visit taxon_determinations_path }
      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /taxon_determinations/list' do
      before { visit list_taxon_determinations_path }
      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /taxon_determinations/n' do
      before {
        visit taxon_determination_path(TaxonDetermination.second)
      }
      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end
