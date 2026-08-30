require 'rails_helper'

RSpec.describe Autoselect::TaxonName::Levels::ColValidName, type: :model do
  subject(:level) { described_class.new }

  describe '#key, #label, #external?' do
    it 'has key :col_valid_name' do
      expect(level.key).to eq(:col_valid_name)
    end

    it 'is external' do
      expect(level.external?).to be true
    end
  end

  describe '#call' do
    context 'when CoL has no match for the term' do
      before { allow(::Vendor::Colrapi).to receive(:resolve_accepted_name).and_return(nil) }

      it 'returns an empty array' do
        expect(level.call(term: 'Nonsense', project_id:, user_id:)).to eq([])
      end
    end

    context 'when CoL resolves the term' do
      # The accepted nameusage hash resolve_accepted_name hands back for the valid name.
      let(:valid_col_result) do
        { 'id' => 'VALID1', 'status' => 'accepted',
          'name' => { 'scientificName' => 'Panthera leo', 'rank' => 'species', 'authorship' => 'Linnaeus, 1758' } }
      end
      let(:built_record) do
        OpenStruct.new(
          cached: 'Panthera leo',
          _col_extension: { col_key: 'VALID1', col_name: 'leo', col_status: 'accepted', col_rank: 'species', col_authorship: 'Linnaeus, 1758' }
        )
      end
      let(:fake_catalogue_of_life_level) { instance_double(::Autoselect::TaxonName::Levels::CatalogueOfLife) }

      before do
        allow(::Vendor::Colrapi).to receive(:resolve_accepted_name)
          .with('Panthera leo persica', dataset_id: nil)
          .and_return(
            input: 'Panthera leo persica', matched_name: 'Panthera leo persica', matched_status: 'synonym',
            matched_col_key: 'MATCHED1', valid_name: 'Panthera leo', valid_col_key: 'VALID1',
            valid_authorship: 'Linnaeus, 1758', valid_status: 'accepted',
            valid_col_result:, dataset_id: '3LR'
          )
        allow(::Autoselect::TaxonName::Levels::CatalogueOfLife).to receive(:new).and_return(fake_catalogue_of_life_level)
        allow(fake_catalogue_of_life_level).to receive(:build_pseudo_record)
          .with(valid_col_result, hash_including(dataset_id: '3LR'))
          .and_return(built_record)
      end

      it 'builds the extension from the resolved accepted usage, with no second CoL search' do
        expect(::Vendor::Colrapi).not_to receive(:search)
        level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(fake_catalogue_of_life_level).to have_received(:build_pseudo_record).with(valid_col_result, anything)
      end

      it 'returns a single record for the resolved valid name' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.length).to eq(1)
        expect(result.first.cached).to eq('Panthera leo')
      end

      it 'flags the result with resolved_from' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.first._col_extension[:resolved_from]).to eq('Panthera leo persica')
      end

      it 'preserves the rest of the underlying _col_extension (e.g. col_authorship)' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.first._col_extension[:col_authorship]).to eq('Linnaeus, 1758')
      end
    end

    context 'when resolve_accepted_name returns no usable valid usage' do
      before do
        allow(::Vendor::Colrapi).to receive(:resolve_accepted_name)
          .and_return(valid_name: 'Something', valid_col_result: nil)
      end

      it 'returns an empty array' do
        expect(level.call(term: 'Something', project_id:, user_id:)).to eq([])
      end
    end
  end

  # Shared with Autoselect::Otu::Levels::ColValidName via
  # Autoselect::Levels::ColResolvedName. Every result here is a CoL creation
  # offer (never an existing TW match), so the source is always CoL.
  describe '#record_info / #record_info_html' do
    let(:renamed) do
      OpenStruct.new(name: 'Panthera leo', _col_extension: { resolved_from: 'Panthera leo persica' })
    end
    let(:unchanged) do
      OpenStruct.new(name: 'Panthera leo', _col_extension: { resolved_from: 'Panthera leo' })
    end

    it 'tags the CoL source and notes what was typed when CoL changed the name' do
      expect(level.record_info(renamed)).to eq(['CoL', 'valid name for "Panthera leo persica"'])
    end

    it 'omits the note when the typed term already is the valid name' do
      expect(level.record_info(unchanged)).to eq(['CoL'])
    end

    it 'renders the CoL icon in front of the "valid name for" badge' do
      html = level.record_info_html(renamed)
      expect(html).to start_with(described_class::COL_ICON)
      expect(html).to include('<span class="feedback feedback-thin feedback-warning">valid name for &quot;Panthera leo persica&quot;</span>')
    end

    it 'renders just the CoL icon when nothing was renamed' do
      expect(level.record_info_html(unchanged)).to eq(described_class::COL_ICON)
    end
  end
end
