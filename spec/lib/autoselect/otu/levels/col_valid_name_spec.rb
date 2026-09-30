require 'rails_helper'

RSpec.describe Autoselect::Otu::Levels::ColValidName, type: :model do
  subject(:level) { described_class.new }

  let(:fake_taxon_name_level) { instance_double(::Autoselect::TaxonName::Levels::ColValidName) }

  # The OTU level uses TaxonName::ColValidName#resolve_target (the raw pseudo-record),
  # not #call — it makes its own existing-Otu decision.
  def stub_resolve_target(term:, target:)
    allow(::Autoselect::TaxonName::Levels::ColValidName).to receive(:new).and_return(fake_taxon_name_level)
    allow(fake_taxon_name_level).to receive(:resolve_target)
      .with(term, hash_including(project_id:))
      .and_return(target)
  end

  def resolved_record(valid_name:, extra_extension: {})
    OpenStruct.new(
      cached: valid_name,
      _col_extension: { col_key: 'VALID1', col_status: 'accepted', col_rank: 'species' }.merge(extra_extension)
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
    context 'when CoL resolves nothing' do
      before { stub_resolve_target(term: 'Nonsense', target: nil) }

      it 'returns an empty array' do
        expect(level.call(term: 'Nonsense', project_id:, user_id:)).to eq([])
      end
    end

    context 'when resolved and the name has no OTU' do
      let(:target) { resolved_record(valid_name: 'Panthera leo') }

      before { stub_resolve_target(term: 'Panthera leo persica', target:) }

      it 'returns a single CoL result for the resolved valid name' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        expect(result.length).to eq(1)
        expect(result.first.name).to eq('Panthera leo')
      end

      it 'flags it with resolved_from and an OTU creation hook with no ' \
        'existing OTU' do
        result = level.call(term: 'Panthera leo persica', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:resolved_from]).to eq('Panthera leo persica')
        expect(ext[:hook]).to eq(
          create_url: '/otus/autoselect_col_create', yields: 'otu_id',
          existing_id: nil, existing_global_id: nil
        )
      end
    end

    # The existing OTU is found via the TaxonName resolve_target matched, so
    # it's found even when CoL writes the name differently (see
    # Vendor::Colrapi::NameTranslation).
    context 'when resolved and the name already has an OTU' do
      let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
      let(:species) { subspecies.parent }
      let(:subgenus) { species.parent }

      def call_for(taxon_name, valid_name)
        target = resolved_record(
          valid_name:,
          extra_extension: { target_taxonworks_id: taxon_name.id }
        )
        stub_resolve_target(term: valid_name, target:)
        level.call(term: valid_name, project_id:, user_id:)
      end

      it 'still returns the CoL result, its hook carrying the OTU' do
        otu = ::Otu.create!(taxon_name: species, project_id:, by: user_id)
        result = call_for(species, 'Erythroneura vitis')

        expect(result.length).to eq(1)
        expect(result.first._col_extension[:hook]).to include(
          existing_id: otu.id, existing_global_id: otu.to_global_id.to_s
        )
      end

      it 'finds the OTU of a subgenus CoL gives as a bare epithet' do
        otu = ::Otu.create!(taxon_name: subgenus, project_id:, by: user_id)
        result = call_for(subgenus, 'Erythroneura')
        expect(result.first._col_extension[:hook][:existing_id]).to eq(otu.id)
      end
    end
  end

  describe '#record_info / #record_info_html' do
    def result(resolved_from:, existing_id: nil)
      OpenStruct.new(
        name: 'Panthera leo',
        _col_extension: {
          col_status: 'accepted', col_rank: 'species', resolved_from:,
          hook: { create_url: '/otus/autoselect_col_create', yields: 'otu_id', existing_id: }
        }
      )
    end

    it 'tags the TW source when the name already has an OTU' do
      expect(level.record_info(result(resolved_from: 'Panthera leo persica', existing_id: 1)))
        .to eq(['TW', 'species', 'valid name for "Panthera leo persica"'])
    end

    it 'tags the CoL source when an OTU would be created' do
      expect(level.record_info(result(resolved_from: 'Panthera leo persica')))
        .to eq(['CoL', 'species', 'valid name for "Panthera leo persica"'])
    end

    it 'omits the note when the typed term already is the valid name' do
      expect(level.record_info(result(resolved_from: 'Panthera leo')))
        .to eq(['CoL', 'species'])
    end

    it 'renders the TW icon in front of the "valid name for" badge' do
      html = level.record_info_html(result(resolved_from: 'Panthera leo persica', existing_id: 1))
      expect(html).to start_with(described_class::TW_ICON)
      expect(html).to include('<span class="feedback feedback-thin feedback-warning">valid name for &quot;Panthera leo persica&quot;</span>')
      expect(html).not_to include(described_class::COL_ICON)
    end

    it 'renders the CoL icon in front of the "valid name for" badge' do
      html = level.record_info_html(result(resolved_from: 'Panthera leo persica'))
      expect(html).to start_with(described_class::COL_ICON)
      expect(html).not_to include(described_class::TW_ICON)
    end

    it 'renders just the icon and rank when nothing was renamed' do
      expect(level.record_info_html(result(resolved_from: 'Panthera leo')))
        .to eq(described_class::COL_ICON +
          '<span class="feedback feedback-thin feedback-light">species</span>')
    end
  end
end
