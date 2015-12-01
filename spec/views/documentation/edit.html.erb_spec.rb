require 'rails_helper'

RSpec.describe "documentation/edit", type: :view do
  before(:each) do
    @documentation = assign(:documentation, Documentation.create!(
      :documentation_object => nil,
      :document => nil,
      :page_map => "",
      :project => nil,
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit documentation form" do
    render

    assert_select "form[action=?][method=?]", documentation_path(@documentation), "post" do

      assert_select "input#documentation_documentation_object_id[name=?]", "documentation[documentation_object_id]"

      assert_select "input#documentation_document_id[name=?]", "documentation[document_id]"

      assert_select "input#documentation_page_map[name=?]", "documentation[page_map]"

      assert_select "input#documentation_project_id[name=?]", "documentation[project_id]"

      assert_select "input#documentation_created_by_id[name=?]", "documentation[created_by_id]"

      assert_select "input#documentation_updated_by_id[name=?]", "documentation[updated_by_id]"
    end
  end
end
