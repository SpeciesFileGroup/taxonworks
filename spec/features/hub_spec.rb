require 'rails_helper'

describe 'Hub', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { hub_path }
    let(:page_index_name) { 'Hub' }
  end 

  subject { page }

  describe '/hub' do
    before {
      sign_in_user_and_select_project
      visit hub_path
    }

    it 'should have a hub title' do
      expect(page).to have_selector('h1', text: 'Hub')
      expect(subject).to have_selector('h1', text: 'Hub')
    end

  end
end
