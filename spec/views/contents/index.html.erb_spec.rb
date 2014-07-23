require 'rails_helper'

describe "contents/index", :type => :view do
  before(:each) do
    assign(:contents, [
      stub_model(Content,
        :text => "MyText",
        :otu_id => 1,
        :topic_id => 2,
        :type => "Type",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :revision_id => 6
      ),
      stub_model(Content,
        :text => "MyText",
        :otu_id => 1,
        :topic_id => 2,
        :type => "Type",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :revision_id => 6
      )
    ])
  end

  it "renders a list of contents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
