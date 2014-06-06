require 'spec_helper'

describe "loan_items/show" do
  before(:each) do
    @loan_item = assign(:loan_item, stub_model(LoanItem))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
