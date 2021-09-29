require 'rails_helper'

describe 'CollectionObjects', type: :feature do
  let(:index_path) { collection_objects_path }
  let(:page_title) { 'Collection objects' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created', js: true do
    before do 
      sign_in_user_and_select_project
      3.times { factory_bot_create_for_user_and_project(:valid_specimen, @user, @project) }
    end 

    describe 'GET /collection_objects' do
      before { visit collection_objects_path }
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
        click_link('New') 
        fill_in 'Total', with: '1' 
        fill_in 'Buffered collecting event', with: 'This is a label.\nAnd another line.'
        click_button 'Create Collection object' 
        expect(page).to have_content('Collection object was successfully created.')
      end
    end

    context 'batch load', js: true do
      context 'collection objects from buffered strings' do
        let(:file) { 'spec/files/batch/collection_object/co_from_strings.tsv' }
        let(:upload_file) { Rack::Test::UploadedFile.new(file) }

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
                  o = factory_bot_create_for_user_and_project(:valid_otu, @user, @project) 
                  fill_autocomplete('otu_id_for_specimen_batchload', with: o.name, select: o.id)
                  click_button('buf_preview')
                  expect(page).to have_content("Using '#{o.name}' as OTU.")
                end

                specify 'source' do
                  s = FactoryBot.create(:valid_source, by: @user)
                  fill_autocomplete('source_id_for_specimen_batchload', with: s.cached, select: s.id)
                  click_button('buf_preview')
                  expect(page).to have_content("Using '#{s.cached.gsub('<i>','').gsub('</i>', '')}' as source.")
                end
              end
            end
          end
        end
      end
    end
  end
end
