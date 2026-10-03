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

    specify 'returns a bare epithet as is' do
      expect(t.subgenus_epithet('Megodontus')).to eq('Megodontus')
    end

    specify 'nil is nil' do
      expect(t.subgenus_epithet(nil)).to be_nil
    end
  end

  context '.protonym_name' do
    specify 'a species takes its epithet' do
      expect(t.protonym_name('Testus novus', 'species')).to eq('novus')
    end

    specify 'a species with a subgenus takes its epithet' do
      expect(t.protonym_name('Carabus (Megodontus) violaceus', 'species'))
        .to eq('violaceus')
    end

    specify 'an ICN infraspecific name takes its last epithet' do
      expect(t.protonym_name('Olea europaea subsp. cuspidata', 'subspecies'))
        .to eq('cuspidata')
    end

    specify 'a subgenus takes its epithet' do
      expect(t.protonym_name('Carabus (Megodontus)', 'subgenus'))
        .to eq('Megodontus')
    end

    specify 'an already-reduced epithet is unchanged' do
      expect(t.protonym_name('novus', 'species')).to eq('novus')
      expect(t.protonym_name('Megodontus', 'subgenus')).to eq('Megodontus')
    end

    specify 'a uninomial is unchanged' do
      expect(t.protonym_name('Hominidae', 'family')).to eq('Hominidae')
    end

    specify 'nil is nil' do
      expect(t.protonym_name(nil, 'species')).to be_nil
    end
  end

  context '.search_term' do
    specify 'a TaxonWorks species under a subgenus drops it' do
      expect(t.search_term('Aphrophora (Aphrophora) binomoriensis'))
        .to eq('Aphrophora binomoriensis')
    end

    specify 'a subspecies under a subgenus drops it' do
      expect(t.search_term('Carabus (Megodontus) violaceus violaceus'))
        .to eq('Carabus violaceus violaceus')
    end

    specify '[sic] is dropped' do
      expect(t.search_term('Aus bvs [sic]')).to eq('Aus bvs')
    end

    specify 'ICN infraspecific connecting terms are kept' do
      expect(t.search_term('Olea europaea subsp. africana'))
        .to eq('Olea europaea subsp. africana')
    end

    specify 'a name without a subgenus is unchanged' do
      expect(t.search_term('Bombus terrestris')).to eq('Bombus terrestris')
    end

    specify 'nil is nil' do
      expect(t.search_term(nil)).to be_nil
    end
  end

  context '.name_key' do
    specify 'a TaxonWorks #cached under a subgenus drops it' do
      expect(t.name_key('Aphrophora (Aphrophora) binomoriensis'))
        .to eq('Aphrophora binomoriensis')
    end

    specify '[sic] is dropped' do
      expect(t.name_key('Aus bvs [sic]')).to eq('Aus bvs')
    end

    specify 'matches the key of the same name as CoL gives it' do
      expect(t.name_key('Aedes (Stegomyia) aegypti'))
        .to eq(t.col_name_key('Aedes aegypti', 'species'))
    end

    specify 'a subgenus ("Genus (Subgenus)" alone) is keyed by its epithet' do
      expect(t.name_key('Carabus (Megodontus)'))
        .to eq(t.col_name_key('Carabus (Megodontus)', 'subgenus'))
    end

    specify 'nil is nil' do
      expect(t.name_key(nil)).to be_nil
    end
  end

  context '.col_name_key' do
    specify 'a subgenus is keyed by its epithet' do
      expect(t.col_name_key('Carabus (Megodontus)', 'subgenus'))
        .to eq('Megodontus')
    end

    specify 'a species with a subgenus drops it' do
      expect(t.col_name_key('Aedes (Stegomyia) aegypti', 'species'))
        .to eq('Aedes aegypti')
    end

    specify 'a species without a subgenus is unchanged' do
      expect(t.col_name_key('Bombus terrestris', 'species'))
        .to eq('Bombus terrestris')
    end

    specify 'an ICN infraspecific name is unchanged' do
      expect(t.col_name_key('Olea europaea subsp. africana', 'subspecies'))
        .to eq('Olea europaea subsp. africana')
    end

    specify 'nil is nil' do
      expect(t.col_name_key(nil, 'species')).to be_nil
    end
  end

  context '.forms' do
    specify 'a Protonym\'s current form is #cached, published its original ' \
      'combination' do
      species.update_column(:cached_original_combination, 'Typhlocyba vitis')
      expect(t.forms(species)).to eq(
        current: 'Erythroneura (Erythroneura) vitis',
        published: 'Typhlocyba vitis'
      )
    end

    specify 'a Protonym without an original combination has no published ' \
      'form' do
      species.update_column(:cached_original_combination, nil)
      expect(t.forms(species)[:published]).to be_nil
    end

    specify 'a Combination is only a published form' do
      other_genus = Protonym.create!(
        name: 'Otheronoma', rank_class: Ranks.lookup(:iczn, :genus),
        parent: genus.root
      )
      combination = Combination.create!(genus: other_genus, species:)
      expect(t.forms(combination))
        .to eq(current: nil, published: 'Otheronoma vitis')
    end
  end

  context '.taxonworks_name_keys' do
    specify 'a subgenus is keyed by its epithet, not its cached combination' do
      expect(subgenus.cached).to eq('Erythroneura (Erythroneura)')
      expect(t.taxonworks_name_keys(subgenus)[:current]).to eq('Erythroneura')
    end

    specify 'a species under a subgenus drops the subgenus' do
      expect(t.taxonworks_name_keys(species)[:current])
        .to eq('Erythroneura vitis')
    end

    specify 'a subspecies under a subgenus drops the subgenus' do
      expect(t.taxonworks_name_keys(subspecies)[:current])
        .to eq('Erythroneura vitis vitata')
    end

    specify 'a genus is keyed by its cached name' do
      expect(t.taxonworks_name_keys(genus)[:current]).to eq('Erythroneura')
    end

    specify '[sic] is dropped' do
      misspelled = OpenStruct.new(
        cached: 'Zoraida (Zoraida) sinuata [sic]',
        name: 'sinuata',
        rank_class: Ranks.lookup(:iczn, :species)
      )
      expect(t.taxonworks_name_keys(misspelled)[:current])
        .to eq('Zoraida sinuata')
    end

    specify 'the published form drops a subgenus and [sic] too' do
      species.update_column(
        :cached_original_combination, 'Jassus [sic] (Athysanus) vitis'
      )
      expect(t.taxonworks_name_keys(species)[:published]).to eq('Jassus vitis')
    end
  end

  context '.candidates_by_key' do
    def keyed(rows)
      t.candidates_by_key(rows, project_id:)
    end

    # [taxon_name, form] pairs for key
    def found(result, key)
      (result[key] || []).map { |c| [c.taxon_name, c.form] }
    end

    specify 'finds a subgenus from its bare CoL epithet' do
      subgenus
      result = keyed([{ col_name: 'Erythroneura', rank: 'subgenus' }])
      expect(found(result, 'Erythroneura')).to include([subgenus, :current])
    end

    specify 'finds a misspelled genus, whose #cached carries [sic]' do
      genus.update_column(:cached, 'Erythroneura [sic]')
      result = keyed([{ col_name: 'Erythroneura', rank: 'genus' }])
      expect(found(result, 'Erythroneura')).to include([genus, :current])
    end

    specify 'finds a species under a subgenus from a CoL name without it' do
      species
      result = keyed([{ col_name: 'Erythroneura vitis', rank: 'species' }])
      expect(found(result, 'Erythroneura vitis'))
        .to contain_exactly([species, :current])
    end

    specify 'finds a species directly under a genus from a CoL name with a ' \
      'subgenus' do
      novus = Protonym.create!(
        name: 'novus', rank_class: Ranks.lookup(:iczn, :species), parent: genus
      )
      result = keyed(
        [{ col_name: 'Erythroneura (Erythroneura) novus', rank: 'species' }]
      )
      expect(found(result, 'Erythroneura novus'))
        .to contain_exactly([novus, :current])
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
      expect(found(result, 'Erythroneura vitis'))
        .to contain_exactly([species, :current])
    end

    specify 'finds a Protonym by its original combination, as published' do
      species.update_column(
        :cached_original_combination, 'Typhlocyba (Zygina) vitis'
      )
      result = keyed([{ col_name: 'Typhlocyba vitis', rank: 'species' }])
      expect(found(result, 'Typhlocyba vitis'))
        .to contain_exactly([species, :published])
    end

    specify 'lists a name once, as current, when both forms share a key' do
      species.update_column(
        :cached_original_combination, 'Erythroneura vitis'
      )
      result = keyed([{ col_name: 'Erythroneura vitis', rank: 'species' }])
      expect(found(result, 'Erythroneura vitis'))
        .to contain_exactly([species, :current])
    end

    specify 'finds a Combination, as published' do
      other_genus = Protonym.create!(
        name: 'Otheronoma', rank_class: Ranks.lookup(:iczn, :genus),
        parent: genus.root
      )
      combination = Combination.create!(genus: other_genus, species:)
      result = keyed([{ col_name: 'Otheronoma vitis', rank: 'species' }])
      expect(found(result, 'Otheronoma vitis'))
        .to contain_exactly([combination, :published])
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
