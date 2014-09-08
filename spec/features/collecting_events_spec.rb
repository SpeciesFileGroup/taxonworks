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

  describe 'GET /collecting_events/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_collecting_event) }
      visit '/collecting_events/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Collecting Events'
    end
  end

  describe 'GET /collecting_events/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_collecting_event) }
      all_collecting_events = CollectingEvent.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/collecting_events/#{all_collecting_events[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end
