require 'rails_helper'

describe "taxon_names/index" do
  before(:each) do
    assign(:taxon_names, [
      stub_model(TaxonName,
        :name => "Name",
        :parent_id => 1,
        :cached_name => "Cached Name",
        :cached_author_year => "Cached Author Year",
        :cached_higher_classification => "Cached Higher Classification",
=begin
        :lft => 2,
        :rgt => 3,
=end
        :source_id => 4,
        :year_of_publication => 5,
        :verbatim_author => "Verbatim Author",
        :rank_class => "Rank Class",
        :type => "Type",
        :created_by_id => 6,
        :updated_by_id => 7,
        :project_id => 8,
        :cached_original_combination => "Cached Original Combination",
        :cached_secondary_homonym => "Cached Secondary Homonym",
        :cached_primary_homonym => "Cached Primary Homonym",
        :cached_secondary_homonym_alt => "Cached Secondary Homonym Alt",
        :cached_primary_homonym_alt => "Cached Primary Homonym Alt"
      ),
      stub_model(TaxonName,
        :name => "Name",
        :parent_id => 1,
        :cached_name => "Cached Name",
        :cached_author_year => "Cached Author Year",
        :cached_higher_classification => "Cached Higher Classification",
        #:lft => 2,
        #:rgt => 3,
        :source_id => 4,
        :year_of_publication => 5,
        :verbatim_author => "Verbatim Author",
        :rank_class => "Rank Class",
        :type => "Type",
        :created_by_id => 6,
        :updated_by_id => 7,
        :project_id => 8,
        :cached_original_combination => "Cached Original Combination",
        :cached_secondary_homonym => "Cached Secondary Homonym",
        :cached_primary_homonym => "Cached Primary Homonym",
        :cached_secondary_homonym_alt => "Cached Secondary Homonym Alt",
        :cached_primary_homonym_alt => "Cached Primary Homonym Alt"
      )
    ])
  end

  it "renders a list of taxon_names" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Cached Name".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Author Year".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Higher Classification".to_s, :count => 2
    #assert_select "tr>td", :text => 2.to_s, :count => 2
    #assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Author".to_s, :count => 2
    assert_select "tr>td", :text => "Rank Class".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
    assert_select "tr>td", :text => 8.to_s, :count => 2
    assert_select "tr>td", :text => "Cached Original Combination".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Secondary Homonym".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Primary Homonym".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Secondary Homonym Alt".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Primary Homonym Alt".to_s, :count => 2
  end
end
