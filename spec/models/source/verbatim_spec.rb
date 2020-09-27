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

  specify 'converts to type Bibtex when valid Bibtex' do
    verbatim_source.update!(verbatim: "My text")
    expect(verbatim_source.update(
      type: 'Source::Bibtex',
      title: 'My title',
      bibtex_type: 'article',
      author: 'jones'
    )).to be_truthy
  end

  specify 'adds errors when converts to type Bibtex and invalid' do
    verbatim_source.update!(verbatim: "My text")
    expect(verbatim_source.update( type: 'Source::Bibtex', title: 'My title', author: 'jones')).to be_falsey
  end

  specify '#cached is set from #verbatim' do
    verbatim_source.update!(verbatim:  citation )
    expect(verbatim_source.cached).to eq(citation)
  end

  context 'bibtex' do
    specify 'update with conversion sets cached' do
      t = 'My new text'
      verbatim_source.update!(verbatim: "My text")
      verbatim_source.update!(type: 'Source::Bibtex', bibtex_type: 'article', title: t)
      a = verbatim_source.becomes(verbatim_source.type.safe_constantize)
      a.reload
      expect(a.cached).to match(t)
    end

    specify '#generate_bibtex for a non-resolvable reference returns false' do
      verbatim_source.update(verbatim: citation)

      VCR.use_cassette('verbatim_source_is_not_resolvable') do
        expect(verbatim_source.generate_bibtex).to be_falsey
      end
    end

    context 'valid conversion' do
      before do
        verbatim_source.verbatim = 'Cristofari, Cécile, and Matthieu J. Guitton. "The Steampunk Doctor: Practicing Medicine in a Mechanical Age." Advances in Anthropology 2014 (2014).'
        verbatim_source.save!
      end

      specify '#generate_bibtex for a non-resolvable reference returns a Source::Bibtex instance' do
        VCR.use_cassette('verbatim_source_is_resolvable') do
          expect(verbatim_source.generate_bibtex).to be_truthy
        end
      end

      specify '#to_bibtex 1' do
        VCR.use_cassette('verbatim_source_is_resolvable') do
          expect(verbatim_source.send(:to_bibtex)).to be_truthy
          expect(verbatim_source.type).to eq('Source::Bibtex')
        end
      end

      specify '#convert_to_bibtex 1' do
        VCR.use_cassette('verbatim_source_is_resolvable') do
          verbatim_source.convert_to_bibtex = true
          verbatim_source.save!
          expect(verbatim_source.type).to eq('Source::Bibtex')
        end
      end

      specify '#convert_to_bibtex 2' do
        VCR.use_cassette('verbatim_source_is_resolvable') do
          verbatim_source.convert_to_bibtex = nil 
          verbatim_source.save!
          expect(verbatim_source.type).to eq('Source::Verbatim')
        end
      end
    end
  end

end
