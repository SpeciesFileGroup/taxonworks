require 'spec_helper'

describe Attribute do
  let (:attribute) {Attribute.new}

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
  end
end
