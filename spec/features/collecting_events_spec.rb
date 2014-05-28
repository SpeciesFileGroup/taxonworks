require 'spec_helper'

describe "CollectingEvents" do
  describe "GET /collecting_events" do
    before { visit collecting_events_path }
    specify 'a index name is present' do
      expect(page).to have_content('Collecting Events')
    end
  end
end
