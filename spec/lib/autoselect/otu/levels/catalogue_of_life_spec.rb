require 'rails_helper'

RSpec.describe Autoselect::Otu::Levels::CatalogueOfLife, type: :model do
  subject(:level) { described_class.new }

  let(:taxon_name_level) do
    instance_double(::Autoselect::TaxonName::Levels::CatalogueOfLife)
  end

  let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
  let(:species) { subspecies.parent }

  # A TaxonName-level CoL pseudo-record, as
  # TaxonName::Levels::CatalogueOfLife#call returns them.
  def col_record(cached, target_taxonworks_id: nil)
    OpenStruct.new(
      id: nil,
      cached:,
      _col_extension: {
        col_key: "KEY-#{cached}", col_status: 'accepted', col_rank: 'species',
        target_taxonworks_id:
      }.compact
    )
  end

  def stub_col_records(*records)
    allow(::Autoselect::TaxonName::Levels::CatalogueOfLife)
      .to receive(:new).and_return(taxon_name_level)
    allow(taxon_name_level).to receive(:call).and_return(records)
  end

  describe '#call' do
    # Still a CoL result, so the confirmation modal can show missing ancestors.
    it 'returns the CoL result for a name that already has an OTU, its hook ' \
      'carrying the OTU' do
      otu = ::Otu.create!(taxon_name: species, project_id:, by: user_id)
      # CoL writes it without the subgenus TaxonWorks has
      stub_col_records(
        col_record('Erythroneura vitis', target_taxonworks_id: species.id)
      )

      result = level.call(term: 'Erythroneura vitis', project_id:, user_id:)
      expect(result.length).to eq(1)
      expect(result.first._col_extension[:hook]).to eq(
        create_url: '/otus/autoselect_col_create', yields: 'otu_id',
        existing_id: otu.id, existing_global_id: otu.to_global_id.to_s
      )
    end

    it 'has no existing OTU in the hook for a name without one' do
      stub_col_records(
        col_record('Erythroneura vitis', target_taxonworks_id: species.id),
        col_record('Erythroneura novus')
      )

      result = level.call(term: 'Erythroneura', project_id:, user_id:)
      expect(result.map { |r| r._col_extension[:hook][:existing_id] })
        .to eq([nil, nil])
    end
  end

  describe '#record_info_html' do
    def result(existing_id)
      OpenStruct.new(
        name: 'Aus bus',
        _col_extension: {
          col_status: 'accepted',
          hook: { create_url: '/otus/autoselect_col_create', yields: 'otu_id', existing_id: }
        }
      )
    end

    it 'marks a name that already has an OTU with the TW icon' do
      expect(level.record_info_html(result(1)))
        .to start_with(described_class::TW_ICON)
    end

    it 'marks a name without an OTU with the CoL icon' do
      expect(level.record_info_html(result(nil)))
        .to start_with(described_class::COL_ICON)
    end
  end
end
