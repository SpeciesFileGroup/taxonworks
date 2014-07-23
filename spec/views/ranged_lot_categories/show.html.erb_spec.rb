require 'rails_helper'

describe "ranged_lot_categories/show", :type => :view do
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
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
  end
end
