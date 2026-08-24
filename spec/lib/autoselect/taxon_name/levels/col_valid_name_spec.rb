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
      let(:matched_record) do
        OpenStruct.new(
          cached: 'Panthera leo',
          _col_extension: { col_key: 'VALID1', col_name: 'leo', col_status: 'accepted', col_rank: 'species', col_authorship: 'Linnaeus, 1758' }
        )
      end
      let(:other_record) do
        OpenStruct.new(cached: 'Panthera leo persica', _col_extension: { col_key: 'OTHER1' })
      end
      let(:fake_catalogue_of_life_level) { instance_double(::Autoselect::TaxonName::Levels::CatalogueOfLife) }

      before do
        allow(::Vendor::Colrapi).to receive(:resolve_accepted_name)
          .with('Panthera leo persica', dataset_id: nil)
          .and_return(
            input: 'Panthera leo persica', matched_name: 'Panthera leo persica', matched_status: 'synonym',
            matched_col_key: 'MATCHED1', valid_name: 'Panthera leo', valid_col_key: 'VALID1',
            valid_authorship: 'Linnaeus, 1758', valid_status: 'accepted', dataset_id: '3LR'
          )
        allow(::Autoselect::TaxonName::Levels::CatalogueOfLife).to receive(:new).and_return(fake_catalogue_of_life_level)
        allow(fake_catalogue_of_life_level).to receive(:call)
          .with(hash_including(term: 'Panthera leo', dataset_id: '3LR'))
          .and_return([other_record, matched_record])
      end

      it 'searches CatalogueOfLife for the resolved valid name, not the raw term' do
        level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(fake_catalogue_of_life_level).to have_received(:call).with(hash_including(term: 'Panthera leo'))
      end

      it 'returns only the record matching the resolved valid_col_key' do
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

      context 'and CatalogueOfLife has nothing at all for the valid name' do
        before do
          allow(fake_catalogue_of_life_level).to receive(:call)
            .with(hash_including(term: 'Panthera leo'))
            .and_return([])
        end

        it 'returns an empty array' do
          expect(level.call(term: 'Panthera leo persica', project_id:, user_id:)).to eq([])
        end
      end
    end
  end
end
