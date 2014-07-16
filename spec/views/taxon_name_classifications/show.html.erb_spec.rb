require 'rails_helper'

describe "taxon_name_classifications/show" do
  before(:each) do
    @taxon_name_classification = assign(:taxon_name_classification, stub_model(TaxonNameClassification,
      :taxon_name_id => 1,
      :type => "Type",
      :created_by_id => 2,
      :updated_by_id => 3,
      :project_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Type/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
