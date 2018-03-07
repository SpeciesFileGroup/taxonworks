require 'rails_helper'

RSpec.describe ObservationMatrixRowItem, type: :model, group: :matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem.new }

  context 'validation' do
    before { observation_matrix_row_item.valid? }

    specify 'observation_matrix is required' do
      expect(observation_matrix_row_item.errors.include?(:observation_matrix)).to be_truthy
    end

    specify 'type is required' do
      expect(observation_matrix_row_item.errors.include?(:type)).to be_truthy
    end
  end

  context 'subclass STI' do
    MATRIX_ROW_ITEM_TYPES.each_key do |k|
      context k do
        let(:klass) { k.constantize }

        specify '.subclass_attributes is defined' do
          expect(klass.respond_to?(:subclass_attributes)).to be_truthy
        end

        specify '.subclass_attributes is populated' do
          expect(klass.subclass_attributes.size).to be > 0
        end

        specify '.subclass_attributes are present in ALL_STI_ATTRIBUTES' do
          expect((klass.subclass_attributes - ObservationMatrixRowItem::ALL_STI_ATTRIBUTES).size).to be 0
        end
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'is_data'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
  end
end
