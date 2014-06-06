require 'spec_helper'

describe "tags/new" do
  before(:each) do
    assign(:tag, stub_model(Tag,
      :keyword_id => 1,
      :tag_object_id => 1,
      :tag_object_type => "MyString",
      :tag_object_attribute => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :position => 1
    ).as_new_record)
  end

  it "renders new tag form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tags_path, "post" do
      assert_select "input#tag_keyword_id[name=?]", "tag[keyword_id]"
      assert_select "input#tag_tag_object_id[name=?]", "tag[tag_object_id]"
      assert_select "input#tag_tag_object_type[name=?]", "tag[tag_object_type]"
      assert_select "input#tag_tag_object_attribute[name=?]", "tag[tag_object_attribute]"
      # assert_select "input#tag_created_by_id[name=?]", "tag[created_by_id]"
      # assert_select "input#tag_updated_by_id[name=?]", "tag[updated_by_id]"
      # assert_select "input#tag_project_id[name=?]", "tag[project_id]"
      # assert_select "input#tag_position[name=?]", "tag[position]"
    end
  end
end
