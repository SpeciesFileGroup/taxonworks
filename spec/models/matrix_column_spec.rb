require 'rails_helper'

RSpec.describe MatrixColumn, type: :model, group: :matrix do

  let(:matrix_column) {MatrixColumn.new}
  let(:matrix) { FactoryGirl.create(:valid_matrix) }
  let(:descriptor) { FactoryGirl.create(:valid_descriptor) }

  context 'validation' do
    before {matrix_column.valid?}

    specify 'matrix_id' do
      expect(matrix_column.errors.include?(:matrix_id)).to be_truthy
    end

    specify 'descriptor_id' do
      expect(matrix_column.errors.include?(:descriptor_id)).to be_truthy
    end

    specify 'descriptor is unique to matrix' do
      MatrixColumn.create!(matrix: matrix, descriptor: descriptor)
      mc = MatrixColumn.new(matrix: matrix, descriptor: descriptor)
      expect(mc.valid?).to be_falsey
      expect(mc.errors.include?(:descriptor_id)).to be_truthy 
    end

  end

end
