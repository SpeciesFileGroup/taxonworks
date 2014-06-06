require 'spec_helper'

describe "citations/index" do
  before(:each) do
    assign(:citations, [
      stub_model(Citation),
      stub_model(Citation)
    ])
  end

  it "renders a list of citations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
