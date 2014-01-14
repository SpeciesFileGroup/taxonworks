require 'spec_helper'

describe TaxonNameClassification do

  let(:taxon_name_classification) { FactoryGirl.build(:taxon_name_classification) }

  context "validation" do

    # Trigger the callbacks
    before do 
      taxon_name_classification.save
    end

    context "requires" do
      specify "taxon_name" do
        expect(taxon_name_classification.errors.include?(:taxon_name)).to be_true
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
        taxon_name_classification.type = TaxonNameClassification::Iczn::Unavailable::NomenNudum
        taxon_name_classification.valid?
        expect(taxon_name_classification.errors.include?(:type)).to be_false
      end
    end
  end

  context "soft_validation" do
    before(:each) do
      @species = FactoryGirl.create(:iczn_species)
      @taxon_name_classification = FactoryGirl.build(:taxon_name_classification, taxon_name: @species) 
    end
   specify "applicable type and year" do
     @taxon_name_classification.type = TaxonNameClassification::Iczn::Unavailable::NomenNudum
     expect(@taxon_name_classification.soft_validate).to be_true
     expect(@taxon_name_classification.soft_validations.messages_on(:type).count).to eq(0)
   end
    specify "unapplicable type" do
      @taxon_name_classification.type = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotFromGenusName'
      expect(@taxon_name_classification.valid?).to be_true
      expect(@taxon_name_classification.soft_validate).to be_true
      expect(@taxon_name_classification.soft_validations.messages_on(:type).count).to be > 0
    end
    specify "unapplicable year" do
      @taxon_name_classification.type = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicPublicationNotInPdfFormat'
      expect(@taxon_name_classification.valid?).to be_true
      expect(@taxon_name_classification.soft_validate).to be_true
      expect(@taxon_name_classification.soft_validations.messages_on(:type).count).to be > 0
    end
  end
end
 

