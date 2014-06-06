require 'spec_helper'

describe "citation_topics/index" do
  before(:each) do
    assign(:citation_topics, [
      stub_model(CitationTopic),
      stub_model(CitationTopic)
    ])
  end

  it "renders a list of citation_topics" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
