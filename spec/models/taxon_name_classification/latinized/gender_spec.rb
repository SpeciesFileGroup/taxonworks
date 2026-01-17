require 'rails_helper'

describe TaxonNameClassification::Latinized::Gender, type: :model, group: [:nomenclature] do

  specify 'sets cached_genus' do
    g = Protonym.create(name: 'Llmala', rank_class: Ranks.lookup(:iczn, :genus), parent: FactoryBot.create(:root_taxon_name))
    TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: g)
    expect(g.cached_gender).to eq('feminine')
  end

  specify 'is not valid for non-genus ranks' do
    root = FactoryBot.create(:root_taxon_name)
    family = Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: root)
    classification = TaxonNameClassification::Latinized::Gender::Masculine.new(taxon_name: family)
    expect(classification.valid?).to be false
    expect(classification.errors[:taxon_name]).to include('Gender is only applicable to genus names')
  end

end
