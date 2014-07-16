require 'rails_helper'

describe "citations/index" do
  before(:each) do
    assign(:citations, [
      stub_model(Citation,
        :citation_object_id => "Citation Object",
        :citation_object_type => "Citation Object Type",
        :source_id => 1,
        :created_by_id => 2,
        :updated_by_id => 3,
        :project_id => 4
      ),
      stub_model(Citation,
        :citation_object_id => "Citation Object",
        :citation_object_type => "Citation Object Type",
        :source_id => 1,
        :created_by_id => 2,
        :updated_by_id => 3,
        :project_id => 4
      )
    ])
  end

  it "renders a list of citations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Citation Object".to_s, :count => 2
    assert_select "tr>td", :text => "Citation Object Type".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
