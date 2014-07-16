require 'rails_helper'

describe "taxon_names/show" do
  before(:each) do
    @taxon_name = assign(:taxon_name, stub_model(TaxonName,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/Cached Name/)
    rendered.should match(/Cached Author Year/)
    rendered.should match(/Cached Higher Classification/)
    #rendered.should match(/2/)
    #rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/Verbatim Author/)
    rendered.should match(/Rank Class/)
    rendered.should match(/Type/)
    rendered.should match(/6/)
    rendered.should match(/7/)
    rendered.should match(/8/)
    rendered.should match(/Cached Original Combination/)
    rendered.should match(/Cached Secondary Homonym/)
    rendered.should match(/Cached Primary Homonym/)
    rendered.should match(/Cached Secondary Homonym Alt/)
    rendered.should match(/Cached Primary Homonym Alt/)
  end
end
