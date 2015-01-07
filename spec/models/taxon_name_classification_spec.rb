require 'rails_helper'

describe TaxonNameClassification, :type => :model do

  after(:all) {
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    TaxonNameClassification.delete_all
  }

  specify 'that .class_name(s) do not overlap' do
    existing_names = []
    TaxonNameClassification.descendants.each do |klass|
      name = klass.class_name
      expect(existing_names.include?(name)).to be(false), "#{name} from #{klass.name} is duplicated!"
      existing_names.push name
    end
  end

  context "validation" do
    context "requires" do
      before (:all) do
        @taxon_name_classification = FactoryGirl.build(:taxon_name_classification)
        @taxon_name_classification.valid?
      end
      specify "taxon_name" do
        expect(@taxon_name_classification.errors.include?(:taxon_name)).to be_truthy
      end
      specify "type" do
        expect(@taxon_name_classification.errors.include?(:type)).to be_truthy
      end

      specify 'disjoint_taxon_name_relationships' do
        TAXON_NAME_CLASSIFICATION_CLASSES.each do |r|
          r1 = r.disjoint_taxon_name_classes.collect{|i| i.to_s}
          r1 = ['a'] + r1
          r1 = r1.collect{|i| i.class.to_s}.uniq
          expect(r1.first).to eq('String')
          expect(r1.size).to eq(1)
        end
      end

      specify 'applicable_ranks' do
        TAXON_NAME_CLASSIFICATION_CLASSES.each do |r|
          r1 = r.applicable_ranks.collect{|i| i.to_s}
          r1 = ['a'] + r1
          r1 = r1.collect{|i| i.class.to_s}.uniq
          expect(r1.first).to eq('String')
          expect(r1.size).to eq(1)
        end
      end
    end

    context "validate type" do
      specify "invalid type" do
        c = FactoryGirl.build(:taxon_name_classification, type: 'aaa')
        c.valid?
        expect(c.errors.include?(:type)).to be_truthy
      end
      specify "invalid type" do
        c = FactoryGirl.build(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
        c.valid?
        expect(c.errors.include?(:type)).to be_falsey
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

    specify "applicable type and year" do
     c = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
     c.soft_validate(:proper_classification)
     expect(c.soft_validations.messages_on(:type).empty?).to be_truthy
   end
    specify "unapplicable type" do
      c = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotFromGenusName')
      c.soft_validate(:proper_classification)
      expect(c.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify "unapplicable year" do
      c = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicPublicationNotInPdfFormat')
      c.soft_validate(:proper_classification)
      expect(c.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'disjoint classes' do
      g = FactoryGirl.create(:iczn_genus, parent: @family)
      s = FactoryGirl.create(:iczn_species, parent: g)
      r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Unavailable')
      c2 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames')
      c1.soft_validate(:validate_disjoint_classes)
      c2.soft_validate(:validate_disjoint_classes)
      #conflicting with c2
      expect(c1.soft_validations.messages_on(:type).size).to eq(1)
      #conflicting with c1
      expect(c2.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'not specific classes' do
      c1 = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
      c2 = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym')
      c1.soft_validate(:not_specific_classes)
      c2.soft_validate(:not_specific_classes)
      expect(c1.soft_validations.messages_on(:type).size).to eq(1)
      expect(c2.soft_validations.messages_on(:type).size).to eq(1)
    end

  end
end
 

