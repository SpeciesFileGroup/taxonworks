require 'rails_helper'

describe "projects/new", :type => :view do
  before(:each) do
    assign(:project, stub_model(Project,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
    ).as_new_record)
  end

  it "renders new project form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", projects_path, "post" do
      assert_select "input#project_name[name=?]", "project[name]"
    end
  end
end
