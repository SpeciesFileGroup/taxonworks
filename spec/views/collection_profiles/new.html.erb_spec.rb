require 'spec_helper'

describe "collection_profiles/new" do
  before(:each) do
    assign(:collection_profile, stub_model(CollectionProfile).as_new_record)
  end

  it "renders new collection_profile form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", collection_profiles_path, "post" do
    end
  end
end
