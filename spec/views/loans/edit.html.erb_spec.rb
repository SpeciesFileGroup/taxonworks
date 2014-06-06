require 'spec_helper'

describe "loans/edit" do
  before(:each) do
    @loan = assign(:loan, stub_model(Loan))
  end

  it "renders the edit loan form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", loan_path(@loan), "post" do
    end
  end
end
