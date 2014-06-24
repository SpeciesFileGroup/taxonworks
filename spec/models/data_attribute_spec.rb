require 'spec_helper'

describe DataAttribute do
  let (:attribute) {DataAttribute.new}

  context 'validation' do
    before(:each) {
      attribute.valid?
    }
    context 'requires' do
      specify 'attribute_subject' do
        expect(attribute.errors.include?(:attribute_subject)).to be_truthy
      end

      specify 'value' do
        expect(attribute.errors.include?(:value)).to be_truthy
      end

      specify 'type' do
        expect(attribute.errors.include?(:type)).to be_truthy
      end
    end

    specify 'key/value is unique' do
      a = FactoryGirl.create(:valid_data_attribute)
      p = ImportAttribute.new(attribute_subject: a.attribute_subject, import_predicate: 'hair color', value: 'black')
      expect(p.valid?).to be_falsey
      expect(p.errors.include?(:value)).to be_truthy
    end
  end
end
