require 'rails_helper'

describe "taxon_determinations/new" do
  before(:each) do
    assign(:taxon_determination, stub_model(TaxonDetermination,
      :biological_collection_object_id => 1,
      :otu_id => 1,
      :position => 1,
      :year_made => "MyString",
      :month_made => "MyString",
      :day_made => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new taxon_determination form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", taxon_determinations_path, "post" do
      assert_select "select#taxon_determination_biological_collection_object_id[name=?]", "taxon_determination[biological_collection_object_id]"
      assert_select "select#taxon_determination_otu_id[name=?]", "taxon_determination[otu_id]"
      assert_select "input#taxon_determination_position[name=?]", "taxon_determination[position]"
      assert_select "input#taxon_determination_year_made[name=?]", "taxon_determination[year_made]"
      assert_select "input#taxon_determination_month_made[name=?]", "taxon_determination[month_made]"
      assert_select "input#taxon_determination_day_made[name=?]", "taxon_determination[day_made]"
    end
  end
end
