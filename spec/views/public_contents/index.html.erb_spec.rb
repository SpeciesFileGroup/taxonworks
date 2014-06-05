require 'spec_helper'

describe "public_contents/index" do
  before(:each) do
    assign(:public_contents, [
      stub_model(PublicContent),
      stub_model(PublicContent)
    ])
  end

  it "renders a list of public_contents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
