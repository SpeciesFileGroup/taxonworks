require 'rails_helper'
describe Combination, type: :model, group: :nomenclature do

  context 'protonym becoms combination' do

    let(:family) { FactoryBot.create(:relationship_family, name: 'Aidae', year_of_publication: 2000) }
    let(:genus) {FactoryBot.create(:iczn_genus, name: 'Aus', parent: family)}
    let(:subgenus) {FactoryBot.create(:iczn_subgenus, name: 'Aus', parent: genus) }
    let(:species) {FactoryBot.create(:iczn_species, name: 'bus', parent: subgenus) } # our valid name

    let(:combination) {
      Combination.create!(genus: genus, species: species)
    }

    specify 'disable validation with #disable_combination_relationship_check' do
      combination.disable_combination_relationship_check = true
      combination.combination_relationships.destroy
      expect(combination.save!).to be_truthy
    end

    let(:p) { Protonym.create(name: 'bum', parent: species.parent, rank_class: species.rank_class) }
    let(:invalidating_relationship) { TaxonNameRelationship::Iczn::Invalidating.create!(object_taxon_name: species, subject_taxon_name: p) }

    specify '#becomes' do
      p.becomes!(Combination)
      expect(p.type).to eq('Combination')
    end 

    specify '#become_combination 1' do
      expect(p.become_combination).to be_falsey
    end

    specify '#become_combination 2' do
      p.update(original_genus: genus, original_species: p)
      invalidating_relationship
      expect(p.become_combination).to be_truthy
    end

    specify '#become_combination 3' do
      p.update(name: 'aum')
      expect(p.become_combination).to be_falsey
    end

    specify '#become_combination 4' do
      TaxonNameClassification::Iczn::Unavailable.create!(taxon_name: p)
      expect(p.become_combination).to be_falsey
    end

    context 'complicated' do
      let!(:p1) { Protonym.create(name: 'ba', parent: species.parent, rank_class: species.rank_class, original_species: p, original_genus: genus)  }

      specify 'not allowed because of second invalidating relationship' do
        TaxonNameRelationship::Iczn::Invalidating.create!(object_taxon_name: p, subject_taxon_name: p1)
        expect(p.become_combination).to be_falsey
      end

      specify 'original species' do
        p1
        p.update(original_genus: genus, original_species: p)
        invalidating_relationship
        expect(p.become_combination).to be_truthy
        expect(p1.reload.original_species.id).to eq(species.id) # failing
      end
    end

    context 'with an valid conversion' do
      before do
        p.update(original_genus: genus, original_species: p)
        invalidating_relationship
      end

      let!(:c) { p.become_combination }

      specify 'is Combination' do
        expect(c.type).to eq('Combination')
      end

      specify '#name cleared' do
        expect(c.name).to eq(nil)
      end

      specify '#rank_class cleared' do
        expect(c.rank_class).to eq(nil)
      end

      specify 'relationship types are updated' do
        expect(TaxonNameRelationship.all.pluck(:type)).to contain_exactly('TaxonNameRelationship::Combination::Genus', 'TaxonNameRelationship::Combination::Species' )
      end

      specify '#original_relationships' do
        expect(c.combination_relationships.count).to eq(2)
      end

      specify '#genus' do
        expect(c.genus).to eq(genus)
      end

      specify '#species' do
        expect(c.species).to eq(species)
      end

      specify '#verbatim_name' do
        expect(c.verbatim_name).to eq('Aus bum')
      end

      specify '#cached' do
        expect(c.cached).to eq('Aus bum')
      end

      specify '#cached_author_year' do
        expect(c.cached_author_year).to eq('McAtee, 1830') # regenerated on cache from save
      end

      specify '#cached_original_combination_html' do
        expect(c.cached_original_combination_html).to eq(nil)
      end
    end
  end
end
