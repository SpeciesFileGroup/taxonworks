require 'rails_helper'

RSpec.describe ObservationMatrixColumn, type: :model, group: :observation_matrix do

  let(:observation_matrix_column) {ObservationMatrixColumn.new}
  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  let(:descriptor) { FactoryBot.create(:valid_descriptor) }

  context 'validation' do
    before {observation_matrix_column.valid?}

    specify 'observation_matrix' do
      expect(observation_matrix_column.errors.include?(:observation_matrix)).to be_truthy
    end

    specify 'descriptor' do
      expect(observation_matrix_column.errors.include?(:descriptor)).to be_truthy
    end

    specify 'descriptor is unique to observation_matrix' do
      ObservationMatrixColumn.create!(observation_matrix: observation_matrix, descriptor: descriptor)
      mc = ObservationMatrixColumn.new(observation_matrix: observation_matrix, descriptor: descriptor)
      expect(mc.valid?).to be_falsey
      expect(mc.errors.include?(:descriptor_id)).to be_truthy 
    end
  end

  context '#sort' do
    let!(:column1) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix) }
    let!(:column2) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix) }
    let!(:column3) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix) }

    specify '#sort 1' do
      ObservationMatrixColumn.sort([column2.id, column3.id, column1.id])
      expect(column2.reload.position < column3.reload.position).to be_truthy
      expect(column3.reload.position < column1.reload.position).to be_truthy
    end
  end

end
