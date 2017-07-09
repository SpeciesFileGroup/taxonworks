require 'rails_helper'

RSpec.describe ObservationMatrix, type: :model do

  let(:matrix) {ObservationMatrix.new}

  context 'associations' do 
    context 'has_many' do
      specify '#matrix_column_items' do
        expect(matrix.observation_matrix_column_items << ObservationMatrixColumnItem.new).to be_truthy
      end
    end

  end

  let(:observation_matrix) {ObservationMatrix.new}

  context :validation do
    before {matrix.valid?}
    specify 'name is required' do
      expect(matrix.errors.include?(:name)).to be_truthy
    end
  end

end
