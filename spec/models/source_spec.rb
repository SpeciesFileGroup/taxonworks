require 'spec_helper'

describe Source do
  let(:source) { Source.new }



  context "concerns" do
    it_behaves_like 'identifiable'
    it_behaves_like 'has_roles'
  end

  context 'after save' do
    pending 'it should set a cached value'
    pending 'it should set a cached author year ?! Bibtex'
  end

  context 'tests based on hackathon requirments' do

    pending 'Be able to input a verbatim reference without resolving it.'
    # The scientist should be able to copy a verbatim reference from another document and pass it into
    # TW for normalization later.

    # The scientist should be able to pass just a URL/URN or other identifier in as a reference for completion
    # later (this will be a source of type "miscellaneous"). Ideally this could then simply resolve identifiers
    # such as a DOI and generate readily available reference information.
    pending 'Be able to input a URL, ISBN/ISSN, PubMed ID, DOI, Handle ID, Mendeley/Zotero/EndNote ID without any other information'
    pending 'map a DOI, ISBN, etc using buburi (Guarav gem) to generate a source'

    pending 'be able to tag imported references with "For review"'

    pending 'Should be able to store abstracts, nomenclature acts & entire classification'
    #  (available from ZooRecord - most probably returned as text strings).

  end

  context 'source format variations' do
    # a valid source should support the following output formats
    pending 'authority string - <author family name> year'
    pending 'short string - <author short name (as little of the author names needed to differentiate from other authors within current project)> <editor indicator> <year> <any containing reference - e.g. In Book> <Short publication name> <Series> <Volume> <Issue> <Pages>'
    pending 'long string - <full author names> <editor indicator> <year> <title> <containing reference> <Full publication name> <Series> <Volume> <Issue> <Pages>'
    pending 'no publication long string -<full author names> <editor indicator> <year> <title> <containing reference> <Series> <Volume> <Issue> <Pages>'
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
    pending 'find an identical record'
    pending 'find a similar record'
  end
end
