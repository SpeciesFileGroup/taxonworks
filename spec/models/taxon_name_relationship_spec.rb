require 'spec_helper'

describe TaxonNameRelationship do

  let(:taxon_name_relationship) { TaxonNameRelationship.new }

  context "validation" do 
    context "requires" do
      before do
        taxon_name_relationship.valid?
      end

      specify "subject_taxon_name_id" do
        expect(taxon_name_relationship.errors.include?(:subject_taxon_name_id)).to be_true
      end

      specify "object_taxon_name_id" do
        expect(taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_true
      end

      specify "type" do
        expect(taxon_name_relationship.errors.include?(:type)).to be_true
      end

      specify 'object_taxon_name_id != subject_taxon_name_id' do
        pending
      end

      context "object and subject should share the same nomenclatural code" do
        specify "same code" do
          r = FactoryGirl.build(:type_species_relationship)
          r.valid?
          expect(r.errors.include?(:object_id)).to be_false
        end

        specify "different code" do
         # r = FactoryGirl.build(:type_species_relationship_faulty_object)
          r = FactoryGirl.build(:type_species_relationship, object: FactoryGirl.build(:icn_genus))
          r.valid?
          expect(r.errors.include?(:object_id)).to be_true
        end
      end

      context "type" do
        specify "invalid when not a TaxonNameRelationship" do
          taxon_name_relationship.type = "foo"
          taxon_name_relationship.valid?
          expect(taxon_name_relationship.errors.include?(:type)).to be_true
          taxon_name_relationship.type = Specimen 
          taxon_name_relationship.valid?
          expect(taxon_name_relationship.errors.include?(:type)).to be_true
        end

        specify "valid when a TaxonNameRelationship" do
          taxon_name_relationship.type = TaxonNameRelationship::Chresonym::Genus
          taxon_name_relationship.valid?
          expect(taxon_name_relationship.errors.include?(:typification)).to be_false
        end
      end  
    end
  end

  context "associations" do
    context "belongs_to" do
      specify "subject (TaxonName)" do
        expect(taxon_name_relationship).to respond_to (:subject)
      end

      specify "object (TaxonName)" do
        expect(taxon_name_relationship).to respond_to (:object)
      end
    end
  end

end
