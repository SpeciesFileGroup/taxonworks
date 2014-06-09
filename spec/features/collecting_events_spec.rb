require 'spec_helper'

describe 'CollectingEvents', base_class: CollectingEvent do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /collecting_events' do
    before { visit collecting_events_path }
    specify 'a index name is present' do
      expect(page).to have_content('Collecting Events')
    end
  end
end
