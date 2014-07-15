require 'spec_helper'

describe "sources/show" do
  before(:each) do
    @source = assign(:source, stub_model(Source,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Address/)
    rendered.should match(/Annote/)
    rendered.should match(/Author/)
    rendered.should match(/Booktitle/)
    rendered.should match(/Chapter/)
    rendered.should match(/Crossref/)
    rendered.should match(/Edition/)
    rendered.should match(/Editor/)
    rendered.should match(/Howpublished/)
    rendered.should match(/Institution/)
    rendered.should match(/Journal/)
    rendered.should match(/Key/)
    rendered.should match(/Month/)
    rendered.should match(/Note/)
    rendered.should match(/Number/)
    rendered.should match(/Organization/)
    rendered.should match(/Pages/)
    rendered.should match(/Publisher/)
    rendered.should match(/School/)
    rendered.should match(/Series/)
    rendered.should match(/Title/)
    rendered.should match(/Type/)
    rendered.should match(/Volume/)
    rendered.should match(/Doi/)
    rendered.should match(/Abstract/)
    rendered.should match(/Copyright/)
    rendered.should match(/Language/)
    rendered.should match(/Stated Year/)
    rendered.should match(/Verbatim/)
    rendered.should match(/Cached/)
    rendered.should match(/Cached Author String/)
    rendered.should match(/Bibtex Type/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/Isbn/)
    rendered.should match(/Issn/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/6/)
    rendered.should match(/Translator/)
    rendered.should match(/Year Suffix/)
    rendered.should match(/Url/)
  end
end
