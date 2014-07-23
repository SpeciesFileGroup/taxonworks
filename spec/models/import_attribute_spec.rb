require 'rails_helper'

describe ImportAttribute, :type => :model do
  let (:attribute) {ImportAttribute.new}

  context 'validation' do
    before(:each) {
      attribute.valid?
    }
    context 'requires' do
      specify 'import_predicate' do
        expect(attribute.errors.include?(:import_predicate)).to be_truthy
      end
    end
  end

end
