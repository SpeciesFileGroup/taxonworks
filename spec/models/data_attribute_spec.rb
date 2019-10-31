require 'rails_helper'

describe DataAttribute, type: :model, group: :annotators do
  let(:attribute) {DataAttribute.new}

  context 'validation' do
    before(:each) {
      attribute.valid?
    }

    context 'requires' do
      specify 'attribute_subject' do 
        # this eliminates all model based validation requirements
        attribute.type = 'ImportAttribute'
        attribute.value = 'asdf'
        attribute.import_predicate = 'jkl'
        expect{attribute.save}.to raise_error ActiveRecord::StatementInvalid
      end

      specify 'value' do
        expect(attribute.errors.include?(:value)).to be_truthy
      end

      specify 'type' do
        expect(attribute.errors.include?(:type)).to be_truthy
      end
    end

    context 'uniqueness' do
      let(:o) {FactoryBot.create(:valid_otu) }

      context 'InternalAttribute' do
        let(:p) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }

        let!(:d1) { InternalAttribute.create(attribute_subject: o, predicate: p, value: 'abc' ) }
        let(:d2) { InternalAttribute.new(attribute_subject: o, predicate: p, value: 'abc' ) }

        specify 'key + value is unique' do
          expect(d2.valid?).to be_falsey
          expect(d2.errors.include?(:value)).to be_truthy
        end

        specify 'key + different value is ??' do
          d2.value = 'def'
          expect(d2.valid?).to be_truthy
          expect(d2.errors.include?(:value)).to be_falsey
        end



      end

      context 'ImportAttribute' do
        let!(:a1) { ImportAttribute.create(attribute_subject: o, import_predicate: 'hair color', value: 'black') }
        let(:a2) { ImportAttribute.new(attribute_subject: o, import_predicate: 'hair color', value: 'black') }

        specify 'key/value is unique' do
          expect(a2.valid?).to be_falsey
          expect(a2.errors.include?(:value)).to be_truthy
        end
      end
    end
  end

  context 'citaiton' do
    let(:data_attribute) { FactoryBot.create(:valid_data_attribute) }
    specify 'can be cited' do
      expect(Citation.create!(citation_object: data_attribute, source: FactoryBot.create(:valid_source))).to be_truthy
    end
  end

  context 'houskeeping on data attributes' do
    let(:p) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }

    context 'attached to project data sets project_id' do
      let(:o) { FactoryBot.create(:valid_otu) }

      specify 'for an import attribute' do
        att = DataAttribute.new(import_predicate: 'foo', value: '6', type: 'ImportAttribute')
        o.data_attributes << att
        expect(o.save!).to be_truthy
        expect(att.project_id).to eq(1)
      end

      specify 'for an internal attribute' do
        att = DataAttribute.new(predicate: p, value: '6', type: 'InternalAttribute')
        o.data_attributes << att
        expect(o.save!).to be_truthy
        expect(att.project_id).to eq(1)
      end
    end

    context 'attached to community data with is_community_annotation == true does not set project_id, ' do
      let(:s) { FactoryBot.create(:valid_serial) }

      context 'for an import attribute' do
        specify 'using <<' do
          att = DataAttribute.new(import_predicate: 'foo', value: '6', type: 'ImportAttribute', is_community_annotation: true)
          s.data_attributes << att
          expect(s.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end

        specify 'using build()' do
          s.data_attributes.build(import_predicate: 'foo', value: '6', type: 'ImportAttribute', is_community_annotation: true) 
          expect(s.save!).to be_truthy
          expect(s.data_attributes.first.project_id).to eq(nil)
        end

        specify 'using new()' do
          att = DataAttribute.new(import_predicate: 'foo', value: '6', type: 'ImportAttribute', attribute_subject: s, is_community_annotation: true)
          expect(att.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end
      end

      context 'for an internal attribute' do
        specify 'using <<' do
          att = DataAttribute.new(predicate: p, value: '6', type: 'InternalAttribute', is_community_annotation: true)
          s.data_attributes << att
          expect(s.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end

        specify 'using build()' do
          s.data_attributes.build(predicate: p, value: '6', type: 'InternalAttribute', is_community_annotation: true) 
          expect(s.save!).to be_truthy
          expect(s.data_attributes.first.project_id).to eq(nil)
        end

        specify 'using new()' do
          att = DataAttribute.new(predicate: p, value: '6', type: 'InternalAttribute', attribute_subject: s, is_community_annotation: true)
          expect(att.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end
      end

      context 'using nested attributes' do
        specify 'for community data' do
          s = Serial.new(name: 'Blorf', data_attributes_attributes: [{predicate: p, value: '6', type: 'InternalAttribute', attribute_subject: s, is_community_annotation: true}])  
          expect(s.save!).to be_truthy
          expect(s.data_attributes.size).to eq(1)
          expect(s.data_attributes.first.project_id).to eq(nil)
        end
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
    it_behaves_like 'citations'
  end

end
