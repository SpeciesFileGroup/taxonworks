require 'rails_helper'

describe 'CollectingEvents' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { collecting_events_path }
    let(:page_index_name) { 'Collecting Events' }
  end

  describe 'GET /collecting_events' do
    before { 
      sign_in_valid_user_and_select_project 
      visit collecting_events_path }
    specify 'a index name is present' do
      expect(page).to have_content('Collecting Events')
    end
  end
end
