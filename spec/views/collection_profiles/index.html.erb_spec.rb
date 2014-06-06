require 'spec_helper'

describe "collection_profiles/index" do
  before(:each) do
    assign(:collection_profiles, [
      stub_model(CollectionProfile),
      stub_model(CollectionProfile)
    ])
  end

  it "renders a list of collection_profiles" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
