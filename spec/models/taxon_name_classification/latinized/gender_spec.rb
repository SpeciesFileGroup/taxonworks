require 'rails_helper'

describe TaxonNameClassification::Latinized::Gender, type: :model, group: [:nomenclature] do

  specify 'sets cached_genus' do
    g = Protonym.create(name: 'Llmala', rank_class: Ranks.lookup(:iczn, :genus), parent: FactoryBot.create(:root_taxon_name))
    TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: g)
    expect(g.cached_gender).to eq('feminine')
  end

end
