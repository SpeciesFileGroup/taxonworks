require 'spec_helper'

describe "loans/show" do
  before(:each) do
    @loan = assign(:loan, stub_model(Loan))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
