require 'spec_helper'

describe "loans/index" do
  before(:each) do
    assign(:loans, [
      stub_model(Loan),
      stub_model(Loan)
    ])
  end

  it "renders a list of loans" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
