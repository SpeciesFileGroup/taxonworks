require 'spec_helper'

describe "tagged_section_keywords/edit" do
  before(:each) do
    @tagged_section_keyword = assign(:tagged_section_keyword, stub_model(TaggedSectionKeyword))
  end

  it "renders the edit tagged_section_keyword form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tagged_section_keyword_path(@tagged_section_keyword), "post" do
    end
  end
end
