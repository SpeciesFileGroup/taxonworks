require 'spec_helper'

describe "collection_objects/index" do
  before(:each) do
    assign(:collection_objects, [
      stub_model(CollectionObject,
        :total => 1,
        :type => "Type",
        :preparation_type_id => 2,
        :repository_id => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      ),
      stub_model(CollectionObject,
        :total => 1,
        :type => "Type",
        :preparation_type_id => 2,
        :repository_id => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      )
    ])
  end

  it "renders a list of collection_objects" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
