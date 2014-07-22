require 'rails_helper'

describe "biocuration_classifications/show" do
  before(:each) do
    @biocuration_classification = assign(:biocuration_classification, stub_model(BiocurationClassification,
      :biocuration_class_id => 1,
      :biological_collection_object_id => 2,
      :position => 3,
      :created_by_id => 4,
      :updated_by_id => 5,
      :project_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end
