require 'rails_helper'

describe "tasks/gis/locality/gi_display.html.erb", :type => :feature do

  before(:each) do
    sign_in_user_and_select_project
    generate_ce_test_objects
  end

  after(:each) do
    clean_slate_geo
  end

  it 'renders the geographic_areas_within partial' do
    @collecting_event = @ce_p1
    @geographic_item  = @collecting_event.georeferences.first.error_geographic_item
    # this triggers 'Collecting events within', which renders gi_display
    visit (within_locality_task_path(@geographic_item.id))
    expect(page).to have_content(/Task: Localities contained within area/)
  end

end
