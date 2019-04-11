require 'rails_helper'
describe Combination, type: :model, group: :nomenclature do


  context 'protonym becoms combination' do

    let(:family) { FactoryBot.create(:relationship_family, name: 'Aidae', year_of_publication: 2000) }
    let(:genus) {FactoryBot.create(:iczn_genus, name: 'Aus', parent: family)}
    let(:subgenus) {FactoryBot.create(:iczn_subgenus, name: 'Aus', parent: genus) }
    let(:species) {FactoryBot.create(:iczn_species, name: 'bus', parent: subgenus) }

    let(:combination) {
      Combination.create!(genus: genus, species: species)
    }

    specify 'disable validation with #disable_combination_relationship_check' do
      combination.disable_combination_relationship_check = true
      combination.combination_relationships.destroy
      expect(combination.save!).to be_truthy
    end

    specify 'combination created' do
      p = Combination.new
      p.genus = genus
      p.species = species
      p.save
      p.reload
      expect(p.type).to eq('Combination')
      expect(p.related_taxon_name_relationships.count).to eq(2)
      expect(p.genus).to eq(genus)
      expect(p.species).to eq(species)
    end

    context 'from a protonym' do
      let(:p) do
        z = Protonym.new(name: species.name, parent: species.parent, rank_class: species.rank_class)
        z.original_genus = genus
        z.original_species = species
        z.save!
        z
      end

      specify 'originals set' do
        expect(p.original_genus).to eq(genus)
      end 

      specify '#becomes 1' do
        p.becomes!(Combination)
        expect(p.type).to eq('Combination')
      end 

      specify '#becomes 2' do
        q = p.becomes!(Combination)
        q.save!
        expect(Combination.find(q.id)).to be_truthy
      end


      context 'must have invalid relationship' do
        specify '#become_combination 1' do
          expect(p.become_combination).to be_falsey
        end

        context 'with invalid relationship' do
          before {
            TaxonNameRelationship::Iczn::Invalidating.create!(object_taxon_name: species, subject_taxon_name: p)
          }

          context 'with original_genus' do
            specify '#become_combination 2' do
              expect(p.become_combination).to be_truthy
            end
          end

          specify '#become_combination 3' do
            expect(p.become_combination).to be_falsey
          end
        end
      end

      specify 'test' do
        expect(p.valid?).to be_truthy

        p.taxon_name_relationships.create(object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Invalidating')
        p.reload

        p.taxon_name_relationships.first.destroy
        p.original_genus_relationship.destroy
        p.original_species_relationship.destroy

        p.parent_id = nil
        p.year_of_publication = nil
        p.verbatim_author = nil
        p.rank_class = nil

        p.cached_html = nil
        p.cached_author_year = nil
        p.cached_original_combination_html = nil
        p.cached_secondary_homonym = nil
        p.cached_primary_homonym = nil
        p.cached_secondary_homonym_alternative_spelling = nil
        p.cached_primary_homonym_alternative_spelling = nil
        p.cached = nil
        p.cached_original_combination = nil

        q = p.becomes!(Combination)

        # q.reload
        # q.type = 'Combination'

        q.genus = genus
        q.species = species
        q.save!
        expect(q.valid?).to be_truthy
        expect(q.genus).to eq(genus)
        expect(q.species).to eq(species)

        #      p.genus = genus
        #      p.species = species
        #      p.save
        #      p.reload
        # expect(q.type).to eq('Combination')

        expect(q.related_taxon_name_relationships.load.size).to eq(2)

        expect(q.genus).to eq(genus)
        expect(q.species).to eq(species)
      end
    end
  end
end
