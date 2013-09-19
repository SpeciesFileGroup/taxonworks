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
    end

    context "type" do

      specify "invalid when not a TaxonNameRelationship" do
        taxon_name_relationship.type = "foo"
        taxon_name_relationship.valid?
        expect(taxon_name_relationship.errors.include?(:type)).to be_true
      end

      specify "valid when a TaxonNameRelationship" do
        taxon_name_relationship.type = TaxonNameRelationship::Chresonym::Genus
        taxon_name_relationship.valid?
        expect(taxon_name_relationship.errors.include?(:type)).to be_false
      end

   
    end
  end

  context "relations" do
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
