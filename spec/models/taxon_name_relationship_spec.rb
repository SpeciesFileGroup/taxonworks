require 'spec_helper'

describe TaxonNameRelationship do

  context 'Taxon Name relationships' do
    context 'requires' do
      before(:all) do
        TaxonName.delete_all
        TaxonNameRelationship.delete_all
        @taxon_name_relationship = FactoryGirl.build(:taxon_name_relationship)
        @taxon_name_relationship.valid?
        @species = FactoryGirl.create(:relationship_species)
        @genus = @species.ancestor_at_rank('genus')
      end

      after(:all) do
        TaxonName.delete_all
        TaxonNameRelationship.delete_all
      end

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
            @taxon_name_relationship.type = TaxonNameRelationship::Combination::Genus
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:typification)).to be_false
          end
        end

        context 'relationships' do
          specify 'has only one synonym relationship' do
            s = FactoryGirl.create(:iczn_species, parent: @genus)
            r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: TaxonNameRelationship::Iczn::Invalidating::Synonym)
            expect(r1.valid?).to be_true
            expect(r1.errors.include?(:subject_taxon_name_id)).to be_false
            r2 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective)
            r2.valid?
            expect(r2.errors.include?(:subject_taxon_name_id)).to be_true
          end
          specify 'has only one type relationship' do
            s = FactoryGirl.create(:iczn_species, parent: @genus)
            r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @genus, type: TaxonNameRelationship::Typification::Genus)
            expect(r1.valid?).to be_true
            expect(r1.errors.include?(:object_taxon_name_id)).to be_false
            r2 = FactoryGirl.build(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @genus, type: TaxonNameRelationship::Typification::Genus::Monotypy)
            r2.valid?
            expect(r2.errors.include?(:object_taxon_name_id)).to be_true
          end

        end
      end
    end
  end


end
