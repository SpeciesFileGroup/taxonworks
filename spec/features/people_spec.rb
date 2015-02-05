require 'rails_helper'

describe 'People', :type => :feature do

  it_behaves_like 'a_login_required_controller' do 
    let(:index_path) { people_path }
    let(:page_index_name) { 'People' }
  end

  describe 'GET /people' do
    before { 
      sign_in_user_and_select_project 
      visit people_path }
    specify 'an index name is present' do
      expect(page).to have_content('People')
    end
  end

  context 'signed in as user, with some people created' do

    before do
      sign_in_user_and_select_project
      5.times { factory_girl_create_for_user(:valid_person, @user) }
    end

    describe 'GET /people/list' do
      before do
        visit list_people_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing people'
      end
    end

    describe 'GET /people/n' do
      before {
        visit person_path Person.second
      }

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end
    end
  end

  context 'creating a new person' do
    before {
      sign_in_user_and_select_project
      visit people_path       # when I visit the people_path
    }
    specify 'people_path should have a new link' do
      expect(page).to have_link('New') # it has a new link

    end
    specify 'adding the new person' do
      click_link('New') # when I click the new link

      choose('person_type_personvetted')# and I select the radio button 'vetted'
      fill_in('Last name', with: 'Wombat')# and I fill out the last name field with "Wombat"
      fill_in('First name', with: 'Hieronymus')# and I fill out the first name field with "Hieronymus"
      click_button('Create Person')# when I click the 'Create Person' button
      # then I get the message "Person 'Hieronymus Wombat' was successfully created."
      expect(page).to have_content("Person 'Hieronymus Wombat' was successfully created.")
     end
  end
end

