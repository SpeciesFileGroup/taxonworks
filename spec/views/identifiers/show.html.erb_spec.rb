require 'rails_helper'

describe "identifiers/show" do
  before(:each) do
    @identifier = assign(:identifier, stub_model(Identifier,
      :identified_object_id => 1,
      :identified_object_type => "Identified Object Type",
      :identifier => "Identifier",
      :type => "Type",
      :cached_identifier => "Cached Identifier",
      :namespace_id => 2,
      :created_by_id => 3,
      :updated_by_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Identified Object Type/)
    rendered.should match(/Identifier/)
    rendered.should match(/Type/)
    rendered.should match(/Cached Identifier/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
