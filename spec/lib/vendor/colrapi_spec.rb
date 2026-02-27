require 'rails_helper'

# Fixture helpers — mirror the actual Colrapi API response shapes.
#
# nameusage result entries are FLAT hashes (no 'usage' wrapper):
#   { 'id', 'status', 'name' => { 'scientificName', 'rank', ... }, 'label', 'labelHtml', ... }
#
# classification (ancestors) entries have 'name' as a plain String (uninomial):
#   { 'id', 'name' => 'Homo', 'rank' => 'genus', 'label', 'labelHtml' }

def col_nameusage_result(id: '6MB3T', scientific_name: 'Homo sapiens', rank: 'species', status: 'accepted')
  {
    'id'     => id,
    'status' => status,
    'name'   => {
      'scientificName' => scientific_name,
      'rank'           => rank,
      'authorship'     => 'Linnaeus, 1758'
    },
    'label'     => "#{scientific_name} Linnaeus, 1758",
    'labelHtml' => "<i>#{scientific_name}</i> Linnaeus, 1758"
  }
end

def col_classification_entry(id:, name:, rank:)
  # In classification responses 'name' is a plain String
  { 'id' => id, 'name' => name, 'rank' => rank, 'label' => name, 'labelHtml' => name }
end

describe Vendor::Colrapi, type: :model do

  # ── search ────────────────────────────────────────────────────────────────────

  describe '.search' do
    context 'when Colrapi returns results' do
      before do
        allow(::Colrapi).to receive(:nameusage)
          .with('3LR', q: 'Homo sapiens', limit: 20)
          .and_return({ 'total' => 1, 'result' => [col_nameusage_result] })
      end

      it 'calls Colrapi.nameusage with dataset_id as positional argument' do
        result = described_class.search('Homo sapiens')
        expect(::Colrapi).to have_received(:nameusage).with('3LR', q: 'Homo sapiens', limit: 20)
      end

      it 'returns a hash with total and result keys' do
        result = described_class.search('Homo sapiens')
        expect(result).to include('total', 'result')
      end

      it 'result entries are flat hashes with id, status, name, label' do
        result = described_class.search('Homo sapiens')
        entry = result['result'].first
        expect(entry).to include('id', 'status', 'name', 'label')
        expect(entry.dig('name', 'scientificName')).to eq('Homo sapiens')
        expect(entry['id']).to eq('6MB3T')
        expect(entry['status']).to eq('accepted')
      end
    end

    context 'when Colrapi raises an error' do
      before do
        allow(::Colrapi).to receive(:nameusage).and_raise(StandardError, 'network error')
      end

      it 'returns a safe empty response' do
        result = described_class.search('Anything')
        expect(result).to eq({ 'total' => 0, 'result' => [] })
      end
    end
  end

  # ── ancestors ─────────────────────────────────────────────────────────────────

  describe '.ancestors' do
    let(:classification) {
      [
        col_classification_entry(id: '636X2', name: 'Homo',     rank: 'genus'),
        col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family'),
        col_classification_entry(id: 'CH2',   name: 'Chordata', rank: 'phylum'),
        col_classification_entry(id: 'N',     name: 'Animalia', rank: 'kingdom'),
      ]
    }

    before do
      allow(::Colrapi).to receive(:taxon)
        .with('3LR', taxon_id: '6MB3T', subresource: 'classification')
        .and_return(classification)
    end

    it 'calls Colrapi.taxon with subresource: classification' do
      described_class.ancestors('6MB3T')
      expect(::Colrapi).to have_received(:taxon)
        .with('3LR', taxon_id: '6MB3T', subresource: 'classification')
    end

    it 'returns an array of classification entries' do
      result = described_class.ancestors('6MB3T')
      expect(result).to be_an(Array)
      expect(result.length).to eq(4)
    end

    it 'each entry has id, name (String), and rank' do
      result = described_class.ancestors('6MB3T')
      entry = result.first
      expect(entry['name']).to be_a(String)
      expect(entry['rank']).to be_a(String)
      expect(entry['id']).to be_a(String)
    end

    it 'returns entries in proximal-to-distal order (genus before kingdom)' do
      result = described_class.ancestors('6MB3T')
      ranks = result.map { |e| e['rank'] }
      expect(ranks.first).to eq('genus')
      expect(ranks.last).to eq('kingdom')
    end

    context 'when Colrapi raises an error' do
      before do
        allow(::Colrapi).to receive(:taxon).and_raise(StandardError, 'timeout')
      end

      it 'returns an empty array' do
        expect(described_class.ancestors('6MB3T')).to eq([])
      end
    end
  end

  # ── build_extension ───────────────────────────────────────────────────────────

  describe '.build_extension' do
    let(:col_result) { col_nameusage_result }

    let(:classification) {
      [
        col_classification_entry(id: '636X2', name: 'Homo',     rank: 'genus'),
        col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family'),
      ]
    }

    before do
      allow(described_class).to receive(:ancestors)
        .with('6MB3T')
        .and_return(classification)
    end

    subject(:extension) { described_class.build_extension(col_result, nil) }

    it 'extracts col_key from top-level id' do
      expect(extension[:col_key]).to eq('6MB3T')
    end

    it 'extracts col_name from name.scientificName' do
      expect(extension[:col_name]).to eq('Homo sapiens')
    end

    it 'extracts col_status from top-level status' do
      expect(extension[:col_status]).to eq('accepted')
    end

    it 'builds alignment from classification entries' do
      expect(extension[:alignment]).to be_an(Array)
      expect(extension[:alignment].length).to eq(2)
    end

    it 'alignment entries have rank, col_name, taxonworks_id, taxonworks_name, match' do
      entry = extension[:alignment].first
      expect(entry).to include(:rank, :col_name, :taxonworks_id, :taxonworks_name, :match)
    end

    it 'alignment entry col_name comes from the plain-string name field' do
      entry = extension[:alignment].first
      expect(entry[:col_name]).to eq('Homo')
    end

    it 'alignment entry rank is downcased' do
      entry = extension[:alignment].first
      expect(entry[:rank]).to eq('genus')
    end

    it 'alignment entry match is none when TaxonName not in project' do
      entry = extension[:alignment].first
      expect(entry[:match]).to eq('none')
      expect(entry[:taxonworks_id]).to be_nil
    end

    context 'when a TaxonName matches an ancestor name' do
      let!(:taxon_name) { FactoryBot.create(:valid_taxon_name) }

      let(:classification_with_match) {
        [col_classification_entry(id: 'XXX', name: taxon_name.cached, rank: 'family')]
      }

      before do
        allow(described_class).to receive(:ancestors)
          .with('6MB3T')
          .and_return(classification_with_match)
      end

      it 'sets match to exact and populates taxonworks_id' do
        ext = described_class.build_extension(col_result, taxon_name.project_id)
        entry = ext[:alignment].first
        expect(entry[:match]).to eq('exact')
        expect(entry[:taxonworks_id]).to eq(taxon_name.id)
        expect(entry[:taxonworks_name]).to eq(taxon_name.cached)
      end
    end

    context 'when col_key is blank' do
      let(:col_result_no_id) { col_nameusage_result(id: nil) }

      it 'skips the ancestors call and returns empty alignment' do
        ext = described_class.build_extension(col_result_no_id, nil)
        expect(described_class).not_to have_received(:ancestors)
        expect(ext[:alignment]).to eq([])
      end
    end
  end
end
