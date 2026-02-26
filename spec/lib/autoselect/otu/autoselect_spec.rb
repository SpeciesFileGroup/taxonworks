require 'rails_helper'

RSpec.describe Autoselect::Otu::Autoselect, type: :model do
  let(:project_id) { 1 }
  let(:user_id) { 1 }

  subject(:autoselect) {
    described_class.new(project_id:, user_id:)
  }

  describe 'config response (no term)' do
    let(:config) { autoselect.response }

    it 'returns a hash' do
      expect(config).to be_a(Hash)
    end

    it 'has response: nil' do
      expect(config[:response]).to be_nil
    end

    it 'includes smart, catalog_of_life as level keys in map' do
      expect(config[:map]).to include('smart', 'catalog_of_life')
    end

    it 'does not have fast level' do
      expect(config[:map]).not_to include('fast')
    end

    it 'includes !n operator trigger' do
      triggers = config[:operators].map { |o| o[:trigger] }
      expect(triggers).to include('!n')
    end
  end

  describe 'level stack' do
    it 'has two levels in order' do
      keys = autoselect.levels.map { |l| l.key.to_s }
      expect(keys).to eq(%w[smart catalog_of_life])
    end
  end

  describe 'term response with !n operator' do
    subject(:result) {
      described_class.new(
        term: '!n Foobaridae',
        level: 'smart',
        project_id:,
        user_id:
      ).response
    }

    it 'returns a response item' do
      expect(result[:response]).not_to be_empty
    end

    it 'response item extension has mode: new_otu_form' do
      item = result[:response].first
      expect(item[:extension][:mode]).to eq('new_otu_form')
    end

    it 'response item extension has name_prefill' do
      item = result[:response].first
      expect(item[:extension][:name_prefill]).to eq('Foobaridae')
    end

    it 'response item has nil otu_id in response_values' do
      item = result[:response].first
      expect(item[:response_values][:otu_id]).to be_nil
    end
  end
end

RSpec.describe Autoselect::Otu::Levels::Smart do
  subject(:level) { described_class.new }

  it 'returns new-OTU sentinel when !n operator present' do
    results = level.call(term: 'Foobaridae', operator: :new_record, project_id: 1)
    expect(results.length).to eq(1)
    expect(results.first).to respond_to(:_otu_new_form)
    expect(results.first._otu_new_form[:mode]).to eq('new_otu_form')
    expect(results.first._otu_new_form[:name_prefill]).to eq('Foobaridae')
  end

  it 'sentinel has nil id' do
    results = level.call(term: 'Foobaridae', operator: :new_record, project_id: 1)
    expect(results.first.id).to be_nil
  end
end

RSpec.describe Autoselect::Otu::Levels::CatalogOfLife do
  subject(:level) { described_class.new }

  it 'is external' do
    expect(level.external?).to be true
  end

  context 'when CoL returns no results' do
    before do
      allow(::Vendor::Colrapi).to receive(:search).and_return({ 'total' => 0, 'result' => [] })
    end

    it 'returns empty array' do
      results = level.call(term: 'Homo sapiens', project_id: 1)
      expect(results).to be_empty
    end
  end

  context 'when CoL returns results' do
    let(:col_result) {
      {
        'usage' => {
          'id' => 'abc123',
          'name' => { 'scientificName' => 'Homo sapiens' },
          'status' => 'accepted'
        }
      }
    }

    before do
      allow(::Vendor::Colrapi).to receive(:search).and_return({ 'total' => 1, 'result' => [col_result] })
      allow(::Vendor::Colrapi).to receive(:build_extension).and_return({
        col_key: 'abc123', col_name: 'Homo sapiens', col_status: 'accepted', alignment: []
      })
    end

    it 'returns pseudo-records with _col_extension' do
      results = level.call(term: 'Homo sapiens', project_id: 1)
      expect(results.length).to eq(1)
      expect(results.first).to respond_to(:_col_extension)
    end

    it 'extension includes hook metadata' do
      results = level.call(term: 'Homo sapiens', project_id: 1)
      expect(results.first._col_extension[:hook]).to include(
        model: 'TaxonName',
        level: 'catalog_of_life',
        yields: 'taxon_name_id'
      )
    end
  end
end
