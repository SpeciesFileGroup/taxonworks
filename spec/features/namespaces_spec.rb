require 'rails_helper'

describe 'Namespaces', :type => :feature do

  it_behaves_like 'an_administrator_login_required_controller' do
    let(:index_path) { namespaces_path }
    let(:page_index_name) { 'Namespaces' }
  end

  describe 'GET /Namespaces' do
    before do
      sign_in_administrator
      visit namespaces_path
    end
    
    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
  
  describe 'GET /namespaces/list' do
    before do
      sign_in_administrator_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of namespaces
      5.times { FactoryGirl.create(:valid_namespace) }
      visit '/namespaces/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Namespaces'
    end

  end

  describe 'GET /namespaces/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_namespace) }
      all_namespaces = Namespace.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/namespaces/#{all_namespaces[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end








