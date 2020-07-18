require 'rails_helper'

describe Queries::TaxonName::Tabular, type: :model, group: [:nomenclature] do
  let(:root) { FactoryBot.create(:root_taxon_name)}
  let(:genus) { Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:species1) { Protonym.create(name: 'alpha', rank_class: Ranks.lookup(:iczn, 'species'), parent: genus) }
  let(:species2) { Protonym.create(name: 'betta', rank_class: Ranks.lookup(:iczn, 'species'), parent: genus) }

  specify '#number_of_species' do
    genus = Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
    species1 = Protonym.create(name: 'alpha', rank_class: Ranks.lookup(:iczn, 'species'), parent: genus)
    species2 = Protonym.create(name: 'betta', rank_class: Ranks.lookup(:iczn, 'species'), parent: genus)

    query = Queries::TaxonName::Tabular.new(
    ancestor_id: genus.id.to_s,
    ranks: ['genus', 'species'],
    fieldsets: ['nomenclatural_stats'],
    combinations: 'true',
    rank_data: ['genus', 'species'],
    validity: 'true',
    project_id: genus.project_id.to_s,
    limit: '1000')
    query
  end

end