require 'spec_helper'

describe InternalAttribute do
  let (:attribute) { FactoryGirl.build(:data_attribute_internal_attribute) } 

  context 'validation' do
    before(:each) {
      attribute.valid?
    }
    context 'requires' do
      specify 'predicate' do
        expect(attribute.errors.include?(:predicate)).to be_true
      end
    end
  end
end
