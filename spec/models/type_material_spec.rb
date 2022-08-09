require 'rails_helper'

describe TypeMaterial, type: :model, group: :nomenclature do

  let(:root) { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let(:species) { Protonym.create!(name: 'aus', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }

  let(:type_material) {TypeMaterial.new}

  context 'associations' do
    context 'belongs to' do
      specify 'protonym' do
        expect(type_material.protonym = Protonym.new).to be_truthy
      end
      specify 'material' do
        expect(type_material.collection_object = Specimen.new).to be_truthy
      end
    end

    context 'has_one' do 
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

      specify 'protonym_id' do
        expect(validated_type_material.errors.include?(:protonym)).to be_truthy
      end

      specify 'collection_object' do
        expect(validated_type_material.errors.include?(:collection_object)).to be_truthy
      end

      specify 'type_type' do
        expect(validated_type_material.errors.include?(:type_type)).to be_truthy
      end
    end
  end

  context 'general' do
    context 'Protonym restrictions and linkages' do
      let(:iczn_type) { 
        FactoryBot.build(:type_material, protonym: species)
      }

      let(:icn_type) {
        FactoryBot.build(:type_material, protonym: FactoryBot.build(:icn_species, parent: nil))
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

      specify 'protonym not a species 1' do
        t = FactoryBot.build(:valid_type_material, protonym: genus)
        t.valid?
        expect(t.errors.include?(:protonym_id)).to be_truthy
      end
    end
  end

  context 'methods' do
    let(:iczn_type) { FactoryBot.build(:valid_type_material) }

    let(:icn_type) {
      FactoryBot.build(:valid_type_material, protonym: FactoryBot.build(:icn_species))
    }

    let(:t) {FactoryBot.create(:valid_type_material, source: FactoryBot.create(:valid_source_bibtex)) }

    specify 'type_source from protonym' do
      expect(iczn_type.type_source).to eq(iczn_type.protonym.source)
    end

    specify 'self type_source' do
      expect(t.type_source).not_to eq(t.protonym.source)
    end
  end

  context 'nested attributes' do
    let!(:a) { TypeMaterial.create!(
      protonym: species,
      type_type: 'holotype',
      collection_object_attributes: {total: 1, buffered_collecting_event: 'Not far from the moon.'}) 
    }

    specify 'creates collection object' do
      expect(a.collection_object.id).to be_truthy
    end
  end

  context 'soft validation' do
    let!(:iczn_type) {FactoryBot.create(:valid_type_material, protonym: species) }
    let!(:iczn_lectotype) {FactoryBot.create(:valid_type_material, protonym: species, type_type: 'lectotype') }
    let(:source1) {FactoryBot.create(:valid_source_bibtex, year: 2000)}
    let(:source2) {FactoryBot.create(:valid_source_bibtex, year: 2017)}

    context 'only one primary type' do
      specify 'for neotype' do
        iczn_type.type_type = 'neotype' 
        iczn_type.soft_validate(only_sets: :single_primary_type)
        expect(iczn_type.soft_validations.messages_on(:type_type).count).to eq(1)
      end

      specify 'for syntype' do
        iczn_type.type_type = 'syntypes'
        iczn_type.soft_validate(only_sets: :single_primary_type)
        expect(iczn_type.soft_validations.messages_on(:type_type).count).to eq(1)
      end
    end

    context 'missing source' do
      specify 'source is nil' do
        iczn_type.soft_validate(only_sets: :type_source)
        expect(iczn_type.soft_validations.messages_on(:base).count).to eq(1)
      end

      specify 'source is nil for lectotype' do
        species.source = source1
        iczn_lectotype.soft_validate(only_sets: :type_source)
        expect(iczn_lectotype.soft_validations.messages_on(:base).count).to eq(1)
      end

      specify 'source is the same for lectotype' do
        iczn_lectotype.source = source1
        species.source = source1
        iczn_lectotype.soft_validate(only_sets: :type_source)
        expect(iczn_lectotype.soft_validations.messages_on(:base).count).to eq(1)
      end

      specify 'source is older for lectotype' do
        iczn_lectotype.source = source1
        species.source = source2
        iczn_lectotype.soft_validate(only_sets: :type_source)
        expect(iczn_lectotype.soft_validations.messages_on(:base).count).to eq(1)
      end

      specify 'source is properly set for lectotype' do
        iczn_lectotype.source = source2
        species.source = source1
        iczn_lectotype.soft_validate(only_sets: :type_source)
        expect(iczn_lectotype.soft_validations.messages_on(:base).count).to eq(0)
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'is_data'
  end

end

