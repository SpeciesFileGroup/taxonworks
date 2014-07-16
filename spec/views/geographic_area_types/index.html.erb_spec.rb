require 'rails_helper'

describe "geographic_area_types/index" do
  before(:each) do
    assign(:geographic_area_types, [
      stub_model(GeographicAreaType,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      stub_model(GeographicAreaType,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of geographic_area_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
