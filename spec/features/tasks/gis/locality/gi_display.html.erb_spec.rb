require 'rails_helper'

describe "tasks/gis/locality/gi_display.html.erb", type: :feature, group: :geo do

  before {
      sign_in_user_and_select_project
    }
   

  context 'with two close by collecting events' do
   let!(:collecting_event) { CollectingEvent.create!(verbatim_latitude: '10', verbatim_longitude: '10', by: @user, project: @project, with_verbatim_data_georeference: true ) }  
    let!(:other_collecting_event) { CollectingEvent.create!(verbatim_latitude: '10.001', verbatim_longitude: '10', by: @user, project: @project, with_verbatim_data_georeference: true )  }

    specify 'the geographic_areas_within partial is rendered' do
      #   @collecting_event = @ce_p1
      #   @geographic_item  = @collecting_event.georeferences.first.error_geographic_item
      # this triggers 'Collecting events within', which renders gi_display
      visit (within_locality_task_path(collecting_event.georeferences.first.geographic_item))
      expect(page).to have_content(/Task: Localities contained within area/)
    end
  end

end
