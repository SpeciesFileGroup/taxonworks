require 'spec_helper'

describe "ranged_lot_categories/edit" do
  before(:each) do
    @ranged_lot_category = assign(:ranged_lot_category, stub_model(RangedLotCategory))
  end

  it "renders the edit ranged_lot_category form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", ranged_lot_category_path(@ranged_lot_category), "post" do
    end
  end
end
