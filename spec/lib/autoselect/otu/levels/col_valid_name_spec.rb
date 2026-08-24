require 'rails_helper'

RSpec.describe Autoselect::Otu::Levels::ColValidName, type: :model do
  subject(:level) { described_class.new }

  let(:fake_taxon_name_level) { instance_double(::Autoselect::TaxonName::Levels::ColValidName) }

  def stub_resolved_taxon_name(term:, valid_name:, records:)
    allow(::Autoselect::TaxonName::Levels::ColValidName).to receive(:new).and_return(fake_taxon_name_level)
    allow(fake_taxon_name_level).to receive(:call)
      .with(hash_including(term:))
      .and_return(records)
  end

  def resolved_record(valid_name:, resolved_from:, extra_extension: {})
    OpenStruct.new(
      cached: valid_name,
      _col_extension: { col_key: 'VALID1', col_status: 'accepted', col_rank: 'species', resolved_from: }.merge(extra_extension)
    )
  end

  describe '#key, #label, #external?' do
    it 'has key :col_valid_name' do
      expect(level.key).to eq(:col_valid_name)
    end

    it 'is external' do
      expect(level.external?).to be true
    end
  end

  describe '#call' do
    context 'when the TaxonName level resolves nothing' do
      before { stub_resolved_taxon_name(term: 'Nonsense', valid_name: nil, records: []) }

      it 'returns an empty array' do
        expect(level.call(term: 'Nonsense', project_id:, user_id:)).to eq([])
      end
    end

    context 'when resolved but no local OTU matches the valid name' do
      let(:record) { resolved_record(valid_name: 'Panthera leo', resolved_from: 'Panthera leo persica') }

      before { stub_resolved_taxon_name(term: 'Panthera leo persica', valid_name: 'Panthera leo', records: [record]) }

      it 'offers to create the resolved valid name' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.length).to eq(1)
        expect(result.first.name).to eq('Panthera leo')
      end

      it 'flags the offer with resolved_from and the OTU creation hook' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:resolved_from]).to eq('Panthera leo persica')
        expect(ext[:hook]).to eq(create_url: '/otus/autoselect_col_create', yields: 'otu_id')
      end
    end

    context 'when resolved and a local OTU matches the valid name exactly' do
      let!(:otu) { ::Otu.create!(name: 'Panthera leo', project_id:, by: user_id) }
      let(:record) { resolved_record(valid_name: 'Panthera leo', resolved_from: 'Panthera leo persica') }

      before { stub_resolved_taxon_name(term: 'Panthera leo persica', valid_name: 'Panthera leo', records: [record]) }

      it 'returns the matching Otu instead of a creation offer' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result).to contain_exactly(otu)
      end

      it 'attaches _col_resolution provenance to the record' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.first._col_resolution).to eq(input: 'Panthera leo persica', valid_name: 'Panthera leo')
      end
    end

    context 'when multiple local OTUs match the valid name' do
      let!(:otu_a) { ::Otu.create!(name: 'Panthera leo', project_id:, by: user_id) }
      let!(:otu_b) { ::Otu.create!(name: 'Panthera leo', project_id:, by: user_id) }
      let(:record) { resolved_record(valid_name: 'Panthera leo', resolved_from: 'leo') }

      before { stub_resolved_taxon_name(term: 'leo', valid_name: 'Panthera leo', records: [record]) }

      it 'returns all matching Otus, letting the normal dropdown handle disambiguation' do
        expect(level.call(term: 'leo', project_id:, user_id:)).to contain_exactly(otu_a, otu_b)
      end
    end
  end

  describe '#record_info' do
    let!(:otu) { ::Otu.create!(name: 'Panthera leo', project_id:, by: user_id) }

    it 'leads with a TW source tag for an existing-match record — CoL only helped find it' do
      otu.define_singleton_method(:_col_resolution) { { input: 'Panthera leo persica', valid_name: 'Panthera leo' } }
      expect(level.record_info(otu)).to eq(['TW', 'valid name for "Panthera leo persica"'])
    end

    it 'falls back to the default record_info for records without _col_resolution or _col_extension' do
      expect(level.record_info(otu)).to be_an(Array)
    end

    it 'shows just the TW source tag, no "valid name for" note, when the typed term already is the valid name' do
      otu.define_singleton_method(:_col_resolution) { { input: 'Panthera leo', valid_name: 'Panthera leo' } }
      expect(level.record_info(otu)).to eq(['TW'])
    end

    it 'leads with a CoL source tag for a creation offer — still purely CoL data, not yet in TW' do
      offer = OpenStruct.new(
        name: 'Panthera leo',
        _col_extension: { col_status: 'accepted', col_rank: 'species', resolved_from: 'Panthera leo persica' }
      )
      expect(level.record_info(offer)).to eq(['CoL', 'valid name for "Panthera leo persica"'])
    end

    it 'shows just the CoL source tag, no "valid name for" note, for a creation offer when the typed term already is the valid name' do
      offer = OpenStruct.new(
        name: 'Panthera leo',
        _col_extension: { col_status: 'accepted', resolved_from: 'Panthera leo' }
      )
      expect(level.record_info(offer)).to eq(['CoL'])
    end
  end

  describe '#record_info_html' do
    let!(:otu) { ::Otu.create!(name: 'Panthera leo', project_id:, by: user_id) }

    it 'renders the TW icon in front of the "valid name for" badge, for an existing-match record' do
      otu.define_singleton_method(:_col_resolution) { { input: 'Panthera leo persica', valid_name: 'Panthera leo' } }
      html = level.record_info_html(otu)
      expect(html).to start_with(described_class::TW_ICON)
      expect(html).to include('<span class="feedback feedback-thin feedback-warning">valid name for &quot;Panthera leo persica&quot;</span>')
      expect(html).not_to include(described_class::COL_ICON)
    end

    it 'renders the CoL icon in front of the "valid name for" badge, for a creation offer' do
      offer = OpenStruct.new(
        name: 'Panthera leo',
        _col_extension: { col_status: 'synonym', col_rank: 'species', resolved_from: 'Panthera leo persica' }
      )
      html = level.record_info_html(offer)
      expect(html).to start_with(described_class::COL_ICON)
      expect(html).to include('<span class="feedback feedback-thin feedback-warning">valid name for &quot;Panthera leo persica&quot;</span>')
      expect(html).not_to include(described_class::TW_ICON)
    end

    it 'falls back to the default record_info_html for records without CoL provenance' do
      expect(level.record_info_html(otu)).not_to include('valid name for')
    end

    it 'renders just the TW icon, no "valid name for" badge, when the typed term already is the valid name' do
      otu.define_singleton_method(:_col_resolution) { { input: 'Panthera leo', valid_name: 'Panthera leo' } }
      expect(level.record_info_html(otu)).to eq(described_class::TW_ICON)
    end
  end
end
