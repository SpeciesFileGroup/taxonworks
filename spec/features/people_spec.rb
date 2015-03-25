require 'rails_helper'

describe 'People', :type => :feature do
  let(:page_index_name) { 'people' }
  let(:index_path) { people_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as user, with some records created' do
    before do
      sign_in_user_and_select_project
      5.times { factory_girl_create_for_user(:valid_person, @user) }
    end

    describe 'GET /people' do
      before {
        visit people_path
      }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /people/list' do
      before do
        visit list_people_path
      end

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /people/n' do
      before {
        visit person_path Person.second
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'creating a new person' do
    before {
      sign_in_user_and_select_project
      visit people_path # when I visit the people_path
    }
    specify 'people_path should have a new link' do
      expect(page).to have_link('new') # it has a new link

    end
    specify 'adding the new person' do
      click_link('new') # when I click the new link

      choose('person_type_personvetted') # and I select the radio button 'vetted'
      fill_in('Last name', with: 'Wombat') # and I fill out the last name field with "Wombat"
      fill_in('First name', with: 'Hieronymus') # and I fill out the first name field with "Hieronymus"
      click_button('Create Person') # when I click the 'Create Person' button
      # then I get the message "Person 'Hieronymus Wombat' was successfully created."
      expect(page).to have_content("Person 'Hieronymus Wombat' was successfully created.")
    end
  end
end

