require 'rails_helper'

# ColCreator needs a project root TaxonName to seed parent_id for the topmost created name.
# Model specs use project_id: 1 / user_id: 1 via Current; a root is created on demand below.

RSpec.describe Autoselect::TaxonName::ColCreator, type: :model do
  before(:each) { find_or_create_root_taxon_name }

  # Minimal row helper — creates a row hash as the modal would send it.
  def row(col_name:, col_rank:, col_id: nil, dataset_id: nil, taxonworks_id: nil, col_authorship: nil, col_year: nil, col_status: nil)
    {
      col_name:,
      col_rank:,
      col_id:,
      dataset_id:,
      taxonworks_id:,
      col_authorship:,
      col_year:,
      col_status:
    }
  end

  describe '#call' do
    context 'ICZN (zoological) names — explicit code' do
      let(:rows) do
        [
          row(col_name: 'Animalia',  col_rank: 'kingdom'),
          row(col_name: 'Hominidae', col_rank: 'family',  col_authorship: 'Gray, 1825', col_year: '1825'),
          row(col_name: 'Homo',      col_rank: 'genus',   col_authorship: 'Linnaeus, 1758'),
          row(col_name: 'sapiens',   col_rank: 'species', col_authorship: 'Linnaeus, 1758', col_year: '1758',
              col_id: 'HomoSapiensColId', dataset_id: '3LR')
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'returns a taxon_name_id' do
        expect(result[:taxon_name_id]).to be_a(Integer)
      end

      it 'creates the expected number of records' do
        expect { result }.to change(::TaxonName, :count).by(4)
      end

      it 'creates a ChecklistBank identifier for the target row' do
        result
        expected_uri = "#{::Identifier::Global::Uri::ChecklistBank::API_ROOT}/dataset/3LR/taxon/HomoSapiensColId"
        identifier = ::Identifier.where(identifier: expected_uri).first
        expect(identifier).not_to be_nil
        expect(identifier).to be_a(::Identifier::Global::Uri::ChecklistBank)
      end

      it 'assigns ICZN rank classes to created records' do
        result
        species = ::TaxonName.find_by(name: 'sapiens', project_id:)
        expect(species.rank_class.name).to include('Iczn')
      end


      it 'strips year from verbatim_author' do
        result
        species = ::TaxonName.find_by(name: 'sapiens', project_id:)
        expect(species.verbatim_author).to eq('Linnaeus')
        expect(species.year_of_publication).to eq(1758)
      end
    end

    context 'ICN (botanical) names — Quercus example' do
      # Representative CoL classification for Quercus robur (English oak), ICN code
      let(:rows) do
        [
          row(col_name: 'Plantae',   col_rank: 'kingdom'),
          row(col_name: 'Fagales',   col_rank: 'order'),
          row(col_name: 'Fagaceae',  col_rank: 'family',  col_authorship: 'Dumort., 1829'),
          row(col_name: 'Quercus',   col_rank: 'genus',   col_authorship: 'L.'),
          row(col_name: 'robur',     col_rank: 'species', col_authorship: 'L., 1753', col_year: '1753',
              col_id: 'QuercusRoburColId', dataset_id: '3LR')
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'botanical').call
      }

      it 'returns a taxon_name_id' do
        expect(result[:taxon_name_id]).to be_a(Integer)
      end

      it 'creates records for all rows' do
        expect { result }.to change(::TaxonName, :count).by(5)
      end

      it 'assigns ICN (not ICZN) rank class to species' do
        result
        species = ::TaxonName.find_by(name: 'robur', project_id:)
        expect(species.rank_class.name).to include('Icn')
        expect(species.rank_class.name).not_to include('Iczn')
      end

      it 'assigns ICN rank class to genus' do
        result
        genus = ::TaxonName.find_by(name: 'Quercus', project_id:)
        expect(genus.rank_class.name).to include('Icn')
        expect(genus.rank_class.name).not_to include('Iczn')
      end

      it 'assigns ICN rank class to family' do
        result
        family = ::TaxonName.find_by(name: 'Fagaceae', project_id:)
        expect(family.rank_class.name).to include('Icn')
      end

      it 'strips year from verbatim_author for species' do
        result
        species = ::TaxonName.find_by(name: 'robur', project_id:)
        expect(species.verbatim_author).to eq('L.')
        expect(species.year_of_publication).to eq(1753)
      end

      it 'creates a ChecklistBank identifier for the target row' do
        result
        expected_uri = "#{::Identifier::Global::Uri::ChecklistBank::API_ROOT}/dataset/3LR/taxon/QuercusRoburColId"
        identifier = ::Identifier.where(identifier: expected_uri).first
        expect(identifier).not_to be_nil
        expect(identifier).to be_a(::Identifier::Global::Uri::ChecklistBank)
      end
    end

    context 'when col_code is nil (fallback to ICZN-first order)' do
      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: 'sapiens',  col_rank: 'species', col_authorship: 'L., 1758', col_year: '1758')
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:).call
      }

      it 'still creates records when col_code is absent' do
        expect { result }.to change(::TaxonName, :count).by(2)
      end
    end

    context 'when a row has an existing taxonworks_id' do
      let!(:existing) { FactoryBot.create(:valid_taxon_name) }

      let(:rows) do
        [
          row(col_name: existing.cached, col_rank: 'family', taxonworks_id: existing.id),
          row(col_name: 'Aus', col_rank: 'genus', col_authorship: 'Smith, 1900', col_year: '1900')
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'does not create a duplicate for the existing name' do
        expect { result }.to change(::TaxonName, :count).by(1)
      end

      it 'uses the existing record as parent for the new name' do
        result
        genus = ::TaxonName.find_by(name: 'Aus', project_id:)
        expect(genus.parent_id).to eq(existing.id)
      end
    end

    context 'when a new row is inserted between two existing taxonworks_id rows' do
      let!(:family) { FactoryBot.create(:valid_taxon_name, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', name: 'Hominidae') }
      # valid_taxon_name's :parent_is_root trait forces parent to the project root on
      # create, overriding any explicit `parent:` passed in — reparent onto family after.
      let!(:genus) do
        g = FactoryBot.create(:valid_taxon_name, rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus', name: 'Homo')
        g.update!(parent: family)
        g
      end

      let(:rows) do
        [
          row(col_name: family.cached, col_rank: 'family', taxonworks_id: family.id),
          row(col_name: 'Homininae', col_rank: 'subfamily', col_authorship: 'Gray, 1825', col_year: '1825'),
          row(col_name: genus.cached, col_rank: 'genus', taxonworks_id: genus.id)
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'creates only the inserted (unmatched) row' do
        expect { result }.to change(::TaxonName, :count).by(1)
      end

      it "parents the inserted row on the existing row above it" do
        result
        subfamily = ::TaxonName.find_by(name: 'Homininae', project_id:)
        expect(subfamily.parent_id).to eq(family.id)
      end

      it 'reparents the existing row below the inserted row onto it' do
        result
        subfamily = ::TaxonName.find_by(name: 'Homininae', project_id:)
        expect(genus.reload.parent_id).to eq(subfamily.id)
      end

      it "does not touch the parent of the row above the inserted row" do
        expect { result }.not_to change { family.reload.parent_id }
      end
    end

    context 'when two consecutive new rows are inserted between two existing taxonworks_id rows' do
      let!(:family) { FactoryBot.create(:valid_taxon_name, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', name: 'Hominidae') }
      # See the single-insert context above for why genus is reparented after create.
      let!(:genus) do
        g = FactoryBot.create(:valid_taxon_name, rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus', name: 'Homo')
        g.update!(parent: family)
        g
      end

      let(:rows) do
        [
          row(col_name: family.cached, col_rank: 'family', taxonworks_id: family.id),
          row(col_name: 'Homininae', col_rank: 'subfamily', col_authorship: 'Gray, 1825', col_year: '1825'),
          row(col_name: 'Hominini', col_rank: 'tribe', col_authorship: 'Gray, 1825', col_year: '1825'),
          row(col_name: genus.cached, col_rank: 'genus', taxonworks_id: genus.id)
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      let(:subfamily) { ::TaxonName.find_by(name: 'Homininae', project_id:) }
      let(:tribe) { ::TaxonName.find_by(name: 'Hominini', project_id:) }

      it 'creates only the two inserted rows' do
        expect { result }.to change(::TaxonName, :count).by(2)
      end

      it 'parents the first inserted row on the existing row above it' do
        result
        expect(subfamily.parent_id).to eq(family.id)
      end

      it 'parents the second inserted row on the first' do
        result
        expect(tribe.parent_id).to eq(subfamily.id)
      end

      it 'reparents the existing row below onto the last inserted row' do
        result
        expect(genus.reload.parent_id).to eq(tribe.id)
      end

      it 'does not touch the parent of the row above the inserted rows' do
        expect { result }.not_to change { family.reload.parent_id }
      end
    end

    context 'when two consecutive rows already have taxonworks_ids and are already correctly linked' do
      let!(:family) { FactoryBot.create(:valid_taxon_name, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', name: 'Hominidae') }
      # valid_taxon_name's :parent_is_root trait forces parent to the project root on
      # create, overriding any explicit `parent:` passed in — reparent onto family after.
      let!(:genus) do
        g = FactoryBot.create(:valid_taxon_name, rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus', name: 'Homo')
        g.update!(parent: family)
        g
      end

      let(:rows) do
        [
          row(col_name: family.cached, col_rank: 'family', taxonworks_id: family.id),
          row(col_name: genus.cached, col_rank: 'genus', taxonworks_id: genus.id),
          row(col_name: 'sapiens', col_rank: 'species', col_authorship: 'Linnaeus, 1758', col_year: '1758')
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'does not issue an update for the already-correctly-linked existing row' do
        expect_any_instance_of(::TaxonName).not_to receive(:update!)
        result
      end

      it 'never falls back to a per-row find for an already-correctly-linked matched row' do
        found_ids = []
        allow(::TaxonName).to receive(:find).and_wrap_original do |original, id|
          found_ids << id
          original.call(id)
        end

        result

        expect(found_ids).not_to include(family.id, genus.id)
      end
    end

    context 'when the target (final) row has an existing taxonworks_id' do
      let!(:existing) { FactoryBot.create(:valid_taxon_name) }

      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: existing.cached, col_rank: 'genus', taxonworks_id: existing.id)
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'does not create a duplicate for the target' do
        expect { result }.to change(::TaxonName, :count).by(1) # only the ancestor
      end

      it 'returns the existing record as taxon_name_id, not a newly created one' do
        expect(result[:taxon_name_id]).to eq(existing.id)
      end
    end

    context 'when a row carries a taxonworks_id that does not resolve within the project' do
      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: 'Homo', col_rank: 'genus', taxonworks_id: 999_999_999)
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'raises CreationError rather than an uncaught RecordNotFound' do
        expect { result }.to raise_error(described_class::CreationError, /Unknown TaxonName id/)
      end

      it 'creates nothing' do
        expect { result rescue nil }.not_to change(::TaxonName, :count)
      end
    end

    context 'when a row carries a taxonworks_id belonging to another project' do
      let!(:other_project_name) { FactoryBot.create(:valid_taxon_name, project: FactoryBot.create(:valid_project)) }

      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: other_project_name.cached, col_rank: 'genus', taxonworks_id: other_project_name.id)
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'rejects it as an unknown id for this project' do
        expect { result }.to raise_error(described_class::CreationError, /Unknown TaxonName id/)
      end
    end

    context 'when a row has an unknown rank (e.g. domain)' do
      let(:rows) do
        [
          row(col_name: 'Eukaryota', col_rank: 'domain'),   # unknown to TW — skipped
          row(col_name: 'Animalia',  col_rank: 'kingdom'),
          row(col_name: 'Homo',      col_rank: 'genus')
        ]
      end

      subject(:result) {
        described_class.new(rows:, project_id:, user_id:, col_code: 'zoological').call
      }

      it 'skips the domain row and creates only known ranks' do
        expect { result }.to change(::TaxonName, :count).by(2)
      end
    end
  end

  describe 'non-accepted target' do
    # CoL gives a non-accepted name only its accepted name's classification,
    # nothing of its own, so it isn't created from CoL (the modal blocks it;
    # this is the server's guard).
    def creator(rows)
      described_class.new(rows:, project_id:, user_id:, col_code: 'zoological')
    end

    context 'that would be created' do
      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: 'Homo', col_rank: 'genus'),
          row(col_name: 'erectus', col_rank: 'species',
            col_authorship: 'Dubois, 1893', col_year: '1893',
            col_status: 'synonym')
        ]
      end

      it 'raises CreationError and creates nothing' do
        count = ::TaxonName.count
        expect { creator(rows).call }
          .to raise_error(described_class::CreationError, /synonym/)
        expect(::TaxonName.count).to eq(count)
      end
    end

    context 'that already exists in TaxonWorks' do
      let(:genus) do
        FactoryBot.create(:valid_taxon_name, name: 'Homo',
          rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus')
      end
      let(:species) do
        Protonym.create!(name: 'erectus', parent: genus,
          rank_class: Ranks.lookup(:iczn, :species))
      end

      it 'is used, not rejected' do
        rows = [
          row(col_name: 'Homo', col_rank: 'genus', taxonworks_id: genus.id),
          row(col_name: 'erectus', col_rank: 'species',
            taxonworks_id: species.id, col_status: 'synonym')
        ]
        expect(creator(rows).call[:taxon_name_id]).to eq(species.id)
      end
    end

    context 'provisionally accepted' do
      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: 'Homo', col_rank: 'genus',
            col_status: 'provisionally accepted')
        ]
      end

      it 'is created like an accepted name' do
        expect { creator(rows).call }.to change(::TaxonName, :count).by(2)
      end
    end

    context "'Accepted' is matched case-insensitively" do
      let(:rows) do
        [
          row(col_name: 'Animalia', col_rank: 'kingdom'),
          row(col_name: 'Homo', col_rank: 'genus', col_status: 'Accepted')
        ]
      end

      it 'is created' do
        expect { creator(rows).call }.to change(::TaxonName, :count).by(2)
      end
    end
  end

  # Guards the per-code mapping used to tag non-accepted names: each entry must be a real
  # classification class whose own nomenclatural code matches the map key.
  describe 'NOMENCLATURE_CODE_TO_SYNONYM_CLASSIFICATION' do
    it 'maps all four codes to code-consistent, known classification classes' do
      expect(NOMENCLATURE_CODE_TO_SYNONYM_CLASSIFICATION.keys).to contain_exactly(:iczn, :icn, :icnp, :icvcn)

      NOMENCLATURE_CODE_TO_SYNONYM_CLASSIFICATION.each do |code, type|
        expect(TAXON_NAME_CLASSIFICATION_NAMES).to include(type), "#{type} is not a known classification"
        expect(type.constantize.new.nomenclature_code).to eq(code)
      end
    end
  end

  describe '#resolve_rank_class' do
    # resolve_rank_class returns the String rank_class value from the lookup hashes.
    it 'resolves species as ICN for botanical code' do
      creator = described_class.new(rows: [], project_id:, user_id:, col_code: 'botanical')
      result  = creator.send(:resolve_rank_class, 'species')
      expect(result).to include('Icn')
      expect(result).not_to include('Iczn')
    end

    it 'resolves species as ICZN for zoological code' do
      creator = described_class.new(rows: [], project_id:, user_id:, col_code: 'zoological')
      result  = creator.send(:resolve_rank_class, 'species')
      expect(result).to include('Iczn')
      expect(result).not_to include('::Icn::')
    end

    it 'resolves genus as ICNP for bacterial code' do
      creator = described_class.new(rows: [], project_id:, user_id:, col_code: 'bacterial')
      result  = creator.send(:resolve_rank_class, 'genus')
      expect(result).to include('Icnp')
    end

    it 'returns nil for unknown rank' do
      creator = described_class.new(rows: [], project_id:, user_id:)
      expect(creator.send(:resolve_rank_class, 'domain')).to be_nil
    end

    it 'returns nil for blank rank' do
      creator = described_class.new(rows: [], project_id:, user_id:)
      expect(creator.send(:resolve_rank_class, '')).to be_nil
    end
  end

  describe '#split_authorship' do
    subject(:creator) { described_class.new(rows: [], project_id:, user_id:) }

    it 'splits "Linnaeus, 1758" into author and year' do
      author, year = creator.send(:split_authorship, 'Linnaeus, 1758', nil)
      expect(author).to eq('Linnaeus')
      expect(year).to eq(1758)
    end

    it 'prefers explicit col_year over extracted year' do
      _author, year = creator.send(:split_authorship, 'L., 1753', '1753')
      expect(year).to eq(1753)
    end

    it 'handles parenthetical basionym authorship "(Chatton, 1925) Whittaker & Margulis, 1978"' do
      author, year = creator.send(:split_authorship, '(Chatton, 1925) Whittaker & Margulis, 1978', nil) # Year would not be picked up in the Eukaryota case as presently defined
      expect(author).to eq('Chatton')
      expect(year).to eq(1925)
    end

    it 'returns [nil, nil] for blank authorship' do
      expect(creator.send(:split_authorship, nil, nil)).to eq([nil, nil])
      expect(creator.send(:split_authorship, '', nil)).to  eq([nil, nil])
    end
  end
end
