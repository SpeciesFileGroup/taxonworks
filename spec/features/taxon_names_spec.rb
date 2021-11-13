require 'rails_helper'

describe 'TaxonNames', type: :feature do
  let(:page_title) { 'Taxon names' }
  let(:index_path) { taxon_names_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before(:each) {
      sign_in_user_and_select_project
    }

    let(:root) { FactoryBot.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }

    context 'with some records created' do
      before(:each) {
        5.times {
          Protonym.create(
            user_project_attributes(@user, @project).merge(
              parent: root,
              source: nil,
              rank_class: Ranks.lookup(:iczn, :family), name: 'Fooidae'
            )
          )
        }
      }

      context 'visiting taxon_names_path' do
        before(:each) {
          visit taxon_names_path
        }

        describe 'GET /taxon_names' do
          it_behaves_like 'a_data_model_with_standard_index'
        end

        specify 'creating a new TaxonName', js: true do
          click_link('New')
          fill_in('Name', with: 'Fooidae')
          select('family (ICZN)', from: 'taxon_name_rank_class')
          fill_autocomplete('parent_id_for_name', with: 'root', select: root.id)

          click_button('Create Taxon name')
          expect(page).to have_content("Taxon name 'Fooidae' was successfully created.")
        end

      end

      describe 'GET /taxon_names/list' do
        before { visit list_taxon_names_path }
        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /taxon_names/n' do
        before { visit taxon_name_path(TaxonName.second) }
        it_behaves_like 'a_data_model_with_standard_show'

        it 'should have a taxon name hierarchy list' do
          within(:xpath,'//*[@id="show_taxon_name_hierarchy"]') do
            expect(page).to have_link('Root', href: taxon_name_path(TaxonName.first))
          end
        end
      end
    end

  end
end




