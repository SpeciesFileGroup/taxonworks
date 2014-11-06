require 'rails_helper'

describe Source, :type => :model do
  let(:source) { Source.new }

  after(:all) {
    Source.delete_all
  }

  context 'associtations' do
    specify 'sources have citations' do
      expect(source.citations << Citation.new()).to be_truthy 
    end
  end

  context '#new_from_citation' do
    let(:citation) { 'Yoder, M. J., A. A. Valerio, A. Polaszek, L. Masner, and N. F. Johnson. 2009. Revision of Scelio pulchripennis - group species (Hymenoptera, Platygastroidea, Platygastridae). ZooKeys 20:53-118.' }
    specify 'when citation is < 5 characters false is returned' do
      expect(Source.new_from_citation(citation: 'ABC')).to eq(false)
    end
    
    specify 'when citation is > than 5 characters but unresolvable a Source::Verbatim instance is returned' do
      expect(Source.new_from_citation(citation: 'ABCDE XYZ').class).to eq(Source::Verbatim)
    end

    specify 'when citation is resolveable a Source::Verbatim instance is returned' do
      expect(Source.new_from_citation(citation: citation).class).to eq(Source::Bibtex)
    end
  end

  context "cited objects" do
    let(:o) {FactoryGirl.create(:valid_otu) }
    let(:a) {FactoryGirl.create(:valid_source_bibtex)}

    specify 'returns a scope' do
      expect(source.cited_objects).to eq([])
    end

    specify 'returns a mixed array of objects' do
      c = Citation.create!(source: a, citation_object: o)
      a.reload
      expect(a.cited_objects.include?(o)).to be(true) 
      
    end
  end

  context 'after save' do
    skip 'it should set a cached value'
    skip 'it should set a cached author year ?! Bibtex'
  end

  context 'tests based on hackathon requirments' do

    skip 'Be able to input a verbatim reference without resolving it.'
    # The scientist should be able to copy a verbatim reference from another document and pass it into
    # TW for normalization later.

    # The scientist should be able to pass just a URL/URN or other identifier in as a reference for completion
    # later (this will be a source of type "miscellaneous"). Ideally this could then simply resolve identifiers
    # such as a DOI and generate readily available reference information.
    skip 'Be able to input a URL, ISBN/ISSN, PubMed ID, DOI, Handle ID, Mendeley/Zotero/EndNote ID without any other information'
    skip 'map a DOI, ISBN, etc using buburi (Guarav gem) to generate a source'

    skip 'be able to tag imported references with "For review"'

    skip 'Should be able to store abstracts, nomenclature acts & entire classification'
    #  (available from ZooRecord - most probably returned as text strings).

  end

  context 'source format variations' do
    # a valid source should support the following output formats
    skip 'authority string - <author family name> year'
    skip 'short string - <author short name (as little of the author names needed to differentiate from other authors within current project)> <editor indicator> <year> <any containing reference - e.g. In Book> <Short publication name> <Series> <Volume> <Issue> <Pages>'
    skip 'long string - <full author names> <editor indicator> <year> <title> <containing reference> <Full publication name> <Series> <Volume> <Issue> <Pages>'
    skip 'no publication long string -<full author names> <editor indicator> <year> <title> <containing reference> <Series> <Volume> <Issue> <Pages>'
  end

  context 'duplicate record tests' do
=begin
    Species File conventions to remember:
      Two references are considered a match even if access code or th3 editor, OSF copy, or citation flags are different.
      Two references are considered different if they have different verbatim reference fields (including different capitalization), even if everything else matches!
      A reference is considered different if author, pub or containing ref aren't identical
      A reference is considered similar if years, title, volume or pages are either the same or missing.
      a similar reference may be added to the db by user request
      the values of verbatim data are ignored when checking if references are similar.
=end
    skip 'find an identical record'
    skip 'find a similar record'
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'has_roles'
    it_behaves_like 'alternate_values'
    it_behaves_like 'data_attributes'
    it_behaves_like 'taggable'
  end

end
