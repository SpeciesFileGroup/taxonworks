require 'rails_helper'


describe GeographicAreasHelper, :type => :helper do
  context 'a geographic_area needs some helpers' do

    let(:name) {"Neverland"}
    let(:geographic_area) {FactoryGirl.create(:valid_geographic_area, name:name)}

    specify '#geographic_area_tag' do
      expect(helper.geographic_area_tag(geographic_area)).to eq(name)
    end

    specify '#geographic_area_link' do
      expect(helper.geographic_area_link(geographic_area)).to have_link(name)
    end

    specify "#geographic_area_search_form" do
      expect(helper.geographic_areas_search_form).to have_button('Show')
      expect(helper.geographic_areas_search_form).to have_field('geographic_area_id_for_quick_search_form')
    end

  end
end
