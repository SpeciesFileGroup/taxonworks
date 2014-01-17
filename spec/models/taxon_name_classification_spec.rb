require 'spec_helper'

describe TaxonNameClassification do

  context "validation" do

    context "requires" do
      before (:all) do
        @taxon_name_classification = FactoryGirl.build(:taxon_name_classification)
        @taxon_name_classification.valid?
      end
      specify "taxon_name" do
        expect(@taxon_name_classification.errors.include?(:taxon_name)).to be_true
      end

      specify "type" do
        expect(@taxon_name_classification.errors.include?(:type)).to be_true
      end
    end

    context "validate type" do
      specify "invalid type" do
        c = FactoryGirl.build(:taxon_name_classification, type: 'aaa')
        c.valid?
        expect(c.errors.include?(:type)).to be_true
      end
      specify "invalid type" do
        c = FactoryGirl.build(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
        c.valid?
        expect(c.errors.include?(:type)).to be_false
      end
    end
  end

  context "soft_validation" do
    before(:each) do
      TaxonName.delete_all
      TaxonNameClassification.delete_all
      @species = FactoryGirl.create(:relationship_species)
      @genus = @species.ancestor_at_rank('genus')
      @family = @species.ancestor_at_rank('family')
    end
    after(:all) do
      TaxonName.delete_all
      TaxonNameClassification.delete_all
    end

    specify "applicable type and year" do
     c = FactoryGirl.build(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
     c.soft_validate(:code_complient)
     expect(c.soft_validations.messages_on(:type).empty?).to be_true
   end
    specify "unapplicable type" do
      c = FactoryGirl.build(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotFromGenusName')
      c.soft_validate(:code_complient)
      expect(c.soft_validations.messages_on(:type).count).to eq(1)
    end
    specify "unapplicable year" do
      c = FactoryGirl.build(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicPublicationNotInPdfFormat')
      c.soft_validate(:code_complient)
      expect(c.soft_validations.messages_on(:type).count).to eq(1)
    end
    specify 'disjoint classes' do
      g = FactoryGirl.create(:iczn_genus, parent: @family)
      s = FactoryGirl.create(:iczn_species, parent: g)
      r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Unavailable')
      c2 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames')
      c1.soft_validate(:disjoint)
      c2.soft_validate(:disjoint)
      #conflicting with c2
      expect(c1.soft_validations.messages_on(:type).count).to eq(1)
      #conflicting with c1
      expect(c2.soft_validations.messages_on(:type).count).to eq(1)
    end

  end
end
 

