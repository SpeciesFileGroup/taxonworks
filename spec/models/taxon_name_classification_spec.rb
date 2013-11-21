require 'spec_helper'

describe TaxonNameClassification do

  let(:taxon_name_classification) { TaxonNameClassification.new }

  context "validation" do

    # Trigger the callbacks
    before do 
      taxon_name_classification.save
    end

    context "requires" do
      specify "taxon_name" do
        expect(taxon_name_classification.errors.include?(:taxon_name_id)).to be_true
      end

      specify "type" do
        expect(taxon_name_classification.errors.include?(:type)).to be_true
      end
    end

    context "validate type" do
      specify "invalid type" do
        taxon_name_classification.type = 'aaa'
        taxon_name_classification.valid?
        expect(taxon_name_classification.errors.include?(:type)).to be_true
      end
      specify "invalid type" do
        taxon_name_classification.type = TaxonNameClass::Iczn::Unavailable::NomenNudum
        taxon_name_classification.valid?
        expect(taxon_name_classification.errors.include?(:type)).to be_false
      end
    end
  end

  context "soft_validation" do
    before do
      @species = FactoryGirl.create(:iczn_species)
      taxon_name_classification.taxon_name = @species
    end
    specify "applicable type" do
      taxon_name_classification.type = TaxonNameClass::Iczn::Unavailable::NomenNudum
      taxon_name_classification.soft_validate
      expect(taxon_name_classification.soft_validations.messages_on(:type)).to eq([])
    end
    specify "upapplicable type" do
      taxon_name_classification.type = 'TaxonNameClass::Iczn::Unavailable::NomenNudum::NotFromGenusName'
      taxon_name_classification.soft_validate
      expect(taxon_name_classification.soft_validations.messages_on(:type)).to be_true
    end
  end
end
 

