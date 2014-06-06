require 'spec_helper'

describe "data_attributes/show" do
  before(:each) do
    @data_attribute = assign(:data_attribute, stub_model(DataAttribute))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
