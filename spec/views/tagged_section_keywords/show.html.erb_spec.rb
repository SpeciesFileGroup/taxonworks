require 'spec_helper'

describe "tagged_section_keywords/show" do
  before(:each) do
    @tagged_section_keyword = assign(:tagged_section_keyword, stub_model(TaggedSectionKeyword))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
