require 'rails_helper'

describe 'Otus', type: :feature do
  let(:index_path) { otus_path }
  let(:page_index_name) { 'otus' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before { sign_in_user_and_select_project }

    context 'with some records created' do
      before {
        10.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
        FactoryGirl.create(:valid_otu, name: 'Find me', creator: @user, updater: @user, project: @project)
      }

      context 'GET /otus' do
        before {
          visit index_path
        }

        it_behaves_like 'a_data_model_with_standard_index'

        specify 'that it has an AJAX autocomplete box', js: true do
          select_text = 'Select a otu'
          expect(page).to have_button('Show')
          expect(page).to have_field(select_text) # TODO: inflect
          fill_in(select_text, :with => 'a')
        end
      end

      describe 'GET /otus/list' do
        before do
          visit list_otus_path
        end

        it_behaves_like 'a_data_model_with_standard_list'
      end

      describe 'GET /otus/n' do
        before {
          visit otu_path(Otu.second)
        }

        it_behaves_like 'a_data_model_with_standard_show'
      end
    end

    context 'creating a new OTU' do
      specify 'I can exercise the new link feature' do
        visit otus_path # when I visit the otus_path
        expect(page).to have_link('new') # it has a new link
        click_link('new') # when I click the new link
        fill_in 'Name', with: 'test' # and I fill out the name field with "test"
        click_button 'Create Otu' # and I click 'create otu'
        # then I get the message 'Otu 'test' was successfully created
        expect(page).to have_content("Otu 'test' was successfully created.")
      end

    end
  end
end
