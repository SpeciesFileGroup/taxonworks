require 'rails_helper'

describe "identifiers/index" do
  before(:each) do
    assign(:identifiers, [
      stub_model(Identifier,
        :identified_object_id => 1,
        :identified_object_type => "Identified Object Type",
        :identifier => "Identifier",
        :type => "Type",
        :cached_identifier => "Cached Identifier",
        :namespace_id => 2,
        :created_by_id => 3,
        :updated_by_id => 4
      ),
      stub_model(Identifier,
        :identified_object_id => 1,
        :identified_object_type => "Identified Object Type",
        :identifier => "Identifier",
        :type => "Type",
        :cached_identifier => "Cached Identifier",
        :namespace_id => 2,
        :created_by_id => 3,
        :updated_by_id => 4
      )
    ])
  end

  it "renders a list of identifiers" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Identified Object Type".to_s, :count => 2
    assert_select "tr>td", :text => "Identifier".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Identifier".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
