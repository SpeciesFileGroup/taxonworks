require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:family) { Protonym.create!(name: 'Treeidae', parent: root, rank_class: Ranks.lookup(:iczn, :family)) }
  let!(:genus) { Protonym.create!(name: 'Treeini', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }

  specify 'can change rank from genus to tribe' do
    expect(genus.update(rank_class: Ranks.lookup(:iczn, :tribe))).to be_truthy
  end
end
