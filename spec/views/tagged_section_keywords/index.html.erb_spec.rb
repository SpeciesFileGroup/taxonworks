require 'spec_helper'

describe "tagged_section_keywords/index" do
  before(:each) do
    assign(:tagged_section_keywords, [
      stub_model(TaggedSectionKeyword),
      stub_model(TaggedSectionKeyword)
    ])
  end

  it "renders a list of tagged_section_keywords" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
