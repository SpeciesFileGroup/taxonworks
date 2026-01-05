# frozen_string_literal: true

require 'rails_helper'

describe Export::Dwca::Checklist::Data, type: :model, group: :darwin_core do
  # Speed strategy:
  # - Create all heavy fixture data once per file (outside per-example DBCleaner transactions)
  # - Cache generated TSV strings (frozen master + per-call dup) so we don't regenerate
  #   and renormalize taxonomy for each example.

  before(:context) do
    Current.user_id = 1
    Current.project_id = 1
    DwcaChecklistSpecSupport::Fixtures.setup_once!
  end

  after(:context) do
    DwcaChecklistSpecSupport::Fixtures.cleanup!
  end

  let(:otu_scope) { { otu_id: DwcaChecklistSpecSupport::Fixtures.scope_otu_ids } }

  def cached_csv(scope:, extensions: nil, accepted_name_mode: nil)
    key = [
      'scope', scope[:otu_id].sort.join(','),
      'ext', Array(extensions).sort.join(','),
      'mode', accepted_name_mode.to_s
    ].join('|')

    DwcaChecklistSpecSupport::CsvCache.fetch(key) do
      params = { core_otu_scope_params: scope }
      params[:extensions] = extensions if extensions
      params[:accepted_name_mode] = accepted_name_mode if accepted_name_mode

      described_class.new(**params).csv
    end
  end

  def parsed_csv(scope:, extensions: nil, accepted_name_mode: nil)
    CSV.parse(
      cached_csv(scope: scope, extensions: extensions, accepted_name_mode: accepted_name_mode),
      headers: true,
      col_sep: "\t"
    )
  end

  context 'when initialized with a scope' do
    let(:data) { described_class.new(core_otu_scope_params: otu_scope) }

    specify '#csv returns csv String' do
      expect(cached_csv(scope: otu_scope)).to be_kind_of(String)
    end

    specify '#no_records? is false' do
      expect(data.no_records?).to be false
    end
  end

  context 'core CSV content' do
    let(:csv) { parsed_csv(scope: otu_scope) }

    specify '#total is 5 (3 specimens + 2 asserted distributions)' do
      data = described_class.new(core_otu_scope_params: otu_scope)
      expect(data.total).to eq(5)
    end

    specify 'headers include id' do
      expect(csv.headers).to include('id')
    end

    specify 'headers include taxonID' do
      expect(csv.headers).to include('taxonID')
    end

    specify 'headers include scientificName' do
      expect(csv.headers).to include('scientificName')
    end

    specify 'dwcClass column is converted to "class" in header' do
      expect(csv.headers).to include('class')
    end

    specify 'dwcClass column is not present in header' do
      expect(csv.headers).not_to include('dwcClass')
    end

    specify 'occurrenceID is excluded from headers' do
      expect(csv.headers).not_to include('occurrenceID')
    end

    specify 'each row id equals taxonID (sequential IDs after normalization)' do
      ok = csv.all? { |row| row['id'] == row['taxonID'] }
      expect(ok).to be true
    end

    specify 'non-root rows include higherClassification' do
      # The root taxon (Animalia) has no parent, so no higherClassification
      # All other rows should have higherClassification
      non_root_rows = csv.reject { |row| row['scientificName'] == 'Animalia' }
      ok = non_root_rows.all? { |row| row['higherClassification'].present? }
      expect(ok).to be true
    end
  end

  context 'with distribution extension' do
    let(:extensions) { [described_class::DISTRIBUTION_EXTENSION] }
    let(:data) { described_class.new(core_otu_scope_params: otu_scope, extensions: extensions) }

    specify 'distribution_extension flag is set when extension is requested' do
      expect(data.species_distribution_extension).to be true
    end
  end

  context 'with references extension' do
    let(:extensions) { [described_class::REFERENCES_EXTENSION] }
    let(:data) { described_class.new(core_otu_scope_params: otu_scope, extensions: extensions) }

    specify 'references_extension_tmp returns Tempfile when extension requested' do
      expect(data.references_extension_tmp).to be_a(Tempfile)
    end
  end

  context 'with types and specimen extension' do
    let(:extensions) { [described_class::TYPES_AND_SPECIMEN_EXTENSION] }
    let(:data) { described_class.new(core_otu_scope_params: otu_scope, extensions: extensions) }

    specify 'types_and_specimen_extension_tmp returns Tempfile when extension requested' do
      expect(data.types_and_specimen_extension_tmp).to be_a(Tempfile)
    end
  end

  context 'with vernacular name extension' do
    let(:extensions) { [described_class::VERNACULAR_NAME_EXTENSION] }
    let(:data) { described_class.new(core_otu_scope_params: otu_scope, extensions: extensions) }

    specify 'vernacular_name_extension_tmp returns Tempfile when extension requested' do
      expect(data.vernacular_name_extension_tmp).to be_a(Tempfile)
    end
  end

  context 'with description extension' do
    let(:extensions) { [described_class::DESCRIPTION_EXTENSION] }
    let(:data) { described_class.new(core_otu_scope_params: otu_scope, extensions: extensions) }

    specify 'description_extension_tmp returns Tempfile when extension requested' do
      expect(data.description_extension_tmp).to be_a(Tempfile)
    end
  end

  context 'with no matching records' do
    let(:empty_scope) { { otu_id: [-1] } }

    specify '#no_records? is true' do
      data = described_class.new(core_otu_scope_params: empty_scope)
      expect(data.no_records?).to be true
    end

    specify '#csv is newline' do
      expect(cached_csv(scope: empty_scope)).to eq("\n")
    end
  end
end
