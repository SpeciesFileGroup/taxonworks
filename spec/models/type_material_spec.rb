require 'rails_helper'

describe TypeMaterial, :type => :model do

  after(:all) {
    # TestDbCleanup.cleanup_taxon_name_and_related
    TypeMaterial.delete_all
    CollectionObject.delete_all
  }

  let(:type_material) {TypeMaterial.new}

  context 'associations' do
    context 'belongs to' do
      specify 'protonym' do
        expect(type_material.protonym = Protonym.new).to be_truthy
      end
      specify 'material' do
        expect(type_material.material = Specimen.new).to be_truthy
      end
      specify 'source' do
        expect(type_material.source = Source::Bibtex.new).to be_truthy
      end
    end
  end

  context 'validations' do
    context 'require' do
      let(:validated_type_material) {
        type_material.valid?
        type_material
      }

      specify 'protonym' do
        expect(validated_type_material.errors.include?(:protonym)).to be_truthy
      end

      specify 'material' do
        expect(validated_type_material.errors.include?(:material)).to be_truthy
      end

      specify 'type_type' do
        expect(validated_type_material.errors.include?(:type_type)).to be_truthy
      end
    end
  end

  context 'general' do
    context 'Protonym restrictions and linkages' do
      let(:iczn_type) { 
        FactoryGirl.build(:type_material, protonym: FactoryGirl.build(:relationship_species, parent: nil))
      }

      let(:icn_type) {
        FactoryGirl.build(:type_material, protonym: FactoryGirl.build(:icn_species, parent: nil))
      }

      specify 'type_type is one of ICZN_TYPES.keys for ICZN name' do
        iczn_type.type_type = 'foo'
        iczn_type.valid?
        expect(iczn_type.errors.include?(:type_type)).to be_truthy
        expect(iczn_type.errors.messages[:type_type]).to eq(['Not a legal type for the nomenclatural code provided'])
        iczn_type.type_type = 'holotype'
        iczn_type.valid?
        expect(iczn_type.errors.include?(:type_type)).to be_falsey
      end

      specify 'type_type is one of ICN_TYPES.keys for ICN name' do
        icn_type.type_type = 'foo'
        icn_type.valid?
        expect(icn_type.errors.include?(:type_type)).to be_truthy
        expect(icn_type.errors.messages[:type_type]).to eq(['Not a legal type for the nomenclatural code provided'])
        icn_type.type_type = 'holotype'
        icn_type.valid?
        expect(icn_type.errors.include?(:type_type)).to be_falsey
      end

      specify 'protonym not a species' do
        t = FactoryGirl.build(:valid_type_material, protonym: FactoryGirl.build(:relationship_genus, parent: nil))
        t.valid?
        expect(t.errors.include?(:protonym_id)).to be_truthy
        t.protonym = FactoryGirl.build(:relationship_species, parent: nil)
        t.valid?
        expect(t.errors.include?(:protonym_id)).to be_falsey
      end
    end

    context 'Material restrictions' do
      # @proceps, nothing was done with @type_material, so I consolidated that nothing to a let here
      let(:type_material) {
        a = FactoryGirl.build_stubbed(:type_material)
        a.protonym = FactoryGirl.build_stubbed(:relationship_species, parent: nil)
        a
      }
 
      xspecify 'type_type restricts the BiologicalObject subclass to an _TYPES.value' do
      end

      xspecify 'collection_object is a BiologicalCollectionObject' do
      end
    end
  end

  context 'methods' do
    let(:iczn_type) {
      FactoryGirl.build(:valid_type_material)
    }

    let(:icn_type) {
      FactoryGirl.build(:valid_type_material, protonym: FactoryGirl.build(:icn_species))
    }

    let(:t) {FactoryGirl.create(:valid_type_material, source: FactoryGirl.create(:valid_source_bibtex)) }

    specify 'type_source from protonym' do
      expect(iczn_type.type_source).to eq(iczn_type.protonym.source)
    end

    specify 'self type_source' do
      expect(t.type_source).not_to eq(t.protonym.source)
    end

    skip 'TypeDesignator role(s) should be possible when a specific person needs to be identified as the person who designated the type'
  end

  context 'soft validation' do
    let!(:species) {FactoryGirl.create(:relationship_species) }
    let!(:iczn_type) {FactoryGirl.create(:valid_type_material, protonym: species) }
    let(:t) {FactoryGirl.create(:valid_type_material, protonym: species)  }

    context 'only one primary type' do
      specify 'for neotype' do
        t.type_type = 'neotype' 
        t.soft_validate(:single_primary_type)
        expect(t.soft_validations.messages_on(:type_type).count).to eq(1)
      end

      specify 'for syntype' do
        t.type_type = 'syntypes'
        t.soft_validate(:single_primary_type)
        expect(t.soft_validations.messages_on(:type_type).count).to eq(1)
      end
    end

    specify 'source is nil' do
      iczn_type.soft_validate(:type_source)
      expect(iczn_type.soft_validations.messages_on(:source_id).count).to eq(1)
    end
  end

end

