require 'spec_helper'

describe "data_attributes/index" do
  before(:each) do
    assign(:data_attributes, [
      stub_model(DataAttribute),
      stub_model(DataAttribute)
    ])
  end

  it "renders a list of data_attributes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
