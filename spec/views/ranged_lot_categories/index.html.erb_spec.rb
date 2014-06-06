require 'spec_helper'

describe "ranged_lot_categories/index" do
  before(:each) do
    assign(:ranged_lot_categories, [
      stub_model(RangedLotCategory),
      stub_model(RangedLotCategory)
    ])
  end

  it "renders a list of ranged_lot_categories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
