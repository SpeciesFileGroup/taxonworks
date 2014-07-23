require 'rails_helper'

describe "taxon_name_classifications/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
