require 'spec_helper'

describe "geographic_items/index" do
  before(:each) do
    assign(:geographic_items, [
      FactoryGirl.create(:geographic_item_with_polygon),
      FactoryGirl.create(:geographic_item_with_multi_polygon)
    ])
  end

  it 'renders a list of geographic_items' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers

    # assert_select 'tr>td', :text => 1.to_s, :count => 5
    assert_select 'tr>td', :text => 'POLYGON ((-32.0 21.0 0.0, -25.0 21.0 0.0, -25.0 16.0 0.0, -21.0 20.0 0.0, -32.0 21.0 0.0))', :count => 1
    assert_select 'tr>td', :text => 5.to_s, :count => 1
    assert_select 'tr>td', :text => 62.to_s, :count => 1
    # assert_select 'tr>td', :text => 2.to_s, :count => 1
  end
end
