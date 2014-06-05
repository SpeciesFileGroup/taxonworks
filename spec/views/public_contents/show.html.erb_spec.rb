require 'spec_helper'

describe "public_contents/show" do
  before(:each) do
    @public_content = assign(:public_content, stub_model(PublicContent))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
