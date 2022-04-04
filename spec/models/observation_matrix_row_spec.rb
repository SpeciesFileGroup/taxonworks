require 'rails_helper'

RSpec.describe ObservationMatrixRow, type: :model, group: :observation_matrix do

  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  let(:observation_matrix_row) {ObservationMatrixRow.new}
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:otu1) { FactoryBot.create(:valid_otu) }
  let(:collection_object) {  FactoryBot.create(:valid_collection_object) }

  specify 'requires observation matrix' do
    observation_matrix_row.valid?
    expect(observation_matrix_row.errors.include?(:observation_matrix)).to be_truthy
  end

  specify 'requires observation_object' do
    observation_matrix_row.valid?
    expect(observation_matrix_row.errors.include?(:observation_object)).to be_truthy
  end

  specify 'observation object can not be duplicated in matrix' do
    ObservationMatrixRow.create!(observation_matrix_id: observation_matrix.id, observation_object: otu)
    expect(ObservationMatrixRow.create(observation_matrix_id: observation_matrix.id, observation_object: otu).persisted?).to be_falsey
  end

  context 'observations' do
    let!(:o) { FactoryBot.create(:valid_observation, observation_object: otu) }
    let!(:o1) { FactoryBot.create(:valid_observation, observation_object: otu) } # does not use same dd
    let(:o2) { FactoryBot.create(:valid_observation, observation_object: otu1) } # does not use same dd

    let(:d) { o.descriptor }
    let!(:c) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix, descriptor: d ) }
    let!(:r) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, observation_object: otu) }
    let!(:r1) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }
    let!(:r2) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, observation_object: otu1) }

    specify '#observations' do
      #  byebug
      expect(r.observations.map(&:id)).to contain_exactly(o.id)
    end

    specify '#observations2' do
      expect(r1.observations.map(&:id)).to contain_exactly()
    end
  end

  context '#sort' do
    let!(:row1) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }
    let!(:row2) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }
    let!(:row3) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }

    specify '#sort 1' do
      ObservationMatrixRow.sort([row2.id, row3.id, row1.id])
      expect(row2.reload.position < row3.reload.position).to be_truthy
      expect(row3.reload.position < row1.reload.position).to be_truthy
    end
  end

end
