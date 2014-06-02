require 'spec_helper'

describe "taxon_name_relationships/show" do
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
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Type/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end
