require 'spec_helper'

describe "public_contents/new" do
  before(:each) do
    assign(:public_content, stub_model(PublicContent,
      :otu_id => 1,
      :topic_id => 1,
      :text => "MyText",
      :project_id => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :content_id => 1
    ).as_new_record)
  end

  it "renders new public_content form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", public_contents_path, "post" do
      assert_select "input#public_content_otu_id[name=?]", "public_content[otu_id]"
      assert_select "input#public_content_topic_id[name=?]", "public_content[topic_id]"
      assert_select "textarea#public_content_text[name=?]", "public_content[text]"
      assert_select "input#public_content_project_id[name=?]", "public_content[project_id]"
      assert_select "input#public_content_created_by_id[name=?]", "public_content[created_by_id]"
      assert_select "input#public_content_updated_by_id[name=?]", "public_content[updated_by_id]"
      assert_select "input#public_content_content_id[name=?]", "public_content[content_id]"
    end
  end
end
