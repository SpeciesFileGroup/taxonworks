require 'spec_helper'

describe "citation_topics/index" do
  before(:each) do
    assign(:citation_topics, [
      stub_model(CitationTopic,
        :topic_id => 1,
        :citation_id => 2,
        :pages => "Pages",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      ),
      stub_model(CitationTopic,
        :topic_id => 1,
        :citation_id => 2,
        :pages => "Pages",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      )
    ])
  end

  it "renders a list of citation_topics" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Pages".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
