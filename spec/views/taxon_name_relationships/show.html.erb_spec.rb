require 'rails_helper'

describe "taxon_name_relationships/show", :type => :view do
  before(:each) do
    @taxon_name_relationship = assign(:taxon_name_relationship, stub_model(TaxonNameRelationship,
      :subject_taxon_name_id => 1,
      :object_taxon_name_id => 2,
      :type => "Type",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5,
      :source_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
