require 'rails_helper'

describe 'tasks/import/dwca/psu_import', type: :feature, group: [:collection_objects] do
  context 'with test file' do
    let(:page_title) {'Import Penn State DWCA'}
    let(:index_path) {psu_import_task_path}

    it_behaves_like 'a_login_required_and_project_selected_controller'

    after(:all) {GeoBuild.clean_slate_geo}

    context 'signed in as a user' do
      before(:each) {
        sign_in_user_and_select_project
      }

      describe 'triggering the import process', js: true, resolution: true do

        before do
          @ns1 = FactoryBot.create(:valid_namespace, creator: @user, updater: @user)
          @ns2 = FactoryBot.create(:valid_namespace, creator: @user, updater: @user, short_name: 'PSUC_FEM')
          visit(index_path)
        end

        # TODO: Add some more tests...
        context 'ways to interact with the page' do

          it 'displays a page with which to interact' do
            expect(page).to have_button('import')
            select('PSUC', from: 'dwca_namespace')
            # s = find(:select, 'dwca_namespace')
            # s.send_keys("PSUC\t")
            expect(page).to have_text('PSUC_FEM')
            click_button('import')
            # find(:select)
            # fill_in('dwca_namespace', with: 'PS')
            # fill_autocomplete('dwca_namespace', with: @ns2.short_name, select: @ns2.id)
            # wait_for_ajax
            expect(page).to have_text('No file provided!')
          end # dwca_namespace

          it 'finds and upload a file' do
            f = find('#file')
            # f.text = './spec/files/batch/dwca/PSUC3-Test.utf8.txt'
            # expect(page).to have_text('PSUC3')
          end
        end
      end
    end
  end
end


