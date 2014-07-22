require 'rails_helper'

describe "citation_topics/show" do
  before(:each) do
    @citation_topic = assign(:citation_topic, stub_model(CitationTopic,
      :topic_id => 1,
      :citation_id => 2,
      :pages => "Pages",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Pages/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
  end
end
