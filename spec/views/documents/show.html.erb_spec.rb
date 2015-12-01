require 'rails_helper'

RSpec.describe "documents/show", type: :view do
  before(:each) do
    @document = assign(:document, Document.create!(
      :document_file => "",
      :project_references => "Project References",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Project References/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
