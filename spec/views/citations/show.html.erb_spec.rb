require 'rails_helper'

describe "citations/show", :type => :view do
  before(:each) do
    @citation = assign(:citation, stub_model(Citation,
      :citation_object_id => "Citation Object",
      :citation_object_type => "Citation Object Type",
      :source_id => 1,
      :created_by_id => 2,
      :updated_by_id => 3,
      :project_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Citation Object/)
    expect(rendered).to match(/Citation Object Type/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
