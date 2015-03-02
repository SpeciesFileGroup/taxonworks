require 'rails_helper'

describe DataAttribute, :type => :model do
  let(:attribute) {DataAttribute.new}

  context 'validation' do
    before(:each) {
      attribute.valid?
    }
    context 'requires' do

      specify 'attribute_subject' do 
        # this eliminate all model based validation requirements
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

    #    specify

    # Hmmm.. review this
    specify 'key/value is unique' do
      a = FactoryGirl.create(:valid_data_attribute, value: 'black')
      p = ImportAttribute.new(attribute_subject: a.attribute_subject, import_predicate: 'hair color', value: 'black')
      expect(p.valid?).to be_falsey
      expect(p.errors.include?(:value)).to be_truthy
    end
  end

  context 'houskeeping on data attributes' do
    let(:p) { FactoryGirl.create(:valid_controlled_vocabulary_term_predicate) }

    context 'attached to project data sets project_id' do
      let(:o) { FactoryGirl.create(:valid_otu) }

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

    context 'attached to community data does not set project_id' do
      let(:s) { FactoryGirl.create(:valid_serial) }

      context 'for an import attribute' do
        specify 'using <<' do
          att = DataAttribute.new(import_predicate: 'foo', value: '6', type: 'ImportAttribute')
          s.data_attributes << att
          expect(s.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end

        specify 'using build()' do
          s.data_attributes.build(import_predicate: 'foo', value: '6', type: 'ImportAttribute') 
          expect(s.save!).to be_truthy
          expect(s.data_attributes.first.project_id).to eq(nil)
        end

        specify 'using new()' do
          att = DataAttribute.new(import_predicate: 'foo', value: '6', type: 'ImportAttribute', attribute_subject: s)
          expect(att.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end
      end

      context 'for an internal attribute' do
        specify 'using <<' do
          att = DataAttribute.new(predicate: p, value: '6', type: 'InternalAttribute')
          s.data_attributes << att
          expect(s.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end

        specify 'using build()' do
          s.data_attributes.build(predicate: p, value: '6', type: 'InternalAttribute') 
          expect(s.save!).to be_truthy
          expect(s.data_attributes.first.project_id).to eq(nil)
        end

        specify 'using new()' do
          att = DataAttribute.new(predicate: p, value: '6', type: 'InternalAttribute', attribute_subject: s)
          expect(att.save!).to be_truthy
          expect(att.project_id).to eq(nil)
        end
      end

      context 'using nested attributes' do
        specify 'for community data' do
          s = Serial.new(name: 'Blorf', data_attributes_attributes: [{predicate: p, value: '6', type: 'InternalAttribute', attribute_subject: s}])  
          expect(s.save!).to be_truthy
          expect(s.data_attributes.size).to eq(1)
          expect(s.data_attributes.first.project_id).to eq(nil)
        end
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
