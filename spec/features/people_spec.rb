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
end

