require 'spec_helper'

describe "collection_profiles/edit" do
  before(:each) do
    @collection_profile = assign(:collection_profile, stub_model(CollectionProfile))
  end

  it "renders the edit collection_profile form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", collection_profile_path(@collection_profile), "post" do
    end
  end
end
