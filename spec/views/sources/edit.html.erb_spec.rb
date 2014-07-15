require 'spec_helper'

describe "sources/edit" do
  before(:each) do
    @source = assign(:source, stub_model(Source,
      :serial_id => 1,
      :address => "MyString",
      :annote => "MyString",
      :author => "MyString",
      :booktitle => "MyString",
      :chapter => "MyString",
      :crossref => "MyString",
      :edition => "MyString",
      :editor => "MyString",
      :howpublished => "MyString",
      :institution => "MyString",
      :journal => "MyString",
      :key => "MyString",
      :month => "MyString",
      :note => "MyString",
      :number => "MyString",
      :organization => "MyString",
      :pages => "MyString",
      :publisher => "MyString",
      :school => "MyString",
      :series => "MyString",
      :title => "MyString",
      :type => "",
      :volume => "MyString",
      :doi => "MyString",
      :abstract => "MyString",
      :copyright => "MyString",
      :language => "MyString",
      :stated_year => "MyString",
      :verbatim => "MyString",
      :cached => "MyString",
      :cached_author_string => "MyString",
      :bibtex_type => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :day => 1,
      :year => 1,
      :isbn => "MyString",
      :issn => "MyString",
      :verbatim_contents => "MyText",
      :verbatim_keywords => "MyText",
      :language_id => 1,
      :translator => "MyString",
      :year_suffix => "MyString",
      :url => "MyString"
    ))
  end

  it "renders the edit source form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", source_path(@source), "post" do
      assert_select "input#source_serial_id[name=?]", "source[serial_id]"
      assert_select "input#source_address[name=?]", "source[address]"
      assert_select "input#source_annote[name=?]", "source[annote]"
      assert_select "input#source_author[name=?]", "source[author]"
      assert_select "input#source_booktitle[name=?]", "source[booktitle]"
      assert_select "input#source_chapter[name=?]", "source[chapter]"
      assert_select "input#source_crossref[name=?]", "source[crossref]"
      assert_select "input#source_edition[name=?]", "source[edition]"
      assert_select "input#source_editor[name=?]", "source[editor]"
      assert_select "input#source_howpublished[name=?]", "source[howpublished]"
      assert_select "input#source_institution[name=?]", "source[institution]"
      assert_select "input#source_journal[name=?]", "source[journal]"
      assert_select "input#source_key[name=?]", "source[key]"
      assert_select "input#source_month[name=?]", "source[month]"
      assert_select "input#source_note[name=?]", "source[note]"
      assert_select "input#source_number[name=?]", "source[number]"
      assert_select "input#source_organization[name=?]", "source[organization]"
      assert_select "input#source_pages[name=?]", "source[pages]"
      assert_select "input#source_publisher[name=?]", "source[publisher]"
      assert_select "input#source_school[name=?]", "source[school]"
      assert_select "input#source_series[name=?]", "source[series]"
      assert_select "input#source_title[name=?]", "source[title]"
      assert_select "input#source_type[name=?]", "source[type]"
      assert_select "input#source_volume[name=?]", "source[volume]"
      assert_select "input#source_doi[name=?]", "source[doi]"
      assert_select "input#source_abstract[name=?]", "source[abstract]"
      assert_select "input#source_copyright[name=?]", "source[copyright]"
      assert_select "input#source_language[name=?]", "source[language]"
      assert_select "input#source_stated_year[name=?]", "source[stated_year]"
      assert_select "input#source_verbatim[name=?]", "source[verbatim]"
      assert_select "input#source_cached[name=?]", "source[cached]"
      assert_select "input#source_cached_author_string[name=?]", "source[cached_author_string]"
      assert_select "input#source_bibtex_type[name=?]", "source[bibtex_type]"
      assert_select "input#source_created_by_id[name=?]", "source[created_by_id]"
      assert_select "input#source_updated_by_id[name=?]", "source[updated_by_id]"
      assert_select "input#source_day[name=?]", "source[day]"
      assert_select "input#source_year[name=?]", "source[year]"
      assert_select "input#source_isbn[name=?]", "source[isbn]"
      assert_select "input#source_issn[name=?]", "source[issn]"
      assert_select "textarea#source_verbatim_contents[name=?]", "source[verbatim_contents]"
      assert_select "textarea#source_verbatim_keywords[name=?]", "source[verbatim_keywords]"
      assert_select "input#source_language_id[name=?]", "source[language_id]"
      assert_select "input#source_translator[name=?]", "source[translator]"
      assert_select "input#source_year_suffix[name=?]", "source[year_suffix]"
      assert_select "input#source_url[name=?]", "source[url]"
    end
  end
end
