require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the LoansHelper. For example:
#
# describe GeographicAreasHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe GeographicAreasHelper, :type => :helper do
  context 'a geographic_area needs some helpers' do
    before(:all) {
      @geographic_area      = FactoryGirl.create(:valid_geographic_area)
      @geographic_area_name = @geographic_area.name
    }

    specify '::geographic_area_tag' do
      expect(GeographicAreasHelper.geographic_area_tag(@geographic_area)).to eq(@geographic_area_name)
    end

    specify '#geographic_area_tag' do
      expect(geographic_area_tag(@geographic_area)).to eq(@geographic_area_name)
    end

    specify '#geographic_area_link' do
      expect(geographic_area_link(@geographic_area)).to have_link(@geographic_area_name)
    end

    specify "#geographic_area_search_form" do
      expect(geographic_areas_search_form).to have_button('Show')
      expect(geographic_areas_search_form).to have_field('geographic_area_id_for_quick_search_form')
    end

  end
end
