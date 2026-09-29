require 'rails_helper'

describe Vendor::Colrapi::NameTranslation, type: :model do

  let(:t) { Vendor::Colrapi::NameTranslation }

  # Real lineage: Erythroneura > Erythroneura (Erythroneura) > vitis > vitata
  let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
  let(:species) { subspecies.parent }
  let(:subgenus) { species.parent }
  let(:genus) { subgenus.parent }

  context '.subgenus_epithet' do
    specify 'extracts the epithet from CoL\'s "Genus (Subgenus)"' do
      expect(t.subgenus_epithet('Carabus (Megodontus)')).to eq('Megodontus')
    end
  end

  context '.col_key' do
    specify 'a subgenus is keyed by its epithet' do
      expect(t.col_key('Carabus (Megodontus)', 'subgenus')).to eq('Megodontus')
    end

    specify 'a species with a subgenus drops it' do
      expect(t.col_key('Aedes (Stegomyia) aegypti', 'species'))
        .to eq('Aedes aegypti')
    end

    specify 'a species without a subgenus is unchanged' do
      expect(t.col_key('Bombus terrestris', 'species'))
        .to eq('Bombus terrestris')
    end

    specify 'an ICN infraspecific name is unchanged' do
      expect(t.col_key('Olea europaea subsp. africana', 'subspecies'))
        .to eq('Olea europaea subsp. africana')
    end

    specify 'nil is nil' do
      expect(t.col_key(nil, 'species')).to be_nil
    end
  end

  context '.taxon_name_key' do
    specify 'a subgenus is keyed by its name, not its cached combination' do
      expect(subgenus.cached).to eq('Erythroneura (Erythroneura)')
      expect(t.taxon_name_key(subgenus)).to eq('Erythroneura')
    end

    specify 'a species under a subgenus drops the subgenus' do
      expect(t.taxon_name_key(species)).to eq('Erythroneura vitis')
    end

    specify 'a subspecies under a subgenus drops the subgenus' do
      expect(t.taxon_name_key(subspecies)).to eq('Erythroneura vitis vitata')
    end

    specify 'a genus is keyed by its cached name' do
      expect(t.taxon_name_key(genus)).to eq('Erythroneura')
    end

    specify '[sic] is dropped' do
      misspelled = OpenStruct.new(
        cached: 'Zoraida (Zoraida) sinuata [sic]',
        name: 'sinuata',
        rank_class: Ranks.lookup(:iczn, :species)
      )
      expect(t.taxon_name_key(misspelled)).to eq('Zoraida sinuata')
    end
  end

  context '.candidates_by_key' do
    def keyed(rows)
      t.candidates_by_key(rows, project_id:)
    end

    specify 'finds a subgenus from its bare CoL epithet' do
      subgenus
      result = keyed([{ col_name: 'Erythroneura', rank: 'subgenus' }])
      expect(result['Erythroneura']).to include(subgenus)
    end

    specify 'finds a species under a subgenus from a CoL name without it' do
      species
      result = keyed([{ col_name: 'Erythroneura vitis', rank: 'species' }])
      expect(result['Erythroneura vitis']).to contain_exactly(species)
    end

    specify 'finds a species directly under a genus from a CoL name with a ' \
      'subgenus' do
      novus = Protonym.create!(
        name: 'novus', rank_class: Ranks.lookup(:iczn, :species), parent: genus
      )
      result = keyed(
        [{ col_name: 'Erythroneura (Erythroneura) novus', rank: 'species' }]
      )
      expect(result['Erythroneura novus']).to contain_exactly(novus)
    end

    specify 'does not return the same epithet under a different genus' do
      species
      other_genus = Protonym.create!(
        name: 'Otheronoma', rank_class: Ranks.lookup(:iczn, :genus),
        parent: genus.root
      )
      Protonym.create!(
        name: 'vitis', rank_class: Ranks.lookup(:iczn, :species),
        parent: other_genus
      )
      result = keyed([{ col_name: 'Erythroneura vitis', rank: 'species' }])
      expect(result.keys).to contain_exactly('Erythroneura vitis')
      expect(result['Erythroneura vitis']).to contain_exactly(species)
    end

    specify 'is scoped to the project' do
      species
      result = t.candidates_by_key(
        [{ col_name: 'Erythroneura vitis', rank: 'species' }],
        project_id: FactoryBot.create(:valid_project).id
      )
      expect(result).to be_empty
    end
  end

end
