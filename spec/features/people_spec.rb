require 'rails_helper'

describe 'People', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
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

  describe 'GET /people/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_person) }
      visit '/people/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing People'
    end
  end

  describe 'GET /people/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_person) }
      all_people = Person.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/people/#{all_people[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end
  end
end

