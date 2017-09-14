require 'rails_helper'

describe 'tasks/import/dwca/psu_import', type: :feature, group: [:collection_objects] do
  context 'with test file' do
    let(:page_title) {'Import Penn State DWCA'}
    let(:index_path) {psu_import_task_path}

    it_behaves_like 'a_login_required_and_project_selected_controller'

    after(:all) {clean_slate_geo}

    context 'signed in as a user' do
      before(:each) {
        sign_in_user_and_select_project
      }

      describe 'triggering the import process', js: true, resolution: true do

        before do
          @ns1 = FactoryGirl.create(:valid_namespace, creator: @user, updater: @user)
          @ns2 = FactoryGirl.create(:valid_namespace, creator: @user, updater: @user, short_name: 'PSUC_FEM')
          visit(index_path)
        end

        # TODO: Add some more tests...
        it 'displays a page with which to interact' do
          # fill_autocomplete('dwca_namespace', with: @ns2.short_name, select: @ns2.id)
          # wait_for_ajax
          expect(page).to have_button('import')
        end # dwca_namespace
      end
    end
  end
end


