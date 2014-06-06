require 'spec_helper'

describe "loan_items/index" do
  before(:each) do
    assign(:loan_items, [
      stub_model(LoanItem),
      stub_model(LoanItem)
    ])
  end

  it "renders a list of loan_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
