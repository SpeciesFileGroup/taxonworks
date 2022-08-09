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
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:root) { Protonym.where(name: 'Root').first  }

  context 'scopes' do

    before(:all) {
      TaxonNameRelationship.delete_all
      TaxonName.delete_all 
      @species = FactoryBot.create(:iczn_species)
      @s = Protonym.where(name: 'vitis').first
      @g = Protonym.where(name: 'Erythroneura', rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus').first
    }

    after(:all) {
      TaxonNameRelationship.delete_all
      TaxonName.delete_all
    }

    context 'validity of Protonyms' do
      let(:s1) {FactoryBot.create(:relationship_species, name: 'bus', parent: @g) }
      let(:s2) {FactoryBot.create(:relationship_species, name: 'cus', parent: @g) }

      context 'before invalidating relationship' do
        specify 'two names are valid' do
          expect(Protonym.that_is_valid).to include(s1, s2)
        end
      end

      context 'after invalidating relationship' do
        let!(:r) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: s1, object_taxon_name: s2) }  

        specify 'one name is invalid' do
          expect(Protonym.that_is_valid).to_not include(s1)
        end
      end
    end

    specify 'named' do
      expect(Protonym.named('vitis').count).to eq(1)
    end

    specify 'with_name_in_array' do
      expect(Protonym.with_name_in_array(['vitis']).count).to eq(1)
      expect(Protonym.with_name_in_array(['vitis', 'Erythroneura' ]).count).to eq(3) # genus 2x
    end

    specify 'with_rank_class' do
      expect(Protonym.with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').count).to eq(1)
    end  

    specify 'with_base_of_rank_class' do
      expect(Protonym.with_base_of_rank_class('NomenclaturalRank::Iczn').count).to eq(11)
      expect(Protonym.with_base_of_rank_class('FamilyGroup').count).to eq(0)
    end

    specify 'with_rank_class_including' do
      expect(Protonym.with_rank_class_including('Iczn').count).to eq(11)
      expect(Protonym.with_rank_class_including('GenusGroup').count).to eq(2)
      expect(Protonym.with_rank_class_including('FamilyGroup').count).to eq(4) # When we rename Higher this will work
    end

    specify 'descendants_of' do
      expect(Protonym.descendants_of(Protonym.named('vitis').first).count).to eq(0)
      expect( Protonym.descendants_of(Protonym.named('Erythroneura').with_rank_class_including('GenusGroup::Genus').first).count).to eq(2)

    end

    specify 'ancestors_of' do
      expect(Protonym.ancestors_of(Protonym.named('vitis').first).count).to eq(11)
      expect(Protonym.ancestors_of(Protonym.named('Cicadellidae').first).count).to eq(5)
      expect(Protonym.ancestors_of(Protonym.named('Cicadellidae').first).named('Arthropoda').count).to eq(1)
    end

    context 'relationships' do
      before(:all) do
        @s.original_genus = @g   # @g 'TaxonNameRelationship::OriginalCombination::OriginalGenus' @s
        @s.save
        @s.reload
      end

      # Has *a* relationship
      specify 'with_taxon_name_relationships_as_subject' do
        expect(@g.all_taxon_name_relationships.count).to eq(1)
        expect(Protonym.named('Erythroneura').with_taxon_name_relationships_as_subject.count).to eq(1)
      end
      specify 'with_taxon_name_relationships_as_object' do
        expect(Protonym.named('vitis').with_taxon_name_relationships_as_object.count).to eq(1)
        expect(Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').with_taxon_name_relationships_as_object.count).to eq(0)
      end
      specify 'with_taxon_name_relationships' do 
        expect(Protonym.with_taxon_name_relationships.count).to eq(2)
        expect(Protonym.named('vitis').with_taxon_name_relationships.count).to eq(1)
        expect(Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').with_taxon_name_relationships.count).to eq(1)
        expect(Protonym.named('Erythroneurini').with_taxon_name_relationships.count).to eq(0)
      end

      # Specific relationship exists
      specify 'as_subject_with_taxon_name_relationship' do
        expect(Protonym.as_subject_with_taxon_name_relationship('TaxonNameRelationship::OriginalCombination::OriginalGenus').count).to eq(1)
        expect(Protonym.as_subject_with_taxon_name_relationship('blorf').count).to eq(0)
      end
      specify 'as_subject_with_taxon_name_relationship_base' do
        expect(Protonym.as_subject_with_taxon_name_relationship_base('TaxonNameRelationship::OriginalCombination').count).to eq(1)
        expect(Protonym.as_subject_with_taxon_name_relationship_base('blorf').count).to eq(0)
      end
      specify 'as_subject_with_taxon_name_relationship_containing' do
        expect(Protonym.as_subject_with_taxon_name_relationship_containing('OriginalCombination').count).to eq(1)
        expect(Protonym.as_subject_with_taxon_name_relationship_containing('blorf').count).to eq(0)
      end
      specify 'as_object_with_taxon_name_relationship' do
        expect(Protonym.as_object_with_taxon_name_relationship('TaxonNameRelationship::OriginalCombination::OriginalGenus').count).to eq(1)
        expect(Protonym.as_object_with_taxon_name_relationship('blorf').count).to eq(0)
      end
      specify 'as_object_with_taxon_name_relationship_base' do
        expect(Protonym.as_object_with_taxon_name_relationship_base('TaxonNameRelationship::OriginalCombination').count).to eq(1)
        expect(Protonym.as_object_with_taxon_name_relationship_base('blorf').count).to eq(0)
      end
      specify 'as_object_with_taxon_name_relationship_containing' do
        expect(Protonym.as_object_with_taxon_name_relationship_containing('OriginalCombination').count).to eq(1)
        expect(Protonym.as_object_with_taxon_name_relationship_containing('blorf').count).to eq(0)
      end
      specify 'with_taxon_name_relationship' do
        expect(Protonym.with_taxon_name_relationship('TaxonNameRelationship::OriginalCombination::OriginalGenus').count).to eq(2)
      end

      # Any relationship doesn't exists
      specify 'without_subject_taxon_name_relationships' do
        expect(Protonym.named('vitis').without_subject_taxon_name_relationships.count).to eq(1)
        expect( Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').without_subject_taxon_name_relationships.count).to eq(0)
      end
      specify 'without_object_taxon_name_relationships' do
        expect(Protonym.named('vitis').without_object_taxon_name_relationships.count).to eq(0)
        expect( Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').without_object_taxon_name_relationships.count).to eq(1)
      end
      specify 'without_taxon_name_relationships' do 
        expect(Protonym.without_taxon_name_relationships.count).to eq(Protonym.all.size - 2)
        expect(Protonym.without_taxon_name_relationships.named('vitis').count).to eq(0)
        expect(Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').without_taxon_name_relationships.count).to eq(0)
        expect(Protonym.named('Erythroneurini').without_taxon_name_relationships.count).to eq(1)
      end

      specify 'as_subject_without_taxon_name_relationship_base' do
        expect(Protonym.as_subject_without_taxon_name_relationship_base('TaxonNameRelationship').count).to eq(Protonym.all.size - 1)
      end
    end

    context 'classifications' do
      before(:all) do
        FactoryBot.create(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Available', taxon_name: @s)
        FactoryBot.create(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Available::Valid', taxon_name: @g )
      end

      after(:all) do
        TaxonNameClassification.delete_all
      end

      specify 'with_taxon_name_classifications' do
        expect(Protonym.with_taxon_name_classifications.count).to eq(2)
      end
      specify 'without_taxon_name_classifications' do
        expect(Protonym.without_taxon_name_classifications.count).to eq(Protonym.all.size - 2)
      end

      specify 'without_taxon_name_classification' do
        expect(Protonym.without_taxon_name_classification('TaxonNameClassification::Iczn::Available').count).to eq(Protonym.count - 1)
        expect(Protonym.without_taxon_name_classification('TaxonNameClassification::Iczn::Available::Valid').count).to eq(Protonym.count - 1)
      end

      specify 'with_taxon_name_classification_base' do
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClassification::Iczn').count).to eq(2)
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClassification::Iczn::Available').count).to eq(2)
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClassification::Iczn::Available::Valid').count).to eq(1)
      end
      specify 'with_taxon_name_classification_containing' do
        expect(Protonym.with_taxon_name_classification_containing('Iczn').count).to eq(2)
        expect(Protonym.with_taxon_name_classification_containing('Valid').count).to eq(1)
      end
    end

    context 'original combinations' do
      context '#original_combination_class_relationships' do
        let(:t) { Protonym.new } 

        specify 'for iczn Genus' do
          t.rank_class = NomenclaturalRank::Iczn::GenusGroup::Genus
          expect(t.original_combination_class_relationships.collect{|a| a.inverse_assignment_method}.sort).to eq( [:original_genus, :original_subgenus] )
        end

        specify 'for iczn Subgenus' do
          t.rank_class = NomenclaturalRank::Iczn::GenusGroup::Subgenus
          expect(t.original_combination_class_relationships.collect{|a| a.inverse_assignment_method}.sort).to eq( [:original_genus, :original_subgenus] )
        end

        specify 'for iczn species' do
          t.rank_class = NomenclaturalRank::Iczn::SpeciesGroup::Species 
          expect(t.original_combination_class_relationships.collect{|a| a.inverse_assignment_method}.sort).to eq( [:original_form, :original_genus, :original_species, :original_subgenus, :original_subspecies, :original_variety] )
        end

        specify 'for iczn subspecies' do
          t.rank_class = NomenclaturalRank::Iczn::SpeciesGroup::Subspecies 
          expect(t.original_combination_class_relationships.collect{|a| a.inverse_assignment_method}.sort).to eq( [:original_form, :original_genus, :original_species, :original_subgenus, :original_subspecies, :original_variety] )
        end
      end
    end

    context 'combinations' do
      let(:genus) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Aus', parent: root) }
      let(:alternate_genus) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Bus', parent: root) }
      let(:species) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus', parent: genus) }

      context 'relationships are created when Combinations are created' do
        before(:each) { Combination.create!(genus: alternate_genus, species: species) }
        specify '#combination_relationships' do
          expect(species.combination_relationships.count).to eq(1)
          expect(alternate_genus.combination_relationships.count).to eq(1)
        end

        specify '#combinations' do
          expect(species.combination_relationships.count).to eq(1)
          expect(alternate_genus.combination_relationships.count).to eq(1)
        end
      end
    end
  end
end
