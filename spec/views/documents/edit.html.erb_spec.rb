require 'rails_helper'

RSpec.describe "documents/edit", type: :view do
  before(:each) do
    @document = assign(:document, Document.create!(
      :document_file => "",
      :project_references => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit document form" do
    render

    assert_select "form[action=?][method=?]", document_path(@document), "post" do

      assert_select "input#document_document_file[name=?]", "document[document_file]"

      assert_select "input#document_project_references[name=?]", "document[project_references]"

      assert_select "input#document_created_by_id[name=?]", "document[created_by_id]"

      assert_select "input#document_updated_by_id[name=?]", "document[updated_by_id]"
    end
  end
end
