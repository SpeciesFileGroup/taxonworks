require 'rails_helper'

describe 'geographic_items/show', :type => :view do
  before(:each) do
    @geographic_item = assign(:geographic_item,
                              stub_model(GeographicItem,
                                         :point               => ROOM2024,
                                         :line_string         => nil,
                                         :polygon             => nil,
                                         :multi_point         => nil,
                                         :multi_line_string   => nil,
                                         :multi_polygon       => nil,
                                         :geometry_collection => nil,
                                         :created_by_id       => 1,
                                         :updated_by_id       => 2
                              ))
  end

  it "renders attributes in <p>" do
    # skip 'reconstruction of the geographic_items/show view or spec'
    render
# Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
