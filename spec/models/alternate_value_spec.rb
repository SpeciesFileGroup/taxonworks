require 'spec_helper'

describe AlternateValue do
  let (:alternate_value) { FactoryGirl.build(:alternate_value)}

  context 'associations' do
    context 'belongs_to' do
      specify 'language' do
        expect(alternate_value).to respond_to(:language)
      end

      specify 'alternate_object' do
        expect(alternate_value).to respond_to(:alternate_object)
      end
    end
  end

  context 'validation' do
    context 'required' do
      before(:each) {
        alternate_value.valid?
      }
      specify 'alternate_object' do
        expect(alternate_value.errors.include?(:alternate_object)).to be_true
      end

      specify 'alternate_object_attribute' do 
        expect(alternate_value.errors.include?(:alternate_object_attribute)).to be_true
      end

      specify 'value' do 
        expect(alternate_value.errors.include?(:value)).to be_true
      end

      specify 'type' do 
        expect(alternate_value.errors.include?(:type)).to be_true
      end
    end

    specify 'alternate_object_attribute is legal column of alternate_object' do
      alternate_value.alternate_object = FactoryGirl.create(:valid_protonym)
      alternate_value.alternate_object_attribute = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_object_attribute)).to be_true
      alternate_value.alternate_object_attribute = 'name'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_object_attribute)).to be_false
    end

    specify 'value is not identical to existing column' do
      alternate_value.alternate_object = FactoryGirl.create(:valid_otu, name: 'foo')
      alternate_value.alternate_object_attribute = 'name'
      alternate_value.value = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:value)).to be_true
      alternate_value.value = 'bar'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:value)).to be_false
    end

  end
end
