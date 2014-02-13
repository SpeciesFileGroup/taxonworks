require 'spec_helper'

describe "taxon_names/edit" do
  before(:each) do
    @taxon_name = assign(:taxon_name, stub_model(TaxonName,
      :name => "MyString",
      :parent_id => 1,
      :cached_name => "MyString",
      :cached_author_year => "MyString",
      :cached_higher_classification => "MyString",
      :lft => 1,
      :rgt => 1,
      :source_id => 1,
      :year_of_publication => 1,
      :verbatim_author => "MyString",
      :rank_class => "MyString",
      :type => "",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :cached_original_combination => "MyString",
      :cached_secondary_homonym => "MyString",
      :cached_primary_homonym => "MyString",
      :cached_secondary_homonym_alt => "MyString",
      :cached_primary_homonym_alt => "MyString"
    ))
  end

  it "renders the edit taxon_name form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", taxon_name_path(@taxon_name), "post" do
      assert_select "input#taxon_name_name[name=?]", "taxon_name[name]"
      assert_select "input#taxon_name_parent_id[name=?]", "taxon_name[parent_id]"
      assert_select "input#taxon_name_cached_name[name=?]", "taxon_name[cached_name]"
      assert_select "input#taxon_name_cached_author_year[name=?]", "taxon_name[cached_author_year]"
      assert_select "input#taxon_name_cached_higher_classification[name=?]", "taxon_name[cached_higher_classification]"
      assert_select "input#taxon_name_lft[name=?]", "taxon_name[lft]"
      assert_select "input#taxon_name_rgt[name=?]", "taxon_name[rgt]"
      assert_select "input#taxon_name_source_id[name=?]", "taxon_name[source_id]"
      assert_select "input#taxon_name_year_of_publication[name=?]", "taxon_name[year_of_publication]"
      assert_select "input#taxon_name_verbatim_author[name=?]", "taxon_name[verbatim_author]"
      assert_select "input#taxon_name_rank_class[name=?]", "taxon_name[rank_class]"
      assert_select "input#taxon_name_type[name=?]", "taxon_name[type]"
      assert_select "input#taxon_name_created_by_id[name=?]", "taxon_name[created_by_id]"
      assert_select "input#taxon_name_updated_by_id[name=?]", "taxon_name[updated_by_id]"
      assert_select "input#taxon_name_project_id[name=?]", "taxon_name[project_id]"
      assert_select "input#taxon_name_cached_original_combination[name=?]", "taxon_name[cached_original_combination]"
      assert_select "input#taxon_name_cached_secondary_homonym[name=?]", "taxon_name[cached_secondary_homonym]"
      assert_select "input#taxon_name_cached_primary_homonym[name=?]", "taxon_name[cached_primary_homonym]"
      assert_select "input#taxon_name_cached_secondary_homonym_alt[name=?]", "taxon_name[cached_secondary_homonym_alt]"
      assert_select "input#taxon_name_cached_primary_homonym_alt[name=?]", "taxon_name[cached_primary_homonym_alt]"
    end
  end
end
