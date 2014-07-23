require 'rails_helper'

describe "identifiers/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Identified Object Type/)
    expect(rendered).to match(/Identifier/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Cached Identifier/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
