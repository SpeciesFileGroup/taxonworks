require 'spec_helper'

describe "taxon_determinations/index" do
  before(:each) do
    assign(:taxon_determinations, [
      stub_model(TaxonDetermination,
        :biological_collection_object_id => 1,
        :otu_id => 2,
        :position => 3,
        :year_made => "Year Made",
        :month_made => "Month Made",
        :day_made => "Day Made",
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      ),
      stub_model(TaxonDetermination,
        :biological_collection_object_id => 1,
        :otu_id => 2,
        :position => 3,
        :year_made => "Year Made",
        :month_made => "Month Made",
        :day_made => "Day Made",
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6
      )
    ])
  end

  it "renders a list of taxon_determinations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Year Made".to_s, :count => 2
    assert_select "tr>td", :text => "Month Made".to_s, :count => 2
    assert_select "tr>td", :text => "Day Made".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
