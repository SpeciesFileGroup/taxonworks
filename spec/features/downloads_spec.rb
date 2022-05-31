require 'rails_helper'

describe 'Downloads', type: :feature, group: [:downloads] do
  let(:index_path) { downloads_path }
  let(:page_title) { 'Downloads' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before {
      sign_in_user_and_select_project
      10.times { factory_bot_create_for_user_and_project(:valid_download, @user, @project) }
    }

    context 'with some records created' do
      describe 'GET /downloads' do
        before { visit downloads_path }

        it_behaves_like 'a_data_model_with_standard_index', true
      end

      describe 'GET /downloads/list' do
        before { visit list_downloads_path }

        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end
    end

    context 'with a non-expired download' do
      context 'when ready' do
        describe 'download' do
          let(:download) { Download.first }
          before { visit download_path(Download.first) }

          it 'displays status ready to download' do
            expect(page).to have_content('Status: Ready to download')
          end

          it 'allows file to be downloaded', js: true do
            click_button('Download')
            expect(Features::Downloads::download_content).to eq(File.read(download.file_path))
          end
        end
      end

      context 'when not ready' do
        let(:download) { factory_bot_create_for_user_and_project(:valid_download_no_file, @user, @project) }

        describe 'download' do
          before { visit download_path(download.id) }

          it 'displays status not ready' do
            expect(page).to have_content('Status: Download creation is in progress...')
          end

          it 'does not have a download link', js: true do
            expect(page).to_not have_link('Download', exact: true)
          end
        end
      end
    end

    context 'with a expired download' do
      let(:download) { factory_bot_create_for_user_and_project(:expired_download, @user, @project) }

      describe 'download' do
        before { visit download_path(download.id) }

        it 'displays status expired' do
          expect(page).to have_content('Status: Download has expired and cannot be downloaded')
        end

        it 'does not have a download link', js: true do
          expect(page).to_not have_link('Download', exact: true)
        end
      end
    end

  end
end
