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

  context 'Creating DataAttributes on data objects' do
    specify 'add new import attribute' do
      o = FactoryGirl.build(:valid_otu)
      ip = FactoryGirl.build(:valid_controlled_vocabulary_term_predicate)
      att = DataAttribute.new({import_predicate: ip.name, value: '6', type: 'ImportAttribute'})
      o.data_attributes <<  att
      expect(o.valid?).to be_truthy
      expect(o.data_attributes.to_a.count).to eq(1)
      expect(att.valid?).to be_truthy
      expect(o.save).to be_truthy
      expect(o.data_attributes[0]).to eq(att)
    end
    specify 'add new internal attribute' do
      o = FactoryGirl.build(:valid_otu)
      p = FactoryGirl.build(:valid_controlled_vocabulary_term_predicate)
      att = DataAttribute.new({predicate: p, value: '6', type: 'InternalAttribute'})
      o.data_attributes <<  att
      expect(o.valid?).to be_truthy
      expect(o.data_attributes.to_a.count).to eq(1)
      expect(att.valid?).to be_truthy
      expect(o.save).to be_truthy
      expect(o.data_attributes[0]).to eq(att)
    end
  end
  context 'Creating DataAttributes on shared objects' do
    specify 'add new import attribute' do
      o = FactoryGirl.build(:valid_serial)
      ip = FactoryGirl.build(:valid_controlled_vocabulary_term_predicate)
      att = DataAttribute.new({import_predicate: ip.name, value: '6', type: 'ImportAttribute'})
      o.data_attributes <<  att
      expect(o.valid?).to be_truthy
      expect(o.data_attributes.to_a.count).to eq(1)
      expect(att.valid?).to be_truthy
      expect(o.save).to be_truthy
      expect(o.data_attributes[0]).to eq(att)
    end
    specify 'add new internal attribute' do
      o = FactoryGirl.build(:valid_serial)
      p = FactoryGirl.build(:valid_controlled_vocabulary_term_predicate)
      att = DataAttribute.new({predicate: p, value: '6', type: 'InternalAttribute'})
      o.data_attributes <<  att
      expect(o.valid?).to be_truthy
      expect(o.data_attributes.to_a.count).to eq(1)
      expect(att.valid?).to be_truthy
      expect(o.save).to be_truthy
      expect(o.data_attributes[0]).to eq(att)
    end
  end
end
