require 'rails_helper'

describe "contents/new" do
  before(:each) do
    assign(:content, stub_model(Content,
      :text => "MyText",
      :otu_id => 1,
      :topic_id => 1,
      :type => "",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :revision_id => 1
    ).as_new_record)
  end

  it "renders new content form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", contents_path, "post" do
      assert_select "textarea#content_text[name=?]", "content[text]"
      assert_select "input#content_otu_id[name=?]", "content[otu_id]"
      assert_select "input#content_topic_id[name=?]", "content[topic_id]"
      assert_select "input#content_type[name=?]", "content[type]"
      # assert_select "input#content_created_by_id[name=?]", "content[created_by_id]"
      # assert_select "input#content_updated_by_id[name=?]", "content[updated_by_id]"
      # assert_select "input#content_project_id[name=?]", "content[project_id]"
      assert_select "input#content_revision_id[name=?]", "content[revision_id]"
    end
  end
end
