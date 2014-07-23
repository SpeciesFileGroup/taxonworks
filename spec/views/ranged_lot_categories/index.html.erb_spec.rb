require 'rails_helper'

describe "ranged_lot_categories/index", :type => :view do
  before(:each) do
    assign(:ranged_lot_categories, [
      stub_model(RangedLotCategory,
        :name => "Name",
        :minimum_value => 1,
        :maximum_value => 2,
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      ),
      stub_model(RangedLotCategory,
        :name => "Name",
        :minimum_value => 1,
        :maximum_value => 2,
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      )
    ])
  end

  it "renders a list of ranged_lot_categories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
