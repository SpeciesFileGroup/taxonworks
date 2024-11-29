require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:genus) { Protonym.create!(name: 'Erythroneura', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let!(:species1) { Protonym.create!(name: 'vitata', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }
  let!(:species2) { Protonym.create!(name: 'zitata', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }
  let!(:invalid) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
    subject_taxon_name: species1,
    object_taxon_name: species2)
  }

  specify '#synchronize_otus' do
    expect(TaxonName.synchronize_otus).to be_falsey
  end

  specify '#synchronize_otus :all_valid' do
    i = TaxonName.synchronize_otus(taxon_name_id: root.id, mode: :all_valid, user_id: Current.user_id)
    expect(i).to eq(3)
    expect(Otu.all.count).to eq(3)
  end

  specify '#synchronize_otus :all_valid 1' do
    TaxonName.synchronize_otus(taxon_name_id: root.id, mode: :all_valid, user_id: Current.user_id)
    expect(Otu.all.map(&:taxon_name)).not_to include(species1)
  end

  specify '#synchronize_otus :child_valid' do
    TaxonName.synchronize_otus(taxon_name_id: root.id, mode: :child_valid, user_id: Current.user_id)
    expect(Otu.all.count).to eq(1)
  end

  specify '#synchronize_otus :all_invalid' do
    TaxonName.synchronize_otus(taxon_name_id: root.id, mode: :all_invalid, user_id: Current.user_id)
    expect(Otu.all.count).to eq(1)
  end

  specify '#synchronize_otus :child_invalid' do
    TaxonName.synchronize_otus(taxon_name_id: root.id, mode: :child_invalid, user_id: Current.user_id)
    expect(Otu.all.count).to eq(0)
  end

  specify '#synchronize_otus :child_invalid 1' do
    TaxonName.synchronize_otus(taxon_name_id: genus.id, mode: :child_invalid, user_id: Current.user_id)
    expect(Otu.all.count).to eq(1)
  end

  specify '#synchronize_otus :all_without' do
    TaxonName.synchronize_otus(taxon_name_id: root.id, mode: :all_without, user_id: Current.user_id)
    expect(Otu.all.count).to eq(4)
  end

end
