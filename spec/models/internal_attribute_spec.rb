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

  specify '#predicate returns' do
    i =  InternalAttribute.create(predicate: predicate, value: '1234', attribute_subject: otu)
    expect(i.predicate).to eq(predicate)
    i.reload
    expect(i.predicate).to eq(predicate)
  end

  specify 'a valid record can be created with reference to superclass' do
    i = DataAttribute.create(
      controlled_vocabulary_term_id:  predicate.id,
      type: 'InternalAttribute',
      value: '1234', attribute_subject: otu)
    expect(i.valid?).to be(true)

  end

  specify 'a valid record can be created with reference to superclass' do
    i = DataAttribute.create!(
               controlled_vocabulary_term_id:  predicate.id,
                type: 'InternalAttribute',
               value: '1234', attribute_subject: otu
    )
    expect(i.valid?).to be(true)

    o = DataAttribute.find(i.id)
    expect(o.predicate).to eq(i.predicate)
    expect(o.predicate).to eq(predicate)
  end
end

