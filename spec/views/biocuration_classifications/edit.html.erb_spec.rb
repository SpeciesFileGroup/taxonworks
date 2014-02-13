require 'spec_helper'

describe "biocuration_classifications/edit" do
  before(:each) do
    @biocuration_classification = assign(:biocuration_classification, stub_model(BiocurationClassification,
      :biocuration_class_id => 1,
      :biological_collection_object_id => 1,
      :position => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit biocuration_classification form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", biocuration_classification_path(@biocuration_classification), "post" do
      assert_select "input#biocuration_classification_biocuration_class_id[name=?]", "biocuration_classification[biocuration_class_id]"
      assert_select "input#biocuration_classification_biological_collection_object_id[name=?]", "biocuration_classification[biological_collection_object_id]"
      assert_select "input#biocuration_classification_position[name=?]", "biocuration_classification[position]"
      assert_select "input#biocuration_classification_created_by_id[name=?]", "biocuration_classification[created_by_id]"
      assert_select "input#biocuration_classification_updated_by_id[name=?]", "biocuration_classification[updated_by_id]"
      assert_select "input#biocuration_classification_project_id[name=?]", "biocuration_classification[project_id]"
    end
  end
end
