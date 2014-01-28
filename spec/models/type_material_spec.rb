require 'spec_helper'

describe TypeMaterial do
  let(:type_material) { FactoryGirl.build(:type_material)  }

  context 'associations' do
    context 'belongs to' do
      specify 'protonym' do
        expect(type_material).to respond_to(:protonym)
      end
      specify 'material' do
        expect(type_material).to respond_to(:material)
      end
      specify 'source' do
        expect(type_material).to respond_to(:source)
      end
    end
  end

  context 'validations' do
    context 'require' do
      before(:each) {
        type_material.valid? 
      }
      specify 'protonym' do
        expect(type_material.errors.include?(:protonym)).to be_true
      end

      specify 'material' do
        expect(type_material.errors.include?(:material)).to be_true
      end

      specify 'type_type' do
        expect(type_material.errors.include?(:type_type)).to be_true
      end
    end

    context 'Protonym restrictions and linkages' do
      before(:each) {
        @iczn_type = FactoryGirl.build(:type_material, protonym: FactoryGirl.build(:iczn_species))
        @icn_type = FactoryGirl.build(:type_material, protonym: FactoryGirl.build(:icn_species))
      }

      specify 'type_type is one of ICZN_TYPES.keys for ICZN name' do
        @iczn_type.type_type = 'foo'
        @iczn_type.valid?
        expect(@iczn_type.errors.include?(:type_type)).to be_true
        expect(@iczn_type.errors.messages[:type_type]).to eq(['Not a legal type for the nomenclatural code provided'])
        @iczn_type.type_type = 'holotype'
        @iczn_type.valid?
        expect(@iczn_type.errors.include?(:type_type)).to be_false
      end

      specify 'type_type is one of ICN_TYPES.keys for ICN name' do
        pending
      end
    end

    context 'Material restrictions' do
      before(:each) {
        type_material.protonym = FactoryGirl.build(:iczn_species)
      }

      specify 'type_type restricts the BiologicalObject subclass to an _TYPES.value' do
      end

      specify 'collection_object is a BiologicalCollectionObject' do
      end
    end

    context 'type_type restrictions' do
      pending 'only one of holotype, lectotype, neotype per iczn species'
    end

  end

  context 'methods' do
    before(:each) {
      iczn_type = FactoryGirl.build(:valid_type_material)
      icn_type = FactoryGirl.build(:valid_type_material, protonym: FactoryGirl.build(:icn_species))
    }
    pending 'Source is the Protonym source when not provided locally.'
    pending 'TypeDesignator role(s) should be possible when a specific person needs to be identified as the person who designated the type' 
    pending 'a source citation can identify (override the source_id in Protonym) where the type designation was made' 
  end

  context 'soft validation' do
      pending 'no source provided if self.source.nil && self.protonym.source.nil?'
  end

end

