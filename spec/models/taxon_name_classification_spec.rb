require 'rails_helper'
      
Dir[Rails.root.to_s + '/app/models/taxon_name_classification/**/*.rb'].each {
  |file| require_dependency(file) 
} 

describe TaxonNameClassification, type: :model do

  let(:taxon_name_classification) { TaxonNameClassification.new }

  after(:all) {
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    TaxonNameClassification.delete_all
  }

  context 'meta/configuration' do
#    specify 'that .classification_label does not overlap' do
#      existing_names = []
#      TaxonNameClassification.descendants.each do |klass|
#        name = klass.new.classification_label
#        if name
#          expect(existing_names.include?(name)).to be(false), "#{name} from #{klass.name} is duplicated!"
#          existing_names.push name
#        end
#      end
#    end

    specify 'missing and duplicate NOMEN_URI' do
      nomen_uris = []
      TaxonNameClassification.descendants.each do |klass|
        uri = klass.nomen_uri
        expect(uri.empty?).to be_falsey, "NOMEN_URI for #{klass.name} is empty!"
        expect(nomen_uris.include?(uri)).to be(false), "#{uri} from #{klass.name} is duplicated!"
        expect(uri).to match(/http:\/\/purl.obolibrary.org\/obo\/NOMEN/), "#{uri} from #{klass.name} is invalid!"
        nomen_uris.push uri
      end
    end
  end

  context "validation" do
    context "requires" do
      before { taxon_name_classification.valid? } 

      specify "taxon_name" do
        expect(taxon_name_classification.errors.include?(:taxon_name)).to be_truthy
      end

      specify "type" do
        expect(taxon_name_classification.errors.include?(:type)).to be_truthy
      end

      specify 'disjoint_taxon_name_relationships' do
        TAXON_NAME_CLASSIFICATION_CLASSES.each do |r|
          r1 = r.disjoint_taxon_name_classes.collect{|i| i.to_s}
          r1 = ['a'] + r1
          r1 = r1.collect {|i| i.class.to_s}.uniq
          expect(r1.first).to eq('String')
          expect(r1.size).to eq(1)
        end
      end

      specify 'applicable_ranks' do
        TAXON_NAME_CLASSIFICATION_CLASSES.each do |r|
          r1 = r.applicable_ranks.collect{|i| i.to_s}
          r1 = ['a'] + r1
          r1 = r1.collect {|i| i.class.to_s}.uniq
          expect(r1.first).to eq('String')
          expect(r1.size).to eq(1)
        end
      end
    end


    context 'validate nomenclature code' do
      before do
        root = FactoryGirl.create(:root_taxon_name)
      end

      let(:g) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus)) }

      specify 'missmatched code returns error' do
        taxon_name_classification.taxon_name = g
        taxon_name_classification.type_class = 'TaxonNameClassification::Icn::Fossil'
        expect(taxon_name_classification.valid?).to be_falsey
        msg = "Taxon name <i>Aus</i> belongs to iczn nomenclatural code, but the status used from icn nomenclature code"
        expect(taxon_name_classification.errors.full_messages.include?(msg)).to be_truthy
      end
    end

    context "validate type" do
      specify "an invalid type" do
        c = FactoryGirl.build(:taxon_name_classification, type: 'aaa')
        c.valid?
        expect(c.errors.include?(:type)).to be_truthy
      end

      specify "another invalid type" do
        c = FactoryGirl.build(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
        c.valid?
        expect(c.errors.include?(:type)).to be_falsey
      end
    end
  end

  specify '#type_class can set type' do
    taxon_name_classification.type_class = TaxonNameClassification::Latinized::Gender::Feminine
    expect(taxon_name_classification.type).to eq('TaxonNameClassification::Latinized::Gender::Feminine')
  end

  specify '#type_class returns a klass' do
    a = TaxonNameClassification::Latinized::Gender::Feminine
    taxon_name_classification.type_class = a
    expect(taxon_name_classification.type_class).to eq(a)
    expect(taxon_name_classification.type_class).to eq('TaxonNameClassification::Latinized::Gender::Feminine'.constantize)
  end

  context 'with type set' do
    before { taxon_name_classification.type_class = TaxonNameClassification::Iczn::Unavailable }

    specify '#type_name returns a String' do
      expect(taxon_name_classification.type_name).to be_a(String)
    end

    specify '#nomenclature_code' do
      expect(taxon_name_classification.nomenclature_code).to eq(:iczn)
    end
  end

  context '#nomenclature_code' do
    specify ':iczn' do
      taxon_name_classification.type_class = TaxonNameClassification::Iczn::Unavailable
      expect(taxon_name_classification.nomenclature_code).to eq(:iczn)
    end

    specify ':icn' do
      taxon_name_classification.type_class = TaxonNameClassification::Icn::Fossil
      expect(taxon_name_classification.nomenclature_code).to eq(:icn)
    end

   specify 'none (nil)' do
      taxon_name_classification.type_class = TaxonNameClassification::Latinized::Gender::Feminine
      expect(taxon_name_classification.nomenclature_code).to eq(nil)
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
      c2 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology')
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

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
 

