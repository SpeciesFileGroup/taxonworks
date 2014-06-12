require 'spec_helper'

describe "ranged_lot_categories/show" do
  before(:each) do
    @ranged_lot_category = assign(:ranged_lot_category, stub_model(RangedLotCategory,
      :name => "Name",
      :minimum_value => 1,
      :maximum_value => 2,
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
  end
end
