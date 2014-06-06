require 'spec_helper'

describe "alternate_values/show" do
  before(:each) do
    @alternate_value = assign(:alternate_value, stub_model(AlternateValue))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
