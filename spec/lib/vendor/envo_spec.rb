require 'rails_helper'

describe Vendor::Envo, type: :model do

  # ── search ────────────────────────────────────────────────────────────────────

  describe '.search' do
    before do
      allow(::Hookkaido).to receive(:search)
        .with('forest', ontologies: ['envo'], per: 25, page: 1)
        .and_return({
          results: [
            { iri: 'http://purl.obolibrary.org/obo/ENVO_00002007', label: 'temperate forest biome', ontology_prefix: 'envo', description: nil }
          ],
          page: 1,
          per: 25,
          total: 1
        })
    end

    it 'calls Hookkaido.search constrained to the envo ontology' do
      described_class.search('forest')
      expect(::Hookkaido).to have_received(:search).with('forest', ontologies: ['envo'], per: 25, page: 1)
    end

    it 'returns the Hookkaido payload' do
      result = described_class.search('forest')
      expect(result[:total]).to eq(1)
      expect(result[:results].first[:iri]).to eq('http://purl.obolibrary.org/obo/ENVO_00002007')
    end

    it 'passes through per and page' do
      allow(::Hookkaido).to receive(:search)
        .with('forest', ontologies: ['envo'], per: 5, page: 2)
        .and_return({ results: [], page: 2, per: 5, total: 0 })

      described_class.search('forest', per: 5, page: 2)
      expect(::Hookkaido).to have_received(:search).with('forest', ontologies: ['envo'], per: 5, page: 2)
    end

    it 'never allows a caller-supplied ontology to leak through' do
      described_class.search('forest')
      expect(::Hookkaido).not_to have_received(:search).with('forest', ontologies: ['uberon'], per: 25, page: 1)
    end

    it 'returns an empty result instead of raising when Hookkaido times out' do
      allow(::Hookkaido).to receive(:search)
        .with('forest', ontologies: ['envo'], per: 25, page: 1)
        .and_raise(Faraday::TimeoutError)

      result = nil
      expect { result = described_class.search('forest') }.not_to raise_error
      expect(result).to eq({results: [], page: 1, per: 25, total: 0})
    end
  end

  # ── valid_uri? ────────────────────────────────────────────────────────────────

  describe '.valid_uri?' do
    it 'is true for a well-formed ENVO OBO Library PURL' do
      expect(described_class.valid_uri?('http://purl.obolibrary.org/obo/ENVO_00002007')).to be_truthy
    end

    it 'is false for a PURL from a different ontology (e.g. UBERON)' do
      expect(described_class.valid_uri?('http://purl.obolibrary.org/obo/UBERON_0000979')).to be_falsey
    end

    it 'is false for a non-OBO-Library URI' do
      expect(described_class.valid_uri?('https://example.org/ENVO_00002007')).to be_falsey
    end

    it 'is false for nil' do
      expect(described_class.valid_uri?(nil)).to be_falsey
    end

    it 'is false for blank' do
      expect(described_class.valid_uri?('')).to be_falsey
    end
  end
end
