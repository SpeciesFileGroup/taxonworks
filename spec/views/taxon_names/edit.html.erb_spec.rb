require 'rails_helper'

describe "taxon_names/edit", :type => :view do
  before(:each) do
    @taxon_name = assign(:taxon_name, stub_model(TaxonName,
      :name => "MyString",
      :parent_id => 1,
      :source_id => 1,
      :year_of_publication => 1,
      :verbatim_author => "MyString",
      :rank_class => "MyString",
      :type => "",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
    ))
  end

  it "renders the edit taxon_name form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", taxon_name_path(@taxon_name), "post" do
      assert_select "input#taxon_name_name[name=?]", "taxon_name[name]"
      # assert_select "input#taxon_name_parent_id[name=?]", "taxon_name[parent_id]"
      assert_select "input#taxon_name_source_id[name=?]", "taxon_name[source_id]"
      assert_select "input#taxon_name_year_of_publication[name=?]", "taxon_name[year_of_publication]"
      assert_select "input#taxon_name_verbatim_author[name=?]", "taxon_name[verbatim_author]"
      # assert_select "input#taxon_name_rank_class[name=?]", "taxon_name[rank_class]"
      assert_select "input#taxon_name_type[name=?]", "taxon_name[type]"
    end
  end
end
