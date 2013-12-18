require 'spec_helper'

describe DataAttribute do
  let (:attribute) {DataAttribute.new}

  context 'validation' do
    before(:each) {
      attribute.valid?
    }
    context 'requires' do
      specify 'attribute_subject' do
        expect(attribute.errors.include?(:attribute_subject)).to be_true
      end

      specify 'value' do
        expect(attribute.errors.include?(:value)).to be_true
      end

      specify 'type' do
        expect(attribute.errors.include?(:type)).to be_true
      end
    end

    specify 'key/value is unique' do
      a = FactoryGirl.create(:valid_data_attribute)
      p = DataAttribute::ImportAttribute.new(attribute_subject: a.attribute_subject, import_predicate: 'hair color', value: 'black')
      expect(p.valid?).to be_false
      expect(p.errors.include?(:value)).to be_true
    end
  end
end
