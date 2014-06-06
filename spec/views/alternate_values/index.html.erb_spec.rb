require 'spec_helper'

describe "alternate_values/index" do
  before(:each) do
    assign(:alternate_values, [
      stub_model(AlternateValue),
      stub_model(AlternateValue)
    ])
  end

  it "renders a list of alternate_values" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
