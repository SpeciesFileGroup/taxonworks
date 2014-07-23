require 'rails_helper'

describe "taxon_name_relationships/index", :type => :view do
  before(:each) do
    assign(:taxon_name_relationships, [
      stub_model(TaxonNameRelationship,
        :subject_taxon_name_id => 1,
        :object_taxon_name_id => 2,
        :type => "Type",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :source_id => 6
      ),
      stub_model(TaxonNameRelationship,
        :subject_taxon_name_id => 1,
        :object_taxon_name_id => 2,
        :type => "Type",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :source_id => 6
      )
    ])
  end

  it "renders a list of taxon_name_relationships" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
