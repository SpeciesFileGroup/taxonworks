require 'rails_helper'

describe 'CollectionObjects', type: :feature do
  let(:index_path) { collection_objects_path }
  let(:page_title) { 'Collection objects' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_bot_create_for_user_and_project(:valid_specimen, @user, @project) }
      5.times { factory_bot_create_for_user_and_project(:valid_otu, @user, @project) }
      FactoryBot.create(:valid_otu, name: 'Find me', creator: @user, updater: @user, project: @project)
      Otu.last.update_column(:name, 'something_unmatchable 44')
      5.times { FactoryBot.create(:valid_source, by: @user) }
    }

    describe 'GET /collection_objects' do
      before {
        visit collection_objects_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /collection_objects/list' do
      before { visit list_collection_objects_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /collection_objects/n' do
      before {
        visit collection_object_path(CollectionObject.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end

    context 'creating a new collection object' do
      before {
        visit collection_objects_path # when I visit the collection_objects_path
      }

      specify 'follow the new link & create a new collection object' do
        click_link('New') # when I click the new link
        fill_in 'Total', with: '1' # fill out the total field with 1
        fill_in 'Buffered collecting event', with: 'This is a label.\nAnd another line.' # fill in Buffered collecting event
        click_button 'Create Collection object' # when I click the 'Create Collection object' button
        # then I get the message "Collecting objection was successfully created"
        expect(page).to have_content('Collection object was successfully created.')
      end
    end

    context 'batch load', js: true do
      context 'collection objects from buffered strings' do
        let(:file) { 'spec/files/batch/collection_object/co_from_strings.tsv' }
        let(:upload_file) { fixture_file_upload(file) }

        specify 'find right section' do
          visit batch_load_collection_objects_path
          expect(page).to have_content('Buffered strings batch load')
        end

        specify 'preview' do
          visit batch_load_collection_objects_path
          attach_file('buf_file', Rails.root + file)
          click_button('buf_preview')
          expect(page).to have_content('No strings provided for any buffered data.')
        end

        specify 'create' do
          visit batch_load_collection_objects_path
          attach_file('buf_file', Rails.root + file)
          click_button('buf_preview')
          attach_file('buf_file', Rails.root + file)
          click_button('buf_create')
          expect(page).to have_content('No strings provided for any buffered data.')
        end

        context 'control interaction' do
          before do
            visit batch_load_collection_objects_path
            attach_file('buf_file', Rails.root + file)
          end

          context 'select' do
            context 'defaults' do
              specify 'no otu, no source' do
                click_button('buf_preview')
                expect(page).to have_content('This is my collecting event.')
              end

              context 'non-defaults' do
                specify 'otu' do
                  o = Otu.last
                  fill_autocomplete('otu_id_for_specimen_batchload', with: o.name, select: o.id)
                  click_button('buf_preview')
                  expect(page).to have_content("Using 'something_unmatchable 44' as OTU.")
                end

                specify 'source' do
                  s = Source.last
                  s.title = 'Please FIND me!'
                  s.by = @user
                  s.save!
                  fill_autocomplete('source_id_for_specimen_batchload', with: s.cached, select: s.id)
                  click_button('buf_preview')
                  expect(page).to have_content("Using 'Anon (0AD) Please FIND me!' as source.")
                end
              end
            end
          end
        end
      end
    end
  end
end
