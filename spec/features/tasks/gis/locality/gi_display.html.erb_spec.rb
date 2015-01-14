require 'rails_helper'

describe "tasks/gis/locality/gi_display.html.erb", :type => :feature do

  before(:all) do
    sign_in_user_and_select_project
    generate_ce_test_objects
  end

  after(:all) do
    clean_slate_geo
  end

  it 'renders the collecting_events_nearby partial' do
    @collecting_event = @ce_p1
    @geographic_item  = @collecting_event.georeferences.first.error_geographic_item
    visit ("tasks/gis/locality/within/#{@geographic_item.id}")
    expect(page).to have_content(/Task: Contained within/)
  end

end
