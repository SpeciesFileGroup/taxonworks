require 'rails_helper'

describe "taxon_names/show", :type => :view do
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
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Cached Name/)
    expect(rendered).to match(/Cached Author Year/)
    expect(rendered).to match(/Cached Higher Classification/)
    #rendered.should match(/2/)
    #rendered.should match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/Verbatim Author/)
    expect(rendered).to match(/Rank Class/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/8/)
    expect(rendered).to match(/Cached Original Combination/)
    expect(rendered).to match(/Cached Secondary Homonym/)
    expect(rendered).to match(/Cached Primary Homonym/)
    expect(rendered).to match(/Cached Secondary Homonym Alt/)
    expect(rendered).to match(/Cached Primary Homonym Alt/)
  end
end
