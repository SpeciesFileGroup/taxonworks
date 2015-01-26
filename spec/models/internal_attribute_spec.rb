require 'rails_helper'

describe InternalAttribute, :type => :model do
  let(:internal_attribute) { InternalAttribute.new } 
  let(:otu) { FactoryGirl.build(:valid_otu) } 
  let(:predicate) { FactoryGirl.create(:valid_controlled_vocabulary_term_predicate) }

  context 'validation' do
    before(:each) {
      internal_attribute.valid?
    }
    context 'requires' do
      specify 'predicate' do
        expect(internal_attribute.errors.include?(:predicate)).to be_truthy
      end
    end
  end

  specify 'a valid record can be created' do
    expect(InternalAttribute.create(predicate: predicate, value: '1234', attribute_subject: otu)).to be_truthy
  end

  specify 'a valid record can be created with reference to superclass' do
    expect(DataAttribute.create(
      controlled_vocabulary_term_id:  predicate.id,
      value: '1234', attribute_subject: otu)).to be_truthy
  end
end

