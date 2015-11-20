require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:root) { FactoryGirl.create(:root_taxon_name, project_id: 1) }
  after(:all) do
    TaxonName.delete_all 
  end

  context 'added in non alphabetical order' do

    let(:family_a) { Protonym.create(name: 'Aidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family')) } 
    let(:family_b) { Protonym.create(name: 'Bidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family')) } 
    let(:family_c) { Protonym.create(name: 'Cidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family')) } 
    let(:family_d) { Protonym.create(name: 'Didae', parent: root, rank_class: Ranks.lookup(:iczn, 'family')) } 

    before {
      [family_a, family_c, family_b, family_d].each do |n|
        n.save 
      end
    }

    specify 'order is alphabetized' do
      expect(root.children).to contain_exactly(family_a, family_b, family_c, family_d)
    end

    specify 'injecting a name after save' do
      n = Protonym.create(name: 'Baidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family')) 
      expect(root.children(true)).to contain_exactly(family_a, n, family_b, family_c, family_d)
    end

    specify 'updating a name reorders' do
      family_a.name = "Zidae" 
      family_a.save!
      expect(root.children(true)).to contain_exactly(family_b, family_c, family_d, family_a)
    end
 

  end

  context 'no alphabetize' do
    let(:family_c) { Protonym.create(name: 'Cidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family'), no_alphabetize: true) } 
    let(:family_a) { Protonym.create(name: 'Aidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family'), no_alphabetize: true) } 
    let(:family_b) { Protonym.create(name: 'Bidae', parent: root, rank_class: Ranks.lookup(:iczn, 'family'), no_alphabetize: true) } 

    before {
      [family_c, family_a, family_b].each do |n|
        n.save 
      end
    }

    specify 'order is not alphabetized' do
      expect(root.children).to contain_exactly(family_c, family_a, family_b)
    end
  end
end
