require 'spec_helper'

describe "citations/show" do
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
    rendered.should match(/Citation Object/)
    rendered.should match(/Citation Object Type/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
