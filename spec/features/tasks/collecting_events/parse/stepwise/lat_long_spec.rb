require 'rails_helper'

describe '/tasks/collecting_events/parse/stepwise/lat_long', type: :feature, group: [:collecting_events] do
  context 'with one collecting event presented' do
    let(:page_title) { 'not sure what it will be' }
    let(:index_path) { collecting_event_lat_long_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before {
        sign_in_user_and_select_project
      }

      context 'with some records created' do

      end
    end
  end
end
