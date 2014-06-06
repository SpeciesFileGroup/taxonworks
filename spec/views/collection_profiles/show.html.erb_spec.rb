require 'spec_helper'

describe "collection_profiles/show" do
  before(:each) do
    @collection_profile = assign(:collection_profile, stub_model(CollectionProfile))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
