require 'rails_helper'

describe "biocuration_classifications/index", :type => :view do
  before(:each) do
    assign(:biocuration_classifications, [
      stub_model(BiocurationClassification,
        :biocuration_class_id => 1,
        :biological_collection_object_id => 2,
        :position => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      ),
      stub_model(BiocurationClassification,
        :biocuration_class_id => 1,
        :biological_collection_object_id => 2,
        :position => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      )
    ])
  end

  it "renders a list of biocuration_classifications" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
