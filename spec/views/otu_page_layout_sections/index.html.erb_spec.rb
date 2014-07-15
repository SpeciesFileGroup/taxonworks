require 'spec_helper'

describe "otu_page_layout_sections/index" do
  before(:each) do
    assign(:otu_page_layout_sections, [
      stub_model(OtuPageLayoutSection,
        :otu_page_layout_id => 1,
        :type => "Type",
        :position => 2,
        :topic_id => 3,
        :dynamic_content_class => "Dynamic Content Class",
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      ),
      stub_model(OtuPageLayoutSection,
        :otu_page_layout_id => 1,
        :type => "Type",
        :position => 2,
        :topic_id => 3,
        :dynamic_content_class => "Dynamic Content Class",
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      )
    ])
  end

  it "renders a list of otu_page_layout_sections" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Dynamic Content Class".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
