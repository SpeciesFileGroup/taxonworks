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

end
