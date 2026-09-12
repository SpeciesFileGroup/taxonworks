require 'rails_helper'

RSpec.describe Autoselect::AssertedEnvironment::Autoselect, type: :model do
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

    it 'includes fast, envo as level keys in map' do
      expect(config[:map]).to eq(%w[fast envo])
    end

    describe 'level metadata' do
      let(:levels_by_key) {
        config[:levels].index_by { |l| l[:key].to_s }
      }

      it 'fast level is not external' do
        expect(levels_by_key['fast'][:external]).to be false
      end

      it 'envo level is external' do
        expect(levels_by_key['envo'][:external]).to be true
      end

      it 'envo has a longer fuse_ms than fast' do
        expect(levels_by_key['envo'][:fuse_ms]).to be > levels_by_key['fast'][:fuse_ms]
      end
    end

    it 'excludes record-list and new-record operators' do
      keys = config[:operators].map { |o| o[:key] }
      expect(keys).not_to include('recent_mine', 'recent', 'pinboard', 'pinboard_top', 'new_record')
    end

    it 'keeps the generically-useful operators' do
      keys = config[:operators].map { |o| o[:key] }
      expect(keys).to include('help', 'preferences', 'show_info', 'external', 'level_number')
    end
  end

  describe 'term response, fast level' do
    let!(:asserted_environment) {
      FactoryBot.create(:valid_asserted_environment,
        uri: 'http://purl.obolibrary.org/obo/ENVO_00002007',
        uri_label: 'temperate forest biome')
    }

    subject(:result) {
      described_class.new(
        term: 'temperate',
        level: 'fast',
        project_id: asserted_environment.project_id,
        user_id:
      ).response
    }

    it 'returns matching records' do
      expect(result[:response].length).to eq(1)
    end

    it 'response items have required keys' do
      item = result[:response].first
      expect(item).to include(:id, :label, :label_html, :info_html, :response_values, :extension)
    end

    it 'response_values carries uri and uri_label (not just an id reference)' do
      item = result[:response].first
      expect(item[:response_values]).to eq(uri: asserted_environment.uri, uri_label: asserted_environment.uri_label)
    end

    it 'extension is empty' do
      expect(result[:response].first[:extension]).to eq({})
    end

    context 'with no matching records' do
      subject(:result) {
        described_class.new(
          term: 'ZzZzNomatch999',
          level: 'fast',
          project_id: asserted_environment.project_id,
          user_id:
        ).response
      }

      it 'response is empty' do
        expect(result[:response]).to eq([])
      end

      it 'next_level is envo' do
        expect(result[:next_level]).to eq('envo')
      end
    end
  end

  describe 'term response, envo level' do
    before do
      allow(::Vendor::Envo).to receive(:search).with('forest').and_return({
        results: [
          { iri: 'http://purl.obolibrary.org/obo/ENVO_00002007', label: 'temperate forest biome', description: 'A forest biome.', ontology_prefix: 'envo' }
        ],
        page: 1, per: 25, total: 1
      })
    end

    subject(:result) {
      described_class.new(term: 'forest', level: 'envo', project_id:, user_id:).response
    }

    it 'returns the ENVO result as a pseudo-record' do
      item = result[:response].first
      expect(item[:id]).to be_nil
      expect(item[:response_values]).to eq(uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')
    end

    it 'extension is empty (no create hook needed - response_values is enough)' do
      expect(result[:response].first[:extension]).to eq({})
    end

    it 'label_html includes the description' do
      expect(result[:response].first[:label_html]).to include('A forest biome.')
    end
  end

  describe 'level stack' do
    it 'has fast then envo, in that order' do
      keys = autoselect.levels.map(&:key)
      expect(keys).to eq(%i[fast envo])
    end
  end
end

RSpec.describe Autoselect::AssertedEnvironment::Levels::Fast, type: :model do
  let(:level) { described_class.new }

  it 'is not external' do
    expect(level.external?).to be false
  end

  it 'returns [] for a blank term' do
    expect(level.call(term: '', project_id: 1)).to eq([])
  end

  it 'matches by uri_label prefix, scoped to project' do
    a = FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')
    other_project = FactoryBot.create(:valid_project)
    FactoryBot.create(:valid_asserted_environment, project: other_project, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')

    results = level.call(term: 'temperate', project_id: a.project_id)
    expect(results.map(&:id)).to contain_exactly(a.id)
  end

  it 'deduplicates by uri' do
    a = FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')
    FactoryBot.create(:valid_collecting_event_asserted_environment,
      uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')

    results = level.call(term: 'temperate', project_id: a.project_id)
    expect(results.map(&:uri).uniq.length).to eq(results.length)
  end
end

RSpec.describe Autoselect::AssertedEnvironment::Levels::Envo, type: :model do
  let(:level) { described_class.new }

  it 'is external' do
    expect(level.external?).to be true
  end

  it 'has the external fuse_ms' do
    expect(level.fuse_ms).to eq(2000)
  end

  it 'returns [] for a blank term' do
    expect(level.call(term: '')).to eq([])
  end

  context 'when Envo is unavailable' do
    before do
      allow(::Vendor::Envo).to receive(:search).and_return({ results: [], page: 1, per: 25, total: 0 })
    end

    it 'returns an empty array gracefully' do
      expect(level.call(term: 'forest')).to eq([])
    end
  end
end
