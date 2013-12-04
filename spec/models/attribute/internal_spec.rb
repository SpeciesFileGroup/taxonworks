require 'spec_helper'

describe Attribute::Internal do
  let (:attribute) {Attribute::Internal.new}

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
