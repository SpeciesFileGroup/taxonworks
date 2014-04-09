require 'spec_helper'

describe "taxon_determinations/show" do
  before(:each) do
    @taxon_determination = assign(:taxon_determination, stub_model(TaxonDetermination,
      :biological_collection_object_id => 1,
      :otu_id => 2,
      :position => 3,
      :year_made => "Year Made",
      :month_made => "Month Made",
      :day_made => "Day Made",
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
    rendered.should match(/Year made/)
    rendered.should match(/Month made/)
    rendered.should match(/Day made/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end
