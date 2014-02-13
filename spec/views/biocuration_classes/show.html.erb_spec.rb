require 'spec_helper'

describe "biocuration_classes/show" do
  before(:each) do
    @biocuration_class = assign(:biocuration_class, stub_model(BiocurationClass,
      :name => "Name",
      :created_by_id => 1,
      :updated_by_id => 2,
      :project_id => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
