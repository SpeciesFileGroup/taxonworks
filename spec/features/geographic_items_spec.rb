require 'spec_helper'

describe "GeographicItems" do
  describe "GET /geographic_items" do
    before { visit geographic_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Items')
    end
  end
end





