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

  # needs VCR
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

  # needs VCR
  context '#new_from_doi' do
    let(:doi) { 'http://dx.doi.org/10.3897/zookeys.20.205' }

    specify 'when doi is not provide false' do
      expect(Source.new_from_doi()).to eq(false)
    end
    
    specify 'when non resolvable doi is provided false is returned ' do
      expect(Source.new_from_doi(doi: 'asdfasdf')).to eq(false)
    end

    specify 'when non resolvable doi is provided false is returned ' do
      expect(Source.new_from_doi(doi: doi).class).to eq(Source::Bibtex)
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

  context 'fuzzy matching' do
    before {
      @s1 = FactoryGirl.create(:valid_source_verbatim, verbatim: 'This is a base string.')
      @s2 = FactoryGirl.create(:valid_source_verbatim, verbatim: 'This is a base string.')
      @s3 = FactoryGirl.create(:valid_source_verbatim, verbatim: 'This is a roof string.')
      @s4 = FactoryGirl.create(:valid_source_verbatim, verbatim: 'This is a r00f string.')
    }

    specify 'nearest_by_levenshtein(compared_string: nil, column: "cached", limit: 10)' do
      expect(@s1.nearest_by_levenshtein(compared_string: @s1.verbatim).first).to eq(@s2)
      expect(@s2.nearest_by_levenshtein(compared_string: @s2.verbatim).first).to eq(@s1)
      expect(@s3.nearest_by_levenshtein(compared_string: @s3.verbatim).first).to eq(@s4)
      expect(@s4.nearest_by_levenshtein(compared_string: @s4.verbatim).first).to eq(@s3)
    end
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
    xspecify 'find an identical record'
    xspecify 'find a similar record'
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
