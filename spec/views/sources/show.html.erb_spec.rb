require 'rails_helper'

describe "sources/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Annote/)
    expect(rendered).to match(/Author/)
    expect(rendered).to match(/Booktitle/)
    expect(rendered).to match(/Chapter/)
    expect(rendered).to match(/Crossref/)
    expect(rendered).to match(/Edition/)
    expect(rendered).to match(/Editor/)
    expect(rendered).to match(/Howpublished/)
    expect(rendered).to match(/Institution/)
    expect(rendered).to match(/Journal/)
    expect(rendered).to match(/Key/)
    expect(rendered).to match(/Month/)
    expect(rendered).to match(/Note/)
    expect(rendered).to match(/Number/)
    expect(rendered).to match(/Organization/)
    expect(rendered).to match(/Pages/)
    expect(rendered).to match(/Publisher/)
    expect(rendered).to match(/School/)
    expect(rendered).to match(/Series/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Volume/)
    expect(rendered).to match(/Doi/)
    expect(rendered).to match(/Abstract/)
    expect(rendered).to match(/Copyright/)
    expect(rendered).to match(/Language/)
    expect(rendered).to match(/Stated Year/)
    expect(rendered).to match(/Verbatim/)
    expect(rendered).to match(/Cached/)
    expect(rendered).to match(/Cached Author String/)
    expect(rendered).to match(/Bibtex Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/Isbn/)
    expect(rendered).to match(/Issn/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/Translator/)
    expect(rendered).to match(/Year Suffix/)
    expect(rendered).to match(/Url/)
  end
end
