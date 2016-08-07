require 'rails_helper'

RSpec.describe Matrix, type: :model do

  let(:matrix) {Matrix.new}

  context 'associations' do 
    context 'has_many' do
      specify '#matrix_column_items' do
        expect(matrix.matrix_column_items << MatrixColumnItem.new).to be_truthy
      end
    end

  end

  context :validation do
    before {matrix.valid?}
    specify 'name is required' do
      expect(matrix.errors.include?(:name)).to be_truthy
    end
  end

end
