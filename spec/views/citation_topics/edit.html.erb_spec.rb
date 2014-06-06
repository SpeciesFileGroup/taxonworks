require 'spec_helper'

describe "citation_topics/edit" do
  before(:each) do
    @citation_topic = assign(:citation_topic, stub_model(CitationTopic))
  end

  it "renders the edit citation_topic form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", citation_topic_path(@citation_topic), "post" do
    end
  end
end
