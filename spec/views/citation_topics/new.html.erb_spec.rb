require 'spec_helper'

describe "citation_topics/new" do
  before(:each) do
    assign(:citation_topic, stub_model(CitationTopic).as_new_record)
  end

  it "renders new citation_topic form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", citation_topics_path, "post" do
    end
  end
end
