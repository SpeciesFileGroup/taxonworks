require 'rails_helper'

describe "taxon_determinations/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Year made/)
    expect(rendered).to match(/Month made/)
    expect(rendered).to match(/Day made/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
