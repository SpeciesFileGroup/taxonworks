require 'spec_helper'

describe "tagged_section_keywords/new" do
  before(:each) do
    assign(:tagged_section_keyword, stub_model(TaggedSectionKeyword).as_new_record)
  end

  it "renders new tagged_section_keyword form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tagged_section_keywords_path, "post" do
    end
  end
end
