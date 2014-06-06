require 'spec_helper'

describe "citations/show" do
  before(:each) do
    @citation = assign(:citation, stub_model(Citation))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
