require 'spec_helper'

describe "sources/index" do
  before(:each) do
    assign(:sources, [
      stub_model(Source,
        :serial_id => 1,
        :address => "Address",
        :annote => "Annote",
        :author => "Author",
        :booktitle => "Booktitle",
        :chapter => "Chapter",
        :crossref => "Crossref",
        :edition => "Edition",
        :editor => "Editor",
        :howpublished => "Howpublished",
        :institution => "Institution",
        :journal => "Journal",
        :key => "Key",
        :month => "Month",
        :note => "Note",
        :number => "Number",
        :organization => "Organization",
        :pages => "Pages",
        :publisher => "Publisher",
        :school => "School",
        :series => "Series",
        :title => "Title",
        :type => "Type",
        :volume => "Volume",
        :doi => "Doi",
        :abstract => "Abstract",
        :copyright => "Copyright",
        :language => "Language",
        :stated_year => "Stated Year",
        :verbatim => "Verbatim",
        :cached => "Cached",
        :cached_author_string => "Cached Author String",
        :bibtex_type => "Bibtex Type",
        :created_by_id => 2,
        :updated_by_id => 3,
        :day => 4,
        :year => 5,
        :isbn => "Isbn",
        :issn => "Issn",
        :verbatim_contents => "MyText",
        :verbatim_keywords => "MyText",
        :language_id => 6,
        :translator => "Translator",
        :year_suffix => "Year Suffix",
        :url => "Url"
      ),
      stub_model(Source,
        :serial_id => 1,
        :address => "Address",
        :annote => "Annote",
        :author => "Author",
        :booktitle => "Booktitle",
        :chapter => "Chapter",
        :crossref => "Crossref",
        :edition => "Edition",
        :editor => "Editor",
        :howpublished => "Howpublished",
        :institution => "Institution",
        :journal => "Journal",
        :key => "Key",
        :month => "Month",
        :note => "Note",
        :number => "Number",
        :organization => "Organization",
        :pages => "Pages",
        :publisher => "Publisher",
        :school => "School",
        :series => "Series",
        :title => "Title",
        :type => "Type",
        :volume => "Volume",
        :doi => "Doi",
        :abstract => "Abstract",
        :copyright => "Copyright",
        :language => "Language",
        :stated_year => "Stated Year",
        :verbatim => "Verbatim",
        :cached => "Cached",
        :cached_author_string => "Cached Author String",
        :bibtex_type => "Bibtex Type",
        :created_by_id => 2,
        :updated_by_id => 3,
        :day => 4,
        :year => 5,
        :isbn => "Isbn",
        :issn => "Issn",
        :verbatim_contents => "MyText",
        :verbatim_keywords => "MyText",
        :language_id => 6,
        :translator => "Translator",
        :year_suffix => "Year Suffix",
        :url => "Url"
      )
    ])
  end

  it "renders a list of sources" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Annote".to_s, :count => 2
    assert_select "tr>td", :text => "Author".to_s, :count => 2
    assert_select "tr>td", :text => "Booktitle".to_s, :count => 2
    assert_select "tr>td", :text => "Chapter".to_s, :count => 2
    assert_select "tr>td", :text => "Crossref".to_s, :count => 2
    assert_select "tr>td", :text => "Edition".to_s, :count => 2
    assert_select "tr>td", :text => "Editor".to_s, :count => 2
    assert_select "tr>td", :text => "Howpublished".to_s, :count => 2
    assert_select "tr>td", :text => "Institution".to_s, :count => 2
    assert_select "tr>td", :text => "Journal".to_s, :count => 2
    assert_select "tr>td", :text => "Key".to_s, :count => 2
    assert_select "tr>td", :text => "Month".to_s, :count => 2
    assert_select "tr>td", :text => "Note".to_s, :count => 2
    assert_select "tr>td", :text => "Number".to_s, :count => 2
    assert_select "tr>td", :text => "Organization".to_s, :count => 2
    assert_select "tr>td", :text => "Pages".to_s, :count => 2
    assert_select "tr>td", :text => "Publisher".to_s, :count => 2
    assert_select "tr>td", :text => "School".to_s, :count => 2
    assert_select "tr>td", :text => "Series".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Volume".to_s, :count => 2
    assert_select "tr>td", :text => "Doi".to_s, :count => 2
    assert_select "tr>td", :text => "Abstract".to_s, :count => 2
    assert_select "tr>td", :text => "Copyright".to_s, :count => 2
    assert_select "tr>td", :text => "Language".to_s, :count => 2
    assert_select "tr>td", :text => "Stated Year".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim".to_s, :count => 2
    assert_select "tr>td", :text => "Cached".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Author String".to_s, :count => 2
    assert_select "tr>td", :text => "Bibtex Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "Isbn".to_s, :count => 2
    assert_select "tr>td", :text => "Issn".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => "Translator".to_s, :count => 2
    assert_select "tr>td", :text => "Year Suffix".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
  end
end
