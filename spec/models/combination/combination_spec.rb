require 'rails_helper'
describe Combination, type: :model, group: :nomenclature do

  context 'protonym becomes combination' do

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
    let(:p1) { Protonym.create(name: 'ba', parent: species.parent, rank_class: species.rank_class, original_species: p, original_genus: genus)  }

    let(:invalidating_relationship) { TaxonNameRelationship::Iczn::Invalidating.create!(object_taxon_name: species, subject_taxon_name: p) }

    specify '#becomes' do
      p.becomes!(Combination)
      expect(p.type).to eq('Combination')
    end 

    specify '#becomes_combination - when we fail, then we return self, and we are still a protonym' do
      expect(p.becomes_combination.type).to eq('Protonym')
    end

    specify '#becomes_combination 1' do
      p.becomes_combination
      expect(p.errors[:base]).to include('Required TaxonNameRelationship::Iczn::Invalidating relationship not found on this name.')
    end

    specify 'with necessary elements method succeeds' do
      p.update(original_genus: genus, original_species: p)
      invalidating_relationship
      expect(p.becomes_combination).to be_truthy
    end

    specify 'soft_validation does not fix without flag' do
      p.update(original_genus: genus, original_species: p)
      invalidating_relationship
      p.soft_validate(only_sets: :protonym_to_combination)
      p.fix_soft_validations
      expect(p.type).to eq('Protonym')
    end

    specify 'soft_validation fixes with when flagged' do
      p.update(original_genus: genus, original_species: p)
      invalidating_relationship
      p.soft_validate(only_sets: :protonym_to_combination, include_flagged: true)
#      p.soft_validate(only_sets: :protonym_to_combination, include_ancestors: true, only_fixable: true, flagged: true)
      p.fix_soft_validations
      expect(p.type).to eq('Combination')
    end

    specify 'soft_validation fixes with the scope = :requested, conversion fails' do
      p.update(original_genus: genus, original_species: p)
      c = Combination.create!(genus: genus, species: species, verbatim_name: 'Aus bum')
      invalidating_relationship
      z = p.becomes_combination
      expect(z.errors.any?).to be_truthy
      expect(z.type).to eq('Protonym')
    end

    context 'testing conversion prerequisites' do
      before { invalidating_relationship }

      specify 'without original_genus method fails' do
        p.becomes_combination
        expect(p.errors[:base]).to include('Protonym does not have original genus assigned.')
      end

      specify 'without similar enough names method fails' do
        p.update(name: 'aum')
        p.becomes_combination
        expect(p.errors[:base]).to include('Related invalid name is not similar enough to protonym to be treated as combination.')
      end

      context 'with original genus set' do
        before {  p.update(original_genus: genus, original_species: p) }
        specify 'with any classification method fails' do
          TaxonNameClassification::Iczn::Unavailable.create!(taxon_name: p)
          p.reload #! why needed
          p.becomes_combination
          expect(p.errors[:base]).to include('Protonym has taxon name classifications, it can not be converted to combination.')
        end

        specify 'with any addition invalidating relationship method fails' do
          p1 
          TaxonNameRelationship::Iczn::Invalidating.create!(object_taxon_name: p, subject_taxon_name: p1)
          p.becomes_combination
          expect(p.errors[:base]).to include('Protonym has additional taxon name relationships, it can not be converted to combination.')
        end
      end
    end

    context 'complicated' do
      let(:genus1) { Protonym.create(name: 'Gus', parent: genus.parent, rank_class: genus.rank_class)  }
      before do 
        invalidating_relationship
        p1
      end

      specify 'returns false when combination matches original combination of protonym' do
        p.update(original_genus: genus, original_species: p)
        p.becomes_combination
        expect(p.errors[:base]).to contain_exactly("Combination failed to save: Combination exists as protonym(s) with matching original combination: Aus (Aus) ba.") 
      end

      specify 'updates original combination when genera differ' do
        p.update(original_genus: genus1, original_species: p)
        expect(p.becomes_combination).to be_truthy
        expect(p1.reload.original_species.id).to eq(species.id) 
      end
    end

    context 'with an valid conversion' do
      before do
        p.update(original_genus: genus, original_species: p)
        invalidating_relationship
      enlet!(:c) { p.becomes_combination }

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
end
