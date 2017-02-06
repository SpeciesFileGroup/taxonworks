require 'rails_helper'

describe 'TaxonNameClassifications', :type => :feature do
  let(:index_path) { taxon_name_classifications_path }
  let(:page_title) { 'Taxon name classifications' }

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

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    # There is no GET /taxon_name_classifications, context is to TaxonName
    describe 'Showing a taxon classification' do
      before {
        visit list_taxon_name_classifications_path
      }
      specify 'Clicking a recent link resolves to the corresponding taxon page', js: true do
        first('td', text: 'Aus').double_click
        expect(page).to have_content('Taxon names')
        expect(page).to have_content('Aus')
      end
    end
  end
end




