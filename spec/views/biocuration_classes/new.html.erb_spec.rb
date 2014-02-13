require 'spec_helper'

describe "biocuration_classes/new" do
  before(:each) do
    assign(:biocuration_class, stub_model(BiocurationClass,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new biocuration_class form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", biocuration_classes_path, "post" do
      assert_select "input#biocuration_class_name[name=?]", "biocuration_class[name]"
      assert_select "input#biocuration_class_created_by_id[name=?]", "biocuration_class[created_by_id]"
      assert_select "input#biocuration_class_updated_by_id[name=?]", "biocuration_class[updated_by_id]"
      assert_select "input#biocuration_class_project_id[name=?]", "biocuration_class[project_id]"
    end
  end
end
