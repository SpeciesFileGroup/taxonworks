require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  before(:all) do
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
    TaxonNameHierarchy.delete_all
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    Citation.delete_all
    ProjectSource.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:protonym) { Protonym.new }
  let(:root) { Protonym.where(name: 'Root').first  }

  context 'methods' do
    specify 'is_fassil' do
      g = FactoryBot.create(:relationship_genus)
      expect(g.is_fossil?).to be_falsey
      FactoryBot.create(:taxon_name_classification, taxon_name: g, type: 'TaxonNameClassification::Iczn::Fossil')
      g.reload
      expect(g.is_fossil?).to be_truthy
    end

    specify 'family_group_base' do
      expect(Protonym.family_group_base('Cicadellidae')).to eq('Cicadell')
      expect(Protonym.family_group_base('Cicadellae')).to eq('Cicadellae')
    end

    specify 'family_group_name_at_rank' do
      expect(Protonym.family_group_name_at_rank('Cicadellidae', 'tribe')).to eq('Cicadellini')
      expect(Protonym.family_group_name_at_rank('Cicadellae', 'tribe')).to eq('Cicadellae')
    end

    specify 'all_generic_placements' do
      family = FactoryBot.create(:relationship_family)
      genus = FactoryBot.create(:relationship_genus, name: 'Aus', parent: family)
      genus1 = FactoryBot.create(:relationship_genus, name: 'Bus', parent: family)
      genus2 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: family)
      genus3 = FactoryBot.create(:relationship_genus, name: 'Dus', parent: family)
      species = FactoryBot.create(:iczn_species, parent: genus)
      species.reload
      expect(species.all_generic_placements).to eq(['Aus'])
      species.original_genus = genus1
      species.reload
      expect(species.all_generic_placements.sort).to eq(['Aus', 'Bus'])
      combination = Combination.new(genus: genus2, species: species)
      expect(combination.save).to be_truthy
      species.reload
      expect(species.all_generic_placements.sort).to eq(['Aus', 'Bus', 'Cus'])
      combination1 = Combination.new(genus: genus3, species: species)
      expect(combination1.save).to be_truthy
      species.reload
      expect(species.all_generic_placements.sort).to eq(['Aus', 'Bus', 'Cus', 'Dus'])
    end

    context 'predicted_child_rank' do
      before(:all) do
        @order = FactoryBot.build(:iczn_order, name: 'Hemiptera')
        @family = FactoryBot.build(:iczn_family, name: 'Cicadellidae', parent: @order)
        @genus = FactoryBot.build(:iczn_genus, name: 'Cicadella', parent: @family)
        @species = FactoryBot.build(:iczn_species, name: 'viridis', parent: @genus)
      end

      specify 'predict family' do
        expect(@order.predicted_child_rank('Delphacidae')).to eq(NomenclaturalRank::Iczn::FamilyGroup::Family)
      end

      specify 'predict tribe' do
        expect(@family.predicted_child_rank('Delphacini')).to eq(NomenclaturalRank::Iczn::FamilyGroup::Tribe)
      end

      specify 'predict genus' do
        expect(@family.predicted_child_rank('Aus')).to eq(NomenclaturalRank::Iczn::GenusGroup::Genus)
      end

      specify 'predict subgenus' do
        expect(@genus.predicted_child_rank('Aus')).to eq(NomenclaturalRank::Iczn::GenusGroup::Subgenus)
      end

      specify 'predict species' do
        expect(@genus.predicted_child_rank('aus')).to eq(NomenclaturalRank::Iczn::SpeciesGroup::Species)
      end

      specify 'predict subspecies' do
        expect(@species.predicted_child_rank('aus')).to eq(NomenclaturalRank::Iczn::SpeciesGroup::Subspecies)
      end
    end

    context 'coordinated names' do
      before(:all) do
        @family = FactoryBot.create(:iczn_family, name: 'Cicadellidae')
        @subfamily = FactoryBot.create(:iczn_subfamily, name: 'Cicadellinae', parent: @family)
        @tribe = FactoryBot.create(:iczn_tribe, name: 'Cicadellini', parent: @subfamily)
        @tribe1 = FactoryBot.create(:iczn_tribe, name: 'Proconiini', parent: @subfamily)
        @genus = FactoryBot.create(:iczn_genus, name: 'Aus', parent: @tribe)
        @genus1 = FactoryBot.create(:iczn_genus, name: 'Bus', parent: @tribe)
        @subgenus = FactoryBot.create(:iczn_subgenus, name: 'Aus', parent: @genus)
        @species = FactoryBot.create(:iczn_species, name: 'aus', parent: @subgenus)
        @subspecies = FactoryBot.create(:iczn_subspecies, name: 'aus', parent: @species)
        @subspecies1 = FactoryBot.create(:iczn_subspecies, name: 'bus', parent: @species)
        @family.reload
        @subfamily.reload
        @tribe.reload
        @tribe1.reload
        @genus.reload
        @genus1.reload
        @subgenus.reload
        @species.reload
        @subspecies.reload
        @subspecies1.reload
      end

      specify 'list_of_coordinated_names' do
        expect(@family.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@subfamily, @tribe])
        expect(@subfamily.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@family, @tribe])
        expect(@tribe.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@family, @subfamily])
        expect(@tribe1.list_of_coordinated_names.sort_by{|i| i.id}.empty?).to be_truthy
        expect(@genus.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@subgenus])
        expect(@subgenus.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@genus])
        expect(@genus1.list_of_coordinated_names.sort_by{|i| i.id}.empty?).to be_truthy
        expect(@species.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@subspecies])
        expect(@subspecies.list_of_coordinated_names.sort_by{|i| i.id}).to eq([@species])
        expect(@subspecies1.list_of_coordinated_names.sort_by{|i| i.id}.empty?).to be_truthy
      end

      specify 'lowest_rank_coordinated_taxon' do
        expect(@family.lowest_rank_coordinated_taxon).to eq(@tribe)
        expect(@tribe.lowest_rank_coordinated_taxon).to eq(@tribe)
        expect(@genus.lowest_rank_coordinated_taxon).to eq(@subgenus)
        expect(@subgenus.lowest_rank_coordinated_taxon).to eq(@subgenus)
        expect(@species.lowest_rank_coordinated_taxon).to eq(@subspecies)
        expect(@subspecies.lowest_rank_coordinated_taxon).to eq(@subspecies)
      end

      specify 'ancestors_and_descendants' do
        a = @genus.ancestors_and_descendants.sort_by{|i| i.id}
        a.delete(TaxonName.where(parent_id: nil, project_id: @species.project_id).first)
        expect(a).to eq([@family.ancestor_at_rank('Kingdom'), @family.ancestor_at_rank('Phylum'), @family.ancestor_at_rank('Class'), @family.ancestor_at_rank('Order'), @family, @subfamily, @tribe, @subgenus, @species, @subspecies, @subspecies1])
      end
    end

    context 'get_primary_type' do
      specify 'primary' do
        type = FactoryBot.create(:valid_type_material)
        expect(type.protonym.get_primary_type).to eq([type])
      end

      specify 'syntypes' do
        type1 = FactoryBot.create(:syntype_type_material)
        p = type1.protonym
        type2 = FactoryBot.create(:syntype_type_material, protonym: p)
        expect(p).to eq(type2.protonym)
        p.reload
        expect(p.get_primary_type.sort_by{|i| i.id}).to eq([type1, type2])
      end
    end

    specify 'has_same_primary_types' do
      species1 = FactoryBot.create(:relationship_species)
      species2 = FactoryBot.create(:relationship_species, parent: species1.ancestor_at_rank('genus'))
      species1.reload
      expect(species1.has_same_primary_type(species2)).to be_truthy
      type1 = FactoryBot.create(:valid_type_material, protonym: species1)
      species1.reload
      expect(species1.has_same_primary_type(species2)).to be_falsey
      type2 = FactoryBot.create(:valid_type_material, protonym: species2)
      species1.reload
      expect(species1.has_same_primary_type(species2)).to be_falsey
      type2.collection_object_id = type1.collection_object_id
      type2.save
      species1.reload
      expect(species1.has_same_primary_type(species2)).to be_truthy
    end

    specify 'iczn_set_as_incorrect_original_spelling_of_relationship' do
      species1 = FactoryBot.create(:relationship_species, name: 'aus')
      species2 = FactoryBot.create(:relationship_species, name: 'bus', parent: species1.ancestor_at_rank('genus'))
      relationship = TaxonNameRelationship.create(subject_taxon_name: species2, object_taxon_name: species1, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling')
      species1.reload
      species2.reload
      expect(species1.iczn_set_as_incorrect_original_spelling_of_relationship).to be_falsey
      expect(species2.iczn_set_as_incorrect_original_spelling_of_relationship).to eq(relationship)
    end

    specify 'iczn_uncertain_placement_relationship' do
      family = FactoryBot.create(:relationship_family)
      species = FactoryBot.create(:relationship_species, parent: family)
      expect(species.iczn_uncertain_placement_relationship).to be_falsey
      relationship = TaxonNameRelationship.create(subject_taxon_name: species, object_taxon_name: family, type: 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement')
      species.reload
      expect(species.iczn_uncertain_placement_relationship).to eq(relationship)
    end

    specify 'original_combination_class_relationships' do
      genus = FactoryBot.create(:relationship_genus)
      subgenus = FactoryBot.create(:iczn_subgenus, parent: genus)
      species = FactoryBot.create(:relationship_species, parent: subgenus)
      subspecies = FactoryBot.create(:iczn_subspecies, parent: species)

      expect(subspecies.original_combination_class_relationships.collect{|i| i.to_s}.sort).to eq(['TaxonNameRelationship::OriginalCombination::OriginalForm', 'TaxonNameRelationship::OriginalCombination::OriginalGenus', 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', 'TaxonNameRelationship::OriginalCombination::OriginalVariety'])

      r1 = TaxonNameRelationship.create(subject_taxon_name: genus, object_taxon_name: subspecies, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      r2 = TaxonNameRelationship.create(subject_taxon_name: subgenus, object_taxon_name: subspecies, type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      subspecies.reload
      stubs = subspecies.original_combination_relationships_and_stubs
      expect(stubs.count).to eq(6)
      expect(stubs[0]).to eq(r1)
      expect(stubs[1]).to eq(r2)
      expect(stubs[2].subject_taxon_name_id).to be_falsey
      expect(stubs[2].object_taxon_name_id).to eq(subspecies.id)
      expect(stubs[2].type).to eq('TaxonNameRelationship::OriginalCombination::OriginalSpecies')
    end
  end

end
