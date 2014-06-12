require 'spec_helper'

describe "citations/edit" do
  before(:each) do
    @citation = assign(:citation, stub_model(Citation,
      :citation_object_id => "MyString",
      :citation_object_type => "MyString",
      :source_id => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit citation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", citation_path(@citation), "post" do
      assert_select "input#citation_citation_object_id[name=?]", "citation[citation_object_id]"
      assert_select "input#citation_citation_object_type[name=?]", "citation[citation_object_type]"
      assert_select "input#citation_source_id[name=?]", "citation[source_id]"
      assert_select "input#citation_created_by_id[name=?]", "citation[created_by_id]"
      assert_select "input#citation_updated_by_id[name=?]", "citation[updated_by_id]"
      assert_select "input#citation_project_id[name=?]", "citation[project_id]"
    end
  end
end
