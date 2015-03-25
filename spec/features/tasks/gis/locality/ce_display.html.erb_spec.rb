require 'rails_helper'
describe "tasks/gis/locality/ce_display.html.erb", type: :feature, group: :geo do

  before {
    sign_in_user_and_select_project
  }

  context 'with two close by collecting events' do
    let!(:collecting_event) { CollectingEvent.create!(verbatim_latitude: '10', verbatim_longitude: '10', by: @user, project: @project, with_verbatim_data_georeference: true ) }  
    let!(:other_collecting_event) { CollectingEvent.create!(verbatim_latitude: '10.001', verbatim_longitude: '10', by: @user, project: @project, with_verbatim_data_georeference: true )  }

    specify 'the collecting_events_nearby partial renders' do
      visit (nearby_locality_task_path(collecting_event))
      expect(page).to have_content(/Task: Nearby localities/)
    end

  end
end
