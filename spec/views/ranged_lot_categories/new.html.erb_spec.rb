require 'spec_helper'

describe "ranged_lot_categories/new" do
  before(:each) do
    assign(:ranged_lot_category, stub_model(RangedLotCategory,
      :name => "MyString",
      :minimum_value => 1,
      :maximum_value => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new ranged_lot_category form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", ranged_lot_categories_path, "post" do
      assert_select "input#ranged_lot_category_name[name=?]", "ranged_lot_category[name]"
      assert_select "input#ranged_lot_category_minimum_value[name=?]", "ranged_lot_category[minimum_value]"
      assert_select "input#ranged_lot_category_maximum_value[name=?]", "ranged_lot_category[maximum_value]"
      assert_select "input#ranged_lot_category_created_by_id[name=?]", "ranged_lot_category[created_by_id]"
      assert_select "input#ranged_lot_category_updated_by_id[name=?]", "ranged_lot_category[updated_by_id]"
      assert_select "input#ranged_lot_category_project_id[name=?]", "ranged_lot_category[project_id]"
    end
  end
end
