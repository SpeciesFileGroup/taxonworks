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

  # Autoselect::TaxonName::Autoselect#format_results passes the term.
  describe '#record_label_html' do
    it 'accepts the search term' do
      record = OpenStruct.new(cached: 'Panthera leo', _col_extension: { col_name: 'leo' })
      expect { level.record_label_html(record, 'Panthera') }.not_to raise_error
    end
  end

  describe '#call' do
    context 'when CoL has no match for the term' do
      before { allow(::Vendor::Colrapi).to receive(:resolve_accepted_names).and_return([]) }

      it 'returns an empty array' do
        expect(level.call(term: 'Nonsense', project_id:, user_id:)).to eq([])
      end
    end

    context 'when CoL resolves the term' do
      # The accepted nameusage hash resolve_accepted_names hands back for the valid name.
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
      let(:fake_col_match) do
        instance_double(::Autoselect::TaxonName::ColMatch, call: built_record)
      end

      before do
        allow(::Vendor::Colrapi).to receive(:resolve_accepted_names)
          .with('Panthera leo persica', dataset_id: nil)
          .and_return([{
            input: 'Panthera leo persica', matched_name: 'Panthera leo persica',
            matched_authorship: 'Meyer, 1826', matched_status: 'synonym',
            matched_col_key: 'MATCHED1', valid_name: 'Panthera leo', valid_col_key: 'VALID1',
            valid_authorship: 'Linnaeus, 1758', valid_status: 'accepted',
            valid_col_result:, dataset_id: '3LR'
          }])
        allow(::Autoselect::TaxonName::ColMatch).to receive(:new)
          .with(valid_col_result, hash_including(dataset_id: '3LR'))
          .and_return(fake_col_match)
      end

      it 'builds the extension from the resolved accepted usage, with no second CoL search' do
        expect(::Vendor::Colrapi).not_to receive(:search)
        level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(::Autoselect::TaxonName::ColMatch).to have_received(:new)
          .with(valid_col_result, anything)
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

      it 'records the synonym CoL followed, with its authorship' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.first._col_extension[:resolved_synonym])
          .to eq('Panthera leo persica Meyer, 1826')
      end

      context 'and CoL followed no synonymy' do
        before do
          allow(::Vendor::Colrapi).to receive(:resolve_accepted_names)
            .with('Panthera le', dataset_id: nil)
            .and_return([{
              input: 'Panthera le', matched_name: 'Panthera leo', matched_status: 'accepted',
              matched_col_key: 'VALID1', valid_name: 'Panthera leo', valid_col_key: 'VALID1',
              valid_authorship: 'Linnaeus, 1758', valid_status: 'accepted',
              valid_col_result:, dataset_id: '3LR'
            }])
        end

        it 'records no synonym' do
          result = level.call(term: 'Panthera le', project_id:, user_id:)
          expect(result.first._col_extension[:resolved_synonym]).to be_nil
        end
      end

      it 'preserves the rest of the underlying _col_extension (e.g. col_authorship)' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.first._col_extension[:col_authorship]).to eq('Linnaeus, 1758')
      end

      context 'and the accepted name is already a TaxonName in the project' do
        let(:existing_name) { FactoryBot.create(:iczn_species, name: 'leo') }
        let(:built_record) do
          OpenStruct.new(cached: existing_name.cached,
                         _col_extension: { col_key: 'VALID1', target_taxonworks_id: existing_name.id })
        end

        # Still a CoL result, so the confirmation modal can show missing ancestors.
        it 'returns the CoL result, pointing at the existing TaxonName' do
          result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
          expect(result.length).to eq(1)
          expect(result.first._col_extension[:target_taxonworks_id]).to eq(existing_name.id)
        end

        it 'renders it with the TW source' do
          record = level.call(term: 'Panthera leo persica', project_id:, user_id:).first
          expect(level.record_info(record).first).to eq('TW')
        end
      end
    end

    # Pieris: a butterfly genus and a plant genus.
    context 'when the term resolves to names in different codes' do
      def resolved(key, code)
        col_result = {
          'id' => key, 'status' => 'accepted',
          'name' => {
            'scientificName' => 'Pieris', 'rank' => 'genus', 'code' => code
          }
        }
        {
          input: 'Pieris', matched_name: 'Pieris', matched_status: 'accepted',
          matched_col_key: key, valid_name: 'Pieris', valid_col_key: key,
          valid_status: 'accepted', valid_col_result: col_result,
          dataset_id: '3LR'
        }
      end

      before do
        allow(::Vendor::Colrapi).to receive(:resolve_accepted_names)
          .and_return([resolved('Z1', 'zoological'), resolved('B1', 'botanical')])
        allow(::Autoselect::TaxonName::ColMatch).to receive(:new) do |col_result, **|
          instance_double(
            ::Autoselect::TaxonName::ColMatch,
            call: OpenStruct.new(
              cached: 'Pieris',
              _col_extension: {
                col_key: col_result['id'], col_rank: 'genus',
                col_code: col_result.dig('name', 'code')
              }
            )
          )
        end
      end

      it 'returns a record for each, badged with its code' do
        result = level.call(term: 'Pieris', project_id:, user_id:)
        expect(result.map { |r| level.record_info(r) })
          .to eq([%w{CoL genus ICZN}, %w{CoL genus ICN}])
      end
    end

    context 'when resolve_accepted_names returns no usable valid usage' do
      before do
        allow(::Vendor::Colrapi).to receive(:resolve_accepted_names)
          .and_return([{ valid_name: 'Something', valid_col_result: nil }])
      end

      it 'returns an empty array' do
        expect(level.call(term: 'Something', project_id:, user_id:)).to eq([])
      end
    end
  end

  # Shared with Autoselect::Otu::Levels::ColValidName via
  # Autoselect::Levels::ColResolvedName. A result whose name is already a
  # TaxonName (target_taxonworks_id) shows the TW source, else the CoL source.
  describe '#record_info / #record_info_html' do
    let(:renamed) do
      OpenStruct.new(
        name: 'Panthera leo',
        _col_extension: { resolved_from: 'Panthera leo pers', resolved_synonym: 'Panthera leo persica' }
      )
    end
    # Typed text differs from the result, but no synonymy was followed.
    let(:unchanged) do
      OpenStruct.new(name: 'Panthera leo', _col_extension: { resolved_from: 'Panthera le' })
    end
    let(:existing) do
      OpenStruct.new(
        name: 'Panthera leo',
        _col_extension: {
          resolved_from: 'Panthera leo persica', resolved_synonym: 'Panthera leo persica',
          target_taxonworks_id: 1
        }
      )
    end

    it 'tags the CoL source and notes the synonym CoL followed' do
      expect(level.record_info(renamed)).to eq(['CoL', 'valid name for "Panthera leo persica"'])
    end

    it 'tags the TW source when the name is already a TaxonName' do
      expect(level.record_info(existing)).to eq(['TW', 'valid name for "Panthera leo persica"'])
    end

    it 'omits the note when CoL followed no synonymy' do
      expect(level.record_info(unchanged)).to eq(['CoL'])
    end

    it 'renders the CoL icon in front of the "valid name for" badge' do
      html = level.record_info_html(renamed)
      expect(html).to start_with(described_class::COL_ICON)
      expect(html).to include('<span class="feedback feedback-thin feedback-warning">valid name for &quot;Panthera leo persica&quot;</span>')
    end

    it 'renders the TW icon when the name is already a TaxonName' do
      html = level.record_info_html(existing)
      expect(html).to start_with(described_class::TW_ICON)
      expect(html).not_to include(described_class::COL_ICON)
    end

    it 'renders just the CoL icon when nothing was renamed' do
      expect(level.record_info_html(unchanged)).to eq(described_class::COL_ICON)
    end

    context 'with CoL status and rank' do
      def result(col_status:, resolved_synonym: nil)
        OpenStruct.new(
          name: 'Panthera leo',
          _col_extension: {
            col_status:, col_rank: 'species', resolved_from: 'Panthera leo',
            resolved_synonym:
          }
        )
      end

      it 'shows the rank but not an accepted status' do
        expect(level.record_info(result(col_status: 'accepted')))
          .to eq(['CoL', 'species'])
      end

      it 'flags a status other than accepted' do
        expect(level.record_info(result(col_status: 'provisionally accepted')))
          .to eq(['CoL', 'provisionally accepted', 'species'])
      end

      it 'orders status and rank badges before the note' do
        html = level.record_info_html(
          result(col_status: 'provisionally accepted', resolved_synonym: 'Felis leo')
        )
        expect(html).to eq(
          described_class::COL_ICON +
          '<span class="feedback feedback-thin feedback-warning">' \
          'provisionally accepted</span> ' \
          '<span class="feedback feedback-thin feedback-light">species</span> ' \
          '<span class="feedback feedback-thin feedback-warning">' \
          'valid name for &quot;Felis leo&quot;</span>'
        )
      end
    end
  end
end
