require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:genus) { Protonym.create!(name: 'Erythroneura', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let!(:subspecies) { Protonym.create!(name: 'vitata', parent: genus, rank_class: Ranks.lookup(:iczn, :subspecies)) }
  let(:species) { FactoryBot.create(:iczn_species, parent: genus) }
end
