require 'rails_helper'

# Coverage for TaxonName.mrca (most recent common ancestor).
describe TaxonName, type: :model do
  context '.mrca' do
    let!(:genus)     { FactoryBot.create(:iczn_genus) }
    let!(:species_a) do
      FactoryBot.create(:iczn_species, parent: genus, name: 'aaa')
    end
    let!(:species_b) do
      FactoryBot.create(:iczn_species, parent: genus, name: 'bbb')
    end

    specify 'returns nil when the input set is empty' do
      expect(TaxonName.mrca([])).to be_nil
    end

    specify 'returns the single taxon when only one id is given' do
      expect(TaxonName.mrca([species_a.id])).to eq(species_a)
    end

    specify 'returns the genus when two sibling species share it' do
      expect(TaxonName.mrca([species_a.id, species_b.id])).to eq(genus)
    end

    specify 'returns the deeper of two shared ancestors' do
      subgenus = FactoryBot.create(:iczn_subgenus, parent: genus)
      s1 = FactoryBot.create(:iczn_species, parent: subgenus, name: 'ccc')
      s2 = FactoryBot.create(:iczn_species, parent: subgenus, name: 'ddd')
      expect(TaxonName.mrca([s1.id, s2.id])).to eq(subgenus)
    end
  end
end
