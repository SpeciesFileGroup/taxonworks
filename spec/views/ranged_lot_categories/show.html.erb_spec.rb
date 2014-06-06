require 'spec_helper'

describe "ranged_lot_categories/show" do
  before(:each) do
    @ranged_lot_category = assign(:ranged_lot_category, stub_model(RangedLotCategory))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
