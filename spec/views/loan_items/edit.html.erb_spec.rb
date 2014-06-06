require 'spec_helper'

describe "loan_items/edit" do
  before(:each) do
    @loan_item = assign(:loan_item, stub_model(LoanItem))
  end

  it "renders the edit loan_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", loan_item_path(@loan_item), "post" do
    end
  end
end
