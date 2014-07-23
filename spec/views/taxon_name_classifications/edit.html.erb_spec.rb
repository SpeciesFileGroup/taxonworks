require 'rails_helper'

describe "taxon_name_classifications/edit", :type => :view do
  before(:each) do
    @taxon_name_classification = assign(:taxon_name_classification, stub_model(TaxonNameClassification,
      :taxon_name_id => 1,
      :type => "",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit taxon_name_classification form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", taxon_name_classification_path(@taxon_name_classification), "post" do
      assert_select "input#taxon_name_classification_taxon_name_id[name=?]", "taxon_name_classification[taxon_name_id]"
      assert_select "input#taxon_name_classification_type[name=?]", "taxon_name_classification[type]"
    end
  end
end
