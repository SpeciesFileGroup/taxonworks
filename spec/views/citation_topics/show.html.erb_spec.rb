require 'spec_helper'

describe "citation_topics/show" do
  before(:each) do
    @citation_topic = assign(:citation_topic, stub_model(CitationTopic))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
