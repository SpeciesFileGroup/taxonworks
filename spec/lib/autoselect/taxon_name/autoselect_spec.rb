require 'rails_helper'

RSpec.describe Autoselect::TaxonName::Autoselect, type: :model do
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

    it 'has config key populated with a hash' do
      expect(config[:config]).to be_a(Hash)
    end

    it 'includes fast, smart, catalog_of_life as level keys in map' do
      expect(config[:map]).to include('fast', 'smart', 'catalog_of_life')
    end

    it 'includes level metadata in levels array' do
      level_keys = config[:levels].map { |l| l[:key].to_s }
      expect(level_keys).to include('fast', 'smart', 'catalog_of_life')
    end

    it 'includes operators' do
      expect(config[:operators]).to be_an(Array)
      expect(config[:operators].map { |o| o[:trigger] }).to include('!r', '!rm', '!?')
    end

    describe 'level metadata' do
      let(:levels_by_key) {
        config[:levels].index_by { |l| l[:key].to_s }
      }

      it 'fast level is not external' do
        expect(levels_by_key['fast'][:external]).to be false
      end

      it 'catalog_of_life level is external' do
        expect(levels_by_key['catalog_of_life'][:external]).to be true
      end

      it 'catalog_of_life has longer fuse_ms than fast' do
        expect(levels_by_key['catalog_of_life'][:fuse_ms]).to be > levels_by_key['fast'][:fuse_ms]
      end
    end
  end

  describe 'term response' do
    context 'with matching records' do
      let!(:taxon_name) { FactoryBot.create(:valid_taxon_name) }

      subject(:result) {
        described_class.new(
          term: 'Adidae',
          level: 'fast',
          project_id: taxon_name.project_id,
          user_id:
        ).response
      }

      it 'returns a hash with response key' do
        expect(result[:response]).to be_an(Array)
      end

      it 'has config: nil' do
        expect(result[:config]).to be_nil
      end

      it 'has level key' do
        expect(result[:level]).to eq('fast')
      end

      it 'response items have required keys' do
        item = result[:response].first
        expect(item).to include(:id, :label, :label_html, :info, :response_values, :extension)
      end

      it 'response_values includes taxon_name_id' do
        item = result[:response].first
        expect(item[:response_values]).to include(:taxon_name_id)
        expect(item[:response_values][:taxon_name_id]).to eq(taxon_name.id)
      end

      it 'extension is empty for plain TaxonName records' do
        item = result[:response].first
        expect(item[:extension]).to eq({})
      end
    end

    context 'with no matching records at fast level' do
      subject(:result) {
        described_class.new(
          term: 'ZzZzNomatch999',
          level: 'fast',
          project_id:,
          user_id:
        ).response
      }

      it 'includes next_level when results are empty' do
        expect(result[:next_level]).to eq('smart')
      end

      it 'response is empty array' do
        expect(result[:response]).to eq([])
      end
    end

    context 'with smart level' do
      subject(:result) {
        described_class.new(
          term: 'ZzZzNomatch999',
          level: 'smart',
          project_id:,
          user_id:
        ).response
      }

      it 'next_level is catalog_of_life when smart yields nothing' do
        expect(result[:next_level]).to eq('catalog_of_life')
      end
    end
  end

  describe 'level stack' do
    it 'has three levels in order' do
      keys = autoselect.levels.map { |l| l.key.to_s }
      expect(keys).to eq(%w[fast smart catalog_of_life])
    end
  end
end

RSpec.describe Autoselect::TaxonName::Levels::Fast, type: :model do
  let!(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
  let(:level) { described_class.new }

  it 'returns records matching exact cached name' do
    results = level.call(term: 'Adidae', project_id: taxon_name.project_id)
    expect(results.map(&:id)).to include(taxon_name.id)
  end

  it 'returns records matching prefix' do
    results = level.call(term: 'Adi', project_id: taxon_name.project_id)
    expect(results.map(&:id)).to include(taxon_name.id)
  end

  it 'returns empty array when no match' do
    results = level.call(term: 'ZzZzNomatch999', project_id: taxon_name.project_id)
    expect(results).to be_empty
  end
end

RSpec.describe Autoselect::TaxonName::Levels::CatalogOfLife do
  let(:level) { described_class.new }

  it 'is external' do
    expect(level.external?).to be true
  end

  it 'has fuse_ms of 2000' do
    expect(level.fuse_ms).to eq(2000)
  end

  context 'when CoL is unavailable' do
    before do
      allow(::Vendor::Colrapi).to receive(:search).and_return({ 'total' => 0, 'result' => [] })
    end

    it 'returns empty array gracefully' do
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
      expect(results.first._col_extension).to include(:col_key, :col_name)
    end

    it 'pseudo-records have nil id' do
      results = level.call(term: 'Homo sapiens', project_id: 1)
      expect(results.first.id).to be_nil
    end
  end
end
