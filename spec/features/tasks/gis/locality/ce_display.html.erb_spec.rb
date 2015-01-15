require 'rails_helper'

describe "tasks/gis/locality/ce_display.html.erb", :type => :feature do

  before(:each) do
    sign_in_user_and_select_project
    generate_ce_test_objects
  end

  after(:each) do
    clean_slate_geo
  end

  it 'renders the collecting_events_nearby partial' do
    @collecting_event = @ce_p1
    # this triggers 'nearby', which renders ce_display
    visit ("tasks/gis/locality/nearby/#{@collecting_event.id}")
    expect(page).to have_content(/Task: Nearby localities/)
  end

end
