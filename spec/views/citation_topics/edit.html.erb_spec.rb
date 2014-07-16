require 'rails_helper'

describe "citation_topics/edit" do
  before(:each) do
    @citation_topic = assign(:citation_topic, stub_model(CitationTopic,
      :topic_id => 1,
      :citation_id => 1,
      :pages => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit citation_topic form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", citation_topic_path(@citation_topic), "post" do
      assert_select "input#citation_topic_topic_id[name=?]", "citation_topic[topic_id]"
      assert_select "input#citation_topic_citation_id[name=?]", "citation_topic[citation_id]"
      assert_select "input#citation_topic_pages[name=?]", "citation_topic[pages]"
      # assert_select "input#citation_topic_created_by_id[name=?]", "citation_topic[created_by_id]"
      # assert_select "input#citation_topic_updated_by_id[name=?]", "citation_topic[updated_by_id]"
      # assert_select "input#citation_topic_project_id[name=?]", "citation_topic[project_id]"
    end
  end
end
