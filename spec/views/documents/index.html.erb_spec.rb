require 'rails_helper'

RSpec.describe "documents/index", type: :view do
  before(:each) do
    assign(:documents, [
      Document.create!(
        :document_file => "",
        :project_references => "Project References",
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      Document.create!(
        :document_file => "",
        :project_references => "Project References",
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of documents" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Project References".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
