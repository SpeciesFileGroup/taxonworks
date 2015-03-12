require 'rails_helper'

describe Source::Verbatim, :type => :model do

  let(:verbatim_source) { Source::Verbatim.new }
  let(:citation) { 'Smith, J. 1860. A steam-driven engine for computing species richness. Biopunk II, p. 1-20.' }

  context 'validation' do
    before { verbatim_source.valid? }

    specify '#verbatim is required' do
      expect(verbatim_source.errors.include?(:verbatim)).to be_truthy
    end

    specify 'only #verbatim can be provided (ignores cached)' do
      verbatim_source.title = "Gears and Widgets in Biomachine"
      verbatim_source.valid?
      expect(verbatim_source.errors.include?(:title)).to be_truthy
    end 
  end

  context '#cached' do
    before { verbatim_source.verbatim = citation }
    specify 'is set from #verbatim' do
      verbatim_source.save!
      expect(verbatim_source.cached).to eq(citation)
    end
  end

  context '#generate_bibtex' do
    specify 'for a non-resolvable reference returns false' do
      verbatim_source.verbatim = citation
      verbatim_source.save!

      VCR.use_cassette('verbatim_source_is_not_resolvable') do
        expect(verbatim_source.generate_bibtex).to be_falsey
      end
    end

    specify 'for a non-resolvable reference returns a Source::Bibtex instance' do
      verbatim_source.verbatim = 'Cristofari, Cécile, and Matthieu J. Guitton. "The Steampunk Doctor: Practicing Medicine in a Mechanical Age." Advances in Anthropology 2014 (2014).'
      verbatim_source.save!
      VCR.use_cassette('verbatim_source_is_resolvable') do
        expect(verbatim_source.generate_bibtex).to be_truthy
      end
    end
  end

end
