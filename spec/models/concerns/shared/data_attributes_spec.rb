require 'rails_helper'

describe 'DataAttributes', type: :model do
  let(:class_with_data_attributes) {TestDataAttribute.new}

  context 'associations' do
    specify 'has many data_attributes - includes creating a data_attribute' do
      expect(class_with_data_attributes).to respond_to(:data_attributes)
      expect(class_with_data_attributes.data_attributes.to_a).to eq([])
      expect(class_with_data_attributes.data_attributes << FactoryBot.build(:data_attribute, value: '10', import_predicate: 'foos', type: 'ImportAttribute')).to be_truthy
      expect(class_with_data_attributes.data_attributes.size).to eq(1)
      expect(class_with_data_attributes.save).to be_truthy
      expect(class_with_data_attributes.data_attributes.any?).to eq(true)
      expect(class_with_data_attributes.data_attributes.first.id.nil?).to eq(false)
    end
  end

  context 'methods' do
    before(:each) {
      class_with_data_attributes.data_attributes.delete_all
    }

    specify 'has any data attributes?' do
      expect(class_with_data_attributes.data_attributes.any?).to eq(false)
    end

    specify 'keyword_value_hash' do
      class_with_data_attributes.data_attributes << ImportAttribute.new(value: '10', import_predicate: 'legs')
      expect(class_with_data_attributes.data_attributes.size).to eq(1)
      expect(class_with_data_attributes.keyword_value_hash).to eq('legs' => '10')
      class_with_data_attributes.data_attributes << InternalAttribute.new(value: 'purple', predicate: FactoryBot.build(:valid_controlled_vocabulary_term_predicate, name: 'Color') )
      expect(class_with_data_attributes.keyword_value_hash).to eq('legs' => '10', 'Color' => 'purple')
    end

    context 'object with attributes' do
      context 'on destroy' do
        specify 'attached attributes are destroyed' do
          expect(DataAttribute.count).to eq(0)
          class_with_data_attributes.data_attributes << FactoryBot.build(:data_attribute_import_attribute, value: '10', import_predicate: 'legs')
          class_with_data_attributes.data_attributes << FactoryBot.build(:valid_data_attribute_internal_attribute, value: 'purple', predicate: FactoryBot.build(:valid_controlled_vocabulary_term_predicate, name: 'Color') )
          expect(class_with_data_attributes.data_attributes.size).to eq(2)
          expect(class_with_data_attributes.destroy).to be_truthy
          expect(DataAttribute.count).to eq(0)
        end
      end
    end
  end

  context 'adding lots of attributes' do
    specify 'add_import_attributes(hash) should add multiple pairs of ImportAttributes' do
      # skip
    end
  end

end

class TestDataAttribute < ApplicationRecord
  include FakeTable
  include Shared::DataAttributes
end


