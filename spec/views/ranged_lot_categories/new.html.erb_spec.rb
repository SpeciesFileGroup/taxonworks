require 'spec_helper'

describe "ranged_lot_categories/new" do
  before(:each) do
    assign(:ranged_lot_category, stub_model(RangedLotCategory).as_new_record)
  end

  it "renders new ranged_lot_category form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", ranged_lot_categories_path, "post" do
    end
  end
end
