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

    it 'includes fast, smart, catalogue_of_life as level keys in map' do
      expect(config[:map]).to include('fast', 'smart', 'catalogue_of_life')
    end

    it 'includes !n operator trigger' do
      triggers = config[:operators].map { |o| o[:trigger] }
      expect(triggers).to include('!n')
    end
  end

  describe 'level stack' do
    it 'has three levels in order: fast → smart → catalogue_of_life' do
      keys = autoselect.levels.map { |l| l.key.to_s }
      expect(keys).to eq(%w[fast smart catalogue_of_life])
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

RSpec.describe Autoselect::Otu::Levels::Fast, type: :model do
  subject(:level) { described_class.new }

  let(:project) { FactoryBot.create(:valid_project) }

  it 'returns empty array when term is blank' do
    expect(level.call(term: '', project_id: project.id)).to eq([])
  end

  # Pattern 1 — Otu#name, taxon_name_id IS NULL
  context 'pattern 1: standalone OTU name (no taxon_name)' do
    let!(:otu_exact)  { FactoryBot.create(:valid_otu, name: 'Berlinia',   taxon_name: nil, project: project) }
    let!(:otu_prefix) { FactoryBot.create(:valid_otu, name: 'Berliniana', taxon_name: nil, project: project) }
    let!(:otu_miss)   { FactoryBot.create(:valid_otu, name: 'Quercus',    taxon_name: nil, project: project) }

    it 'returns exact match' do
      expect(level.call(term: 'Berlinia', project_id: project.id)).to include(otu_exact)
    end

    it 'returns prefix match' do
      expect(level.call(term: 'Berli', project_id: project.id)).to include(otu_exact, otu_prefix)
    end

    it 'does not return non-matching OTU' do
      expect(level.call(term: 'Berli', project_id: project.id)).not_to include(otu_miss)
    end
  end

  # Pattern 2 — TaxonName#cached prefix
  # valid_taxon_name carries its own internal project; use that project for the OTU too.
  context 'pattern 2: OTU backed by a matching TaxonName#cached' do
    let!(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
    let!(:otu)        { FactoryBot.create(:valid_otu, taxon_name: taxon_name, project_id: taxon_name.project_id) }

    it 'returns OTU when TaxonName#cached matches exactly' do
      results = level.call(term: taxon_name.cached, project_id: taxon_name.project_id)
      expect(results).to include(otu)
    end

    it 'returns OTU when TaxonName#cached matches by prefix' do
      prefix = taxon_name.cached[0, 3]
      results = level.call(term: prefix, project_id: taxon_name.project_id)
      expect(results).to include(otu)
    end
  end

  # Pattern 3 — Multi-word hybrid: every split of the term into taxon prefix + OTU part.
  # Both halves use prefix matching, so 'P PE01' matches TaxonName cached='Pheidole', OTU name='PE01'.
  context 'pattern 3: multi-word hybrid (TaxonName prefix + Otu#name prefix)' do
    let!(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
    let!(:otu)        { FactoryBot.create(:valid_otu, name: 'sp 123', taxon_name: taxon_name, project_id: taxon_name.project_id) }

    it 'matches when full taxon cached + full OTU name given' do
      term = "#{taxon_name.cached} sp 123"
      expect(level.call(term: term, project_id: taxon_name.project_id)).to include(otu)
    end

    it 'matches when OTU part is a prefix' do
      term = "#{taxon_name.cached} sp"
      expect(level.call(term: term, project_id: taxon_name.project_id)).to include(otu)
    end

    it 'matches when taxon part is an abbreviated prefix (e.g. P PE01 style)' do
      prefix = taxon_name.cached[0, 1]  # single-letter abbreviation
      term   = "#{prefix} sp 123"
      expect(level.call(term: term, project_id: taxon_name.project_id)).to include(otu)
    end

    it 'matches when taxon part is a multi-char prefix' do
      prefix = taxon_name.cached[0, 3]
      term   = "#{prefix} sp"
      expect(level.call(term: term, project_id: taxon_name.project_id)).to include(otu)
    end
  end

  context 'project scoping' do
    let(:other_project) { FactoryBot.create(:valid_project) }
    let!(:otu_mine)  { FactoryBot.create(:valid_otu, name: 'Scoparia', taxon_name: nil, project: project) }
    let!(:otu_other) { FactoryBot.create(:valid_otu, name: 'Scoparia', taxon_name: nil, project: other_project) }

    it 'does not return OTUs from other projects' do
      results = level.call(term: 'Scoparia', project_id: project.id)
      expect(results).to include(otu_mine)
      expect(results).not_to include(otu_other)
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

RSpec.describe Autoselect::Otu::Levels::CatalogueOfLife do
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

    it 'extension hook points to OTU create endpoint and yields otu_id' do
      results = level.call(term: 'Homo sapiens', project_id: 1)
      expect(results.first._col_extension[:hook]).to include(
        create_url: '/otus/autoselect_col_create',
        yields:     'otu_id'
      )
    end
  end
end
