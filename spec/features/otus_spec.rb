require 'rails_helper'

describe 'Otus', type: :feature do
  let(:index_path) { otus_path }
  let(:page_title) { 'Otus' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before do
      # TODO: Fix occasional "Capybara::ElementNotFound: Unable to find field "session_email" with id session_email"
      sign_in_user_and_select_project

      @user.generate_api_access_token
      @user.save!
    end

    context 'with some records created' do
      let!(:o1) { Otu.create!(name: 'one', by: @user, project: @project) }
      let!(:o2) { Otu.create!(name: 'two', by: @user, project: @project) }
      let!(:otu) { Otu.create(name: 'Find me', by: @user, project: @project) }

      context 'GET /otus' do
        before { visit index_path }
        it_behaves_like 'a_data_model_with_standard_index'

        specify 'that it has an AJAX autocomplete box', js: true do
          select_text = 'Select a otu'
          expect(page).to have_field(select_text) # TODO: inflect
          fill_in(select_text, with: 'a')
        end

      end

      describe 'GET /otus/list' do
        before { visit list_otus_path }
        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /otus/n' do
        before { visit otu_path(Otu.second) }
        it_behaves_like 'a_data_model_with_standard_show'
      end

      context 'creating a new OTU' do
        specify 'I can exercise the new link feature' do
          visit otus_path
          click_link('New')
          fill_in 'Name', with: 'test'
          click_button 'Create Otu'
          expect(page).to have_content("Otu 'test' was successfully created.")
        end
      end

      context 'downloading OTU table', js: true do
        let!(:csv) { Export::Download.generate_csv(Otu.where(project_id: @project.id)) }

        specify 'otus table can be downloaded as-is' do
          visit otus_path
          click_link('Download')
          expect(Features::Downloads::download_content).to eq(csv)
        end
      end
    end

    context 'batch load', js: false do
      context 'data_attributes for otus' do
        let(:file) { 'spec/files/batch/otu/da_ph_2.tsv' }
        let(:upload_file) { Rack::Test::UploadedFile.new(file) }

        specify 'find right section' do
          visit batch_load_otus_path
          expect(page).to have_content('Data Attributes batch load')
        end

        specify 'preview' do
          visit batch_load_otus_path
          attach_file('da_file', Rails.root + file)
          click_button('da_preview')
          expect(page).to have_content("No OTU with name 'Taxonmatchidae' exists.")
        end

        specify 'create' do
          visit batch_load_otus_path
          attach_file('da_file', Rails.root + file)
          click_button('da_preview')
          attach_file('da_file', Rails.root + file)
          click_button('da_create')
          expect(page).to have_content("No OTU with name 'Taxonmatchidae' exists.")
        end

        context 'control interaction' do
          before do
            visit batch_load_otus_path
            attach_file('da_file', Rails.root + file)
          end

          context 'select' do
            context 'defaults' do
              specify 'internal' do
                click_button('da_preview')
                expect(page).to have_content('Creating internal attributes.')
              end

              specify 'otus' do
                click_button('da_preview')
                expect(page).to have_content('Creating new otus')
              end

              specify 'predicates' do
                click_button('da_preview')
                expect(page).to have_content('Creating new predicates')
              end
            end

            context 'non-defaults' do
              specify 'import' do
                choose('type_select_import')
                click_button('da_preview')
                expect(page).to have_content('Creating import attributes.')
              end

              specify 'otus' do
                uncheck('create_new_otu')
                click_button('da_preview')
                expect(page).to have_content('Not creating new otus.')
              end

              specify 'predicates' do
                uncheck('create_new_predicate')
                click_button('da_preview')
                expect(page).to have_content('Not creating new predicates.')
              end
            end
          end
        end
      end
    end
  end
end
