require 'rails_helper'

describe Source::Verbatim, type: :model, group: :sources do

  let(:verbatim_source) { Source::Verbatim.new }
  let(:citation) { '111111111111111111111111111111' }

  context 'validation' do
    before { verbatim_source.valid? }

    specify '#verbatim is required' do
      expect(verbatim_source.errors.include?(:verbatim)).to be_truthy
    end

    specify 'only #verbatim can be provided (ignores cached)' do
      verbatim_source.title = 'A cold-fusion driven engine for computing.'
      verbatim_source.valid?
      expect(verbatim_source.errors.include?(:title)).to be_truthy
    end
  end

  context '#clone' do
    before do
      verbatim_source.update(verbatim: 'This is verbatim')
    end

    specify 'persists' do
      expect(verbatim_source.clone.persisted?).to be_truthy
    end

    specify 'labeled' do
      a = verbatim_source.clone
      expect(a.verbatim).to eq("[CLONE of #{verbatim_source.id}] " + verbatim_source.verbatim )
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
      verbatim_source.update(verbatim: citation)

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
