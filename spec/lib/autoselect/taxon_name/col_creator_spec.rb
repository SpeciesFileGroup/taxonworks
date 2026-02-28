require 'rails_helper'

# ColCreator needs a project root TaxonName to seed parent_id for the topmost created name.
# Model specs use project_id: 1 / user_id: 1 via Current; a root is created on demand below.

RSpec.describe Autoselect::TaxonName::ColCreator, type: :model do
  before(:each) { find_or_create_root_taxon_name }

  # Minimal row helper — creates a row hash as the modal would send it.
  def row(col_name:, col_rank:, col_id: nil, taxonworks_id: nil, col_authorship: nil, col_year: nil)
    {
      col_name:,
      col_rank:,
      col_id:,
      taxonworks_id:,
      col_authorship:,
      col_year:
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
              col_id: 'HomoSapiensColId')
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

      it 'creates a URI identifier for the target row' do
        result
        identifier = ::Identifier.where(identifier: "#{described_class::COL_BASE_URI}HomoSapiensColId").first
        expect(identifier).not_to be_nil
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
              col_id: 'QuercusRoburColId')
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

      it 'creates a URI identifier for the target row' do
        result
        identifier = ::Identifier.where(identifier: "#{described_class::COL_BASE_URI}QuercusRoburColId").first
        expect(identifier).not_to be_nil
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
      author, year = creator.send(:split_authorship, '(Chatton, 1925) Whittaker & Margulis, 1978', '1978')
      expect(author).to eq('(Chatton) Whittaker & Margulis')
      expect(year).to eq(1978)
    end

    it 'returns [nil, nil] for blank authorship' do
      expect(creator.send(:split_authorship, nil, nil)).to eq([nil, nil])
      expect(creator.send(:split_authorship, '', nil)).to  eq([nil, nil])
    end
  end
end
