require 'rails_helper'

describe "taxon_name_classifications/index", :type => :view do
  before(:each) do
    assign(:taxon_name_classifications, [
      stub_model(TaxonNameClassification,
        :taxon_name_id => 1,
        :type => "Type",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project_id => 4
      ),
      stub_model(TaxonNameClassification,
        :taxon_name_id => 1,
        :type => "Type",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project_id => 4
      )
    ])
  end

  it "renders a list of taxon_name_classifications" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
