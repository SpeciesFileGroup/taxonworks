require 'rails_helper'

describe 'Otus', :type => :feature do
  let(:index_path) { otus_path }

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:page_index_name) { 'Otus' }
  end

  context 'signed in as a user' do
    before { sign_in_user_and_select_project } 

    context 'signed in as a user, with some records created' do
      before {
        10.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
        FactoryGirl.create(:valid_otu, name: 'Find me', creator: @user, updater: @user, project: @project)  
      }
  
      describe 'GET /otus' do
        before {
          visit otus_path
        }

        specify 'the features of an index page' do
          expect(page).to have_content('Otus')
          expect(page).to have_link('new')
          expect(page).to have_link('list')
          expect(page).to have_link('download')
        end

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

        specify 'that it renders without error' do
          expect(page).to have_content 'Listing Otus'
        end

        specify "there to be 'First', 'Prev', 'Next', and 'Last' links" do
          # click_link('Next')
          # expect(page).to have_link('First')
          # expect(page).to have_link('Prev')
          # expect(page).to have_link('Next')
          # expect(page).to have_link('Last')
        end

      end

      describe 'GET /otus/n' do
        before {
          visit otu_path(Otu.second)
        }

        specify 'there is a \'previous\' link' do
          expect(page).to have_link('Previous')
        end

        specify 'there is a \'next\' link' do
          expect(page).to have_link('Next')
        end
      end
    end

    context 'creating a new OTU' do
      specify 'I can exercise the new link feature' do
        visit otus_path                   # when I visit the otus_path
        expect(page).to have_link('new')  # it has a new link
        click_link('new')                 # when I click the new link
        fill_in 'Name', with: 'test'      # and I fill out the name field with "test"
        click_button 'Create Otu'         # and I click 'create otu'
        # then I get the message 'Otu 'test' was successfully created
        expect(page).to have_content("Otu 'test' was successfully created.")
      end

    end
  end
end
