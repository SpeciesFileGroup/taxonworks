require 'rails_helper'

# End-to-end regression guard for the interaction between the matching step
# (Autoselect::TaxonName::Levels::CatalogueOfLife, via ColAncestryComparator) and the
# creation step (Autoselect::TaxonName::ColCreator) — specifically the row ordering and
# reparenting contract between them. Neither class's own spec file exercises this
# together: catalogue_of_life_spec.rb only checks the computed alignment, col_creator_spec.rb
# only checks ColCreator given already-built rows. A regression in either one's row-order
# assumptions about the other would only show up here.

def col_classification_entry(id:, name:, rank:)
  { 'id' => id, 'name' => name, 'rank' => rank, 'label' => name, 'labelHtml' => name }
end

# Mirrors ColConfirmModal.vue's doCreate(): every 'exact'/'extra' alignment row plus
# every checked 'none' row, kingdom-first, taxonworks_id carried on all but 'none'
# rows, then the target row appended last. (This helper treats every 'none' row as
# checked; the real modal defaults family-group-and-higher rows to unchecked.)
def rows_from_level_result(col_extension, target_col_name:, target_rank:, target_col_status: 'accepted')
  ancestor_rows = col_extension[:alignment].map do |r|
    {
      col_name: r[:col_name],
      col_rank: r[:rank],
      col_id: nil,
      dataset_id: nil,
      taxonworks_id: r[:match] == 'none' ? nil : r[:taxonworks_id],
      col_authorship: nil,
      col_year: nil,
      col_status: nil
    }
  end

  target_row = {
    col_name: target_col_name,
    col_rank: target_rank,
    col_id: nil,
    dataset_id: nil,
    taxonworks_id: col_extension[:target_taxonworks_id],
    col_authorship: nil,
    col_year: nil,
    col_status: target_col_status
  }

  ancestor_rows + [target_row]
end

RSpec.describe 'CatalogueOfLife matching + ColCreator creation, end to end', type: :model do
  before(:each) { find_or_create_root_taxon_name }

  let(:level) { Autoselect::TaxonName::Levels::CatalogueOfLife.new }

  # TW's real chain has Subfamily but not Tribe; CoL's chain has Tribe but not Subfamily.
  # Both agree on Family and Genus. Adding a new species under Genus should insert Tribe
  # *between* Subfamily and Genus (kingdom-first: Family -> Subfamily -> Tribe -> Genus) —
  # not as a dangling child of Family that bypasses Subfamily entirely.
  context 'when TW has an intermediate rank CoL lacks (subfamily), and CoL has one TW lacks (tribe)' do
    let!(:root) { ::TaxonName.where(project_id:, parent_id: nil).first }
    let!(:family) { Protonym.create!(name: 'Testidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root, project_id:, by: user_id) }
    let!(:subfamily) { Protonym.create!(name: 'Testinae', rank_class: Ranks.lookup(:iczn, 'subfamily'), parent: family, project_id:, by: user_id) }
    let!(:genus) { Protonym.create!(name: 'Testus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: subfamily, project_id:, by: user_id) }

    let(:col_result) do
      {
        'id' => 'TGT1', 'status' => 'accepted',
        'name' => { 'scientificName' => 'novaspecies', 'rank' => 'species', 'authorship' => nil, 'code' => 'zoological' },
        'label' => 'novaspecies', 'labelHtml' => 'novaspecies'
      }
    end

    before do
      allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
      allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
        col_classification_entry(id: 'A1', name: 'Testidae', rank: 'family'),
        col_classification_entry(id: 'A2', name: 'Testini', rank: 'tribe'),
        col_classification_entry(id: 'A3', name: 'Testus', rank: 'genus')
      ])
    end

    it 'places tribe between subfamily and genus, not as a dangling child of family' do
      match_result = level.call(term: 'novaspecies', project_id:, user_id:)
      ext = match_result.first._col_extension
      rows = rows_from_level_result(ext, target_col_name: 'novaspecies', target_rank: 'species')

      Autoselect::TaxonName::ColCreator.new(rows:, project_id:, user_id:, col_code: 'zoological').call

      tribe = ::TaxonName.find_by(name: 'Testini', project_id:)
      expect(tribe.parent_id).to eq(subfamily.id)
      expect(genus.reload.parent_id).to eq(tribe.id)
      expect(family.reload.parent_id).to eq(root.id) # untouched
    end
  end

  # CoL classification entries give species-group ancestors as full names
  # ("Olea europaea"); the created Protonym#name must be just the epithet.
  context 'when a species-group ancestor of the target has to be created' do
    let!(:root) { ::TaxonName.where(project_id:, parent_id: nil).first }

    def col_subspecies(scientific_name, genus, species, subspecies, code)
      {
        'id' => 'TGT1', 'status' => 'accepted',
        'name' => {
          'scientificName' => scientific_name, 'rank' => 'subspecies',
          'genus' => genus, 'specificEpithet' => species,
          'infraspecificEpithet' => subspecies, 'code' => code
        },
        'label' => scientific_name, 'labelHtml' => scientific_name
      }
    end

    def create_from(col_result, ancestors, code)
      allow(::Vendor::Colrapi).to receive(:search)
        .and_return('result' => [col_result])
      allow(::Vendor::Colrapi).to receive(:ancestors).and_return(ancestors)

      ext = level.call(term: 'x', project_id:, user_id:).first._col_extension
      rows = rows_from_level_result(
        ext, target_col_name: ext[:col_name], target_rank: ext[:col_rank]
      )
      result = Autoselect::TaxonName::ColCreator.new(
        rows:, project_id:, user_id:, col_code: code
      ).call
      ::TaxonName.find(result[:taxon_name_id])
    end

    specify 'ICZN species' do
      genus = Protonym.create!(
        name: 'Testus', rank_class: Ranks.lookup(:iczn, 'genus'),
        parent: root, project_id:, by: user_id
      )

      subspecies = create_from(
        col_subspecies(
          'Testus novus novus', 'Testus', 'novus', 'novus', 'zoological'
        ),
        [
          col_classification_entry(id: 'A1', name: 'Testus', rank: 'genus'),
          col_classification_entry(
            id: 'A2', name: 'Testus novus', rank: 'species'
          )
        ],
        'zoological'
      )

      expect(subspecies.name).to eq('novus')
      expect(subspecies.parent.name).to eq('novus')
      expect(subspecies.parent.parent).to eq(genus)
      expect(subspecies.cached).to eq('Testus novus novus')
    end

    specify 'ICZN species and subgenus, CoL species name carrying the ' \
      'subgenus' do
      genus = Protonym.create!(
        name: 'Carabus', rank_class: Ranks.lookup(:iczn, 'genus'),
        parent: root, project_id:, by: user_id
      )

      subspecies = create_from(
        col_subspecies(
          'Carabus violaceus violaceus', 'Carabus', 'violaceus', 'violaceus',
          'zoological'
        ),
        [
          col_classification_entry(id: 'A1', name: 'Carabus', rank: 'genus'),
          col_classification_entry(
            id: 'A2', name: 'Carabus (Megodontus)', rank: 'subgenus'
          ),
          col_classification_entry(
            id: 'A3', name: 'Carabus (Megodontus) violaceus', rank: 'species'
          )
        ],
        'zoological'
      )

      species = subspecies.parent
      subgenus = species.parent
      expect(species.name).to eq('violaceus')
      expect(subgenus.name).to eq('Megodontus')
      expect(subgenus.parent).to eq(genus)
      expect(subspecies.cached).to eq('Carabus (Megodontus) violaceus violaceus')
    end

    specify 'ICN species' do
      genus = Protonym.create!(
        name: 'Olea', rank_class: Ranks.lookup(:icn, 'genus'),
        parent: root, project_id:, by: user_id
      )

      subspecies = create_from(
        col_subspecies(
          'Olea europaea subsp. cuspidata', 'Olea', 'europaea', 'cuspidata',
          'botanical'
        ),
        [
          col_classification_entry(id: 'A1', name: 'Olea', rank: 'genus'),
          col_classification_entry(
            id: 'A2', name: 'Olea europaea', rank: 'species'
          )
        ],
        'botanical'
      )

      expect(subspecies.name).to eq('cuspidata')
      expect(subspecies.parent.name).to eq('europaea')
      expect(subspecies.parent.parent).to eq(genus)
      expect(subspecies.cached).to eq('Olea europaea subsp. cuspidata')
    end
  end
end
