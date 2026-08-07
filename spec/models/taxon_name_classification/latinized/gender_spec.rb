require 'rails_helper'

describe TaxonNameClassification::Latinized::Gender, type: :model, group: [:nomenclature] do

  specify 'sets cached_genus' do
    g = Protonym.create(name: 'Llmala', rank_class: Ranks.lookup(:iczn, :genus), parent: FactoryBot.create(:root_taxon_name))
    TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: g)
    expect(g.cached_gender).to eq('feminine')
  end

  specify 'clears cached_gender on the taxon name when destroyed' do
    g = Protonym.create!(name: 'Llmala', rank_class: Ranks.lookup(:iczn, :genus), parent: FactoryBot.create(:root_taxon_name))
    c = TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: g)
    expect(g.reload.cached_gender).to eq('feminine')
    c.destroy
    expect(g.reload.cached_gender).to be_nil
  end

  specify 'updates cached name of descendant species when gender is set and removed' do
    genus = FactoryBot.create(:iczn_genus)
    species = Protonym.create!(
      name: 'alta',
      masculine_name: 'altus',
      parent: genus,
      rank_class: Ranks.lookup(:iczn, :species)
    )

    c = TaxonNameClassification::Latinized::Gender::Masculine.create!(taxon_name: genus)
    expect(species.reload.cached).to include('altus')

    c.destroy
    expect(species.reload.cached).to include('alta')
    expect(species.reload.cached).not_to include('altus')
  end

  specify 'is not valid for non-genus ranks' do
    root = FactoryBot.create(:root_taxon_name)
    family = Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: root)
    classification = TaxonNameClassification::Latinized::Gender::Masculine.new(taxon_name: family)
    expect(classification.valid?).to be false
    expect(classification.errors[:taxon_name]).to include('Gender is only applicable to genus names')
  end

  context 'subsequent combinations' do
    let(:genus) { FactoryBot.create(:iczn_genus) }

    let(:species) {
      Protonym.create!(
        name: 'alta',
        masculine_name: 'altus',
        feminine_name: 'alta',
        parent: genus,
        rank_class: Ranks.lookup(:iczn, :species)
      )
    }

    let(:combination) { Combination.create!(genus: genus, species: species) }

    specify 'freezes verbatim_name to the pre-change spelling when the gender change alters the ending' do
      masculine = TaxonNameClassification::Latinized::Gender::Masculine.create!(taxon_name: genus)
      expect(combination.reload.cached).to include('altus')

      masculine.destroy
      TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: genus)
      combination.reload

      expect(combination.verbatim_name).to include('altus')
      expect(combination.cached).to include('altus') # left as the pre-change (now pinned) spelling
    end

    specify 'does not set verbatim_name when the gender change does not alter the ending' do
      invariant_species = Protonym.create!(
        name: 'nigra',
        masculine_name: 'nigra',
        feminine_name: 'nigra',
        parent: genus,
        rank_class: Ranks.lookup(:iczn, :species)
      )
      invariant_combination = Combination.create!(genus: genus, species: invariant_species)

      masculine = TaxonNameClassification::Latinized::Gender::Masculine.create!(taxon_name: genus)
      expect(invariant_combination.reload.verbatim_name).to be_nil

      masculine.destroy
      TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: genus)
      invariant_combination.reload

      expect(invariant_combination.verbatim_name).to be_nil
      expect(invariant_combination.cached).to include('nigra')
    end

    specify 'leaves an already-explicit verbatim_name untouched' do
      explicit_combination = Combination.create!(genus: genus, species: species, verbatim_name: 'Verbatimus explicitus')

      TaxonNameClassification::Latinized::Gender::Masculine.create!(taxon_name: genus)
      explicit_combination.reload

      expect(explicit_combination.verbatim_name).to eq('Verbatimus explicitus')
      expect(explicit_combination.cached).to eq('Verbatimus explicitus')
    end
  end

end
