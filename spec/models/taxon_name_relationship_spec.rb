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
        taxon_name_relationship.type = TaxonNameRelationship::Chrysonym::Genus
        taxon_name_relationship.valid?
        expect(taxon_name_relationship.errors.include?(:type)).to be_false
      end
    end
  end

  context "relations" do
    before do
      t1 = TaxonName.new
      t2 = TaxonName.new
      taxon_name_relationship.subject = t1
      taxon_name_relationship.object = t2
    end

    context "belongs_to" do
      specify "subject (TaxonName)" do
        expect(taxon_name_relationship).to respond_to (:subject)
        expect(taxon_name_relationship.subject.class).to eq(TaxonName)
      end

      specify "object (TaxonName)" do
        expect(taxon_name_relationship).to respond_to (:object)
        expect(taxon_name_relationship.object.class).to eq(TaxonName)
      end
    end
  end

  context "class methods" do
    specify "valid?" do
      expect(subject).to respond_to (:valid?)
    end
  end

  context "instance methods" do
    specify "aliases" do
      expect(taxon_name_relationship).to respond_to (:aliases)
      expect(taxon_name_relationship.aliases).to eq([])
    end

    specify "subject_properties" do
      expect(taxon_name_relationship).to respond_to (:subject_properties)
      expect(taxon_name_relationship.aliases).to eq([])
    end

    specify "object_properties" do
      expect(taxon_name_relationship).to respond_to (:object_properties)
      expect(taxon_name_relationship.aliases).to eq([])
    end




  end

end
