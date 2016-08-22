require 'rails_helper'

RSpec.describe MatrixRowItem, type: :model, group: :matrix do
  let(:matrix_row_item) { MatrixRowItem.new }

  context 'validation' do
    before { matrix_row_item.valid? }

    specify 'matrix is required' do
      expect(matrix_row_item.errors.include?(:matrix_id)).to be_truthy
    end

    specify 'type is required' do
      expect(matrix_row_item.errors.include?(:type)).to be_truthy
    end
  end

  context 'subclass STI' do
    MATRIX_ROW_ITEM_TYPES.keys.each do |k|
      context k do
        let(:klass) { k.constantize }

        specify '.subclass_attributes is defined' do
          expect(klass.respond_to?(:subclass_attributes)).to be_truthy
        end

        specify '.subclass_attributes is populated' do
          expect(klass.subclass_attributes.size).to be > 0
        end

        specify '.subclass_attributes are present in ALL_STI_ATTRIBUTES' do
          expect((klass.subclass_attributes - MatrixRowItem::ALL_STI_ATTRIBUTES).size).to be 0
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
