require 'spec_helper'

describe "loan_items/new" do
  before(:each) do
    assign(:loan_item, stub_model(LoanItem).as_new_record)
  end

  it "renders new loan_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", loan_items_path, "post" do
    end
  end
end
