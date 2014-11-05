require 'rails_helper'

describe 'CollectingEvents', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { collecting_events_path }
    let(:page_index_name) { 'Collecting Events' }
  end

  describe 'GET /collecting_events' do
    before { 
      sign_in_user_and_select_project
      visit collecting_events_path }

    specify 'a index name is present' do
      expect(page).to have_content('Collecting Events')
    end
  end

  context 'signed in as a user, with some records created' do
    before {
    sign_in_user_and_select_project
     10.times { factory_girl_create_for_user_and_project(:valid_collecting_event, @user, @project) }
    }
 
  describe 'GET /collecting_events/list' do
    before do
      visit list_collecting_events_path
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Collecting Events'
    end
  end

  describe 'GET /collecting_events/n' do
    before {
      visit collecting_event_path(CollectingEvent.second)
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
