require 'spec_helper'

describe TaxonNameRelationship do

  context 'Taxon Name relationships' do
    before(:all) do
      TaxonName.delete_all
      TaxonNameRelationship.delete_all
      @taxon_name_relationship = FactoryGirl.build(:taxon_name_relationship)
      @taxon_name_relationship.valid?
      @species = FactoryGirl.create(:relationship_species)
      @genus = @species.ancestor_at_rank('genus')
      @family = @species.ancestor_at_rank('family')
      @kingdom = @species.ancestor_at_rank('kingdom')
    end

    after(:all) do
      TaxonName.delete_all
      TaxonNameRelationship.delete_all
    end
    context 'requires' do

      context 'associations' do
        specify 'subject (TaxonName)' do
          expect(@taxon_name_relationship).to respond_to (:subject_taxon_name)
        end
        specify 'object (TaxonName)' do
          expect(@taxon_name_relationship).to respond_to (:object_taxon_name)
        end
        specify 'type' do
          expect(@taxon_name_relationship).to respond_to (:type)
        end
      end

      context 'validate' do
        specify 'subject_taxon_name_id' do
          expect(@taxon_name_relationship.errors.include?(:subject_taxon_name_id)).to be_true
        end
        specify 'object_taxon_name_id' do
          expect(@taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_true
        end
        specify 'type' do
          expect(@taxon_name_relationship.errors.include?(:type)).to be_true
        end

        specify 'object_taxon_name_id != subject_taxon_name_id' do
          @taxon_name_relationship.object_taxon_name = @genus
          @taxon_name_relationship.subject_taxon_name = @genus
          @taxon_name_relationship.valid?
          expect(@taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_true
        end

        context 'object and subject should share the same potentially_validating code' do
          specify 'same code' do
            r = FactoryGirl.build(:type_species_relationship)
            r.valid?
            expect(r.errors.include?(:object_taxon_name_id)).to be_false
          end

          specify 'different code' do
            r = FactoryGirl.build(:type_species_relationship, object_taxon_name: FactoryGirl.build(:icn_genus))
            r.valid?
            expect(r.errors.include?(:object_taxon_name_id)).to be_true
          end

          specify 'valid object rank' do
            r = FactoryGirl.build(:type_species_relationship)
            r.valid?
            expect(r.errors.include?(:object_taxon_name_id)).to be_false
            expect(r.errors.include?(:subject_taxon_name_id)).to be_false
          end

          specify 'protonym should not have a combination relationships' do
            r = FactoryGirl.build(:type_species_relationship)
            r.object_taxon_name = @species
            r.subject_taxon_name = @genus
            r.type = TaxonNameRelationship::Combination::Genus
            expect(r.valid?).to be_false
          end
        end

        context 'type' do
          specify 'invalidly_published when not a TaxonNameRelationship' do
            @taxon_name_relationship.type = "foo"
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:type)).to be_true
            @taxon_name_relationship.type = Specimen
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:type)).to be_true
          end

          specify 'validly_published when a TaxonNameRelationship' do
            @taxon_name_relationship.type = 'TaxonNameRelationship::Combination::Genus'
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:typification)).to be_false
          end
        end

        context 'relationships' do
          specify 'has only one synonym relationship' do
            s = FactoryGirl.create(:iczn_species, parent: @genus)
            r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
            expect(r1.valid?).to be_true
            expect(r1.errors.include?(:subject_taxon_name_id)).to be_false
            r2 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
            r2.valid?
            expect(r2.errors.include?(:subject_taxon_name_id)).to be_true
          end
          specify 'has only one type relationship' do
            s = FactoryGirl.create(:iczn_species, parent: @genus)
            r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @genus, type: 'TaxonNameRelationship::Typification::Genus')
            expect(r1.valid?).to be_true
            expect(r1.errors.include?(:object_taxon_name_id)).to be_false
            r2 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @genus, type: 'TaxonNameRelationship::Typification::Genus::Monotypy')
            r2.valid?
            expect(r2.errors.include?(:object_taxon_name_id)).to be_true
          end
        end
      end
    end

    context 'soft validation' do
      specify 'disjoint relationships' do
        g = FactoryGirl.create(:iczn_genus, parent: @family)
        s = FactoryGirl.create(:iczn_species, parent: g)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Validating::ConservedName')
        r1.soft_validate(:disjoint)
        expect(r1.soft_validations.messages_on(:type).empty?).to be_true
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r1.soft_validate(:disjoint)
        r2.soft_validate(:disjoint)
        #conflicting with r2
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        #conflicting with r1
        expect(r2.soft_validations.messages_on(:type).count).to eq(1)
      end
      specify 'disjoint objects' do
        g = FactoryGirl.create(:iczn_genus, parent: @family)
        s = FactoryGirl.create(:iczn_species, parent: g)
        FactoryGirl.create(:taxon_name_classification, taxon_name: g, type: 'TaxonNameClassification::Iczn::Unavailable')
        r1 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: g, type: 'TaxonNameRelationship::Typification::Genus::OriginalDesignation')
        r1.soft_validate(:disjoint_object)
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        expect(r1.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
      end
      specify 'disjoint subject' do
        g = FactoryGirl.create(:iczn_genus, parent: @family)
        s = FactoryGirl.create(:iczn_species, parent: g)
        FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Unavailable')
        r1 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: g, type: 'TaxonNameRelationship::Typification::Genus::OriginalDesignation')
        r1.soft_validate(:disjoint_subject)
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        expect(r1.soft_validations.messages_on(:subject_taxon_name_id).count).to eq(1)
      end
      specify 'not specific relationships' do
        s1 = FactoryGirl.create(:iczn_species, parent: @genus)
        s2 = FactoryGirl.create(:iczn_species, parent: @genus)
        r1 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating')
        r2 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
        r3 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r1.soft_validate(:relationships)
        r2.soft_validate(:relationships)
        r3.soft_validate(:relationships)
        # reason of being invalid?
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        # primary or secondary homonym?
        expect(r2.soft_validations.messages_on(:type).count).to eq(1)
        # objective or subjective synonym?
        expect(r3.soft_validations.messages_on(:type).count).to eq(1)
      end
      specify 'fix not specific relationships from synonym to objective synonym' do
        g1 = FactoryGirl.create(:iczn_genus, parent: @family)
        g2 = FactoryGirl.create(:iczn_genus, parent: @family)
        s1 = FactoryGirl.create(:iczn_species, parent: g1)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g1, type: 'TaxonNameRelationship::Typification::Genus')
        r3 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g2, type: 'TaxonNameRelationship::Typification::Genus')
        r1.soft_validate(:relationships)
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        r1.fix_soft_validations
        r1.soft_validate(:relationships)
        expect(r1.soft_validations.messages_on(:type).empty?).to be_true
      end
      specify 'fix not specific relationships from homonym to primary homonym' do
        s1 = FactoryGirl.create(:iczn_species, parent: @genus)
        s2 = FactoryGirl.create(:iczn_species, parent: @genus)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
        r3 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: s2, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
        r1.soft_validate(:relationships)
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        r1.fix_soft_validations
        r1.soft_validate(:relationships)
        expect(r1.soft_validations.messages_on(:type).empty?).to be_true
      end
      specify 'parent is a synonym' do
        g1 = FactoryGirl.create(:iczn_genus, parent: @family)
        g2 = FactoryGirl.create(:iczn_genus, parent: @family)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: @genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r1.soft_validate(:synonym_associations)
        r2.soft_validate(:synonym_associations)
        expect(r1.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_true
        # parent is a synonym of another taxon
        expect(r2.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
        r2.fix_soft_validations
        r2.soft_validate(:synonym_associations)
        # parent updated to valid name
        expect(r2.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_true
      end
      specify 'type genus should have the same first letter' do
        f1 = FactoryGirl.create(:iczn_family, parent: @kingdom)
        g1 = FactoryGirl.create(:iczn_genus, name: 'Bus', parent: f1)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: f1, type: 'TaxonNameRelationship::Typification::Family')
        r1.soft_validate(:matching_type_genus)
        expect(r1.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
      end



    end
  end


end
