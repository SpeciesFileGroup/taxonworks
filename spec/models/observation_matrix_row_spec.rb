require 'rails_helper'

RSpec.describe ObservationMatrixRow, type: :model, group: :observation_matrix do

  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  let(:observation_matrix_row) {ObservationMatrixRow.new}
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:otu1) { FactoryBot.create(:valid_otu) }
  let(:collection_object) {  FactoryBot.create(:valid_collection_object) }

  context :validation do
    let(:valid_matrix_given) do
      observation_matrix_row.observation_matrix = observation_matrix 
    end

    let(:valid_otu_given) do
      observation_matrix_row.otu = otu 
    end

    let(:valid_collection_object_given) do
      observation_matrix_row.collection_object = collection_object
    end

    context 'with valid matrix given' do
      before do
        valid_matrix_given
      end

      context :valid_observation_matrix_row do
        specify 'only Otu given' do
          valid_otu_given
          expect(observation_matrix_row.valid?).to be_truthy
        end

        specify 'only Collection Object given' do
          valid_collection_object_given
          observation_matrix_row.valid?
          expect(observation_matrix_row.valid?).to be_truthy
        end
      end
    end

    context 'observations' do
      let!(:o) { FactoryBot.create(:valid_observation, otu: otu) }
      let!(:o1) { FactoryBot.create(:valid_observation, otu: otu) } # does not use same dd
      let(:o2) { FactoryBot.create(:valid_observation, otu: otu1) } # does not use same dd
      let(:d) { o.descriptor }
      let!(:c) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix, descriptor: d ) }
      let!(:r) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, otu: otu) }
      let!(:r1) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }
      let!(:r2) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, otu: otu1) }

      specify '#observations' do
        expect(r.observations.map(&:id)).to contain_exactly(o.id)
      end

      specify '#observations2' do
        expect(r1.observations.map(&:id)).to contain_exactly()
      end

      specify 'with_otu_ids' do
        expect(observation_matrix.observation_matrix_rows.with_otu_ids(otu.id.to_s + '|' + otu1.id.to_s).count).to eq(2)
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

    context :invalid_observation_matrix_row do
      specify 'no matrix given' do
        observation_matrix_row.valid?
        expect(observation_matrix_row.errors.include?(:observation_matrix)).to be_truthy
      end

      context 'with valid matrix given' do
        before do
          valid_matrix_given
        end

        specify 'Otu AND Collection Object given' do
          valid_otu_given
          valid_collection_object_given
          observation_matrix_row.valid?
          expect(observation_matrix_row.errors.include?(:base)).to be_truthy
        end

        specify 'neither Otu nor Collection Object given' do
          observation_matrix_row.valid?
          expect(observation_matrix_row.errors.include?(:base)).to be_truthy
        end

        specify 'creating 2 MatrixRow with same matrix and same otu' do
          ObservationMatrixRow.create!(observation_matrix_id: observation_matrix.id, otu_id: otu.id)
          expect(ObservationMatrixRow.create(observation_matrix_id: observation_matrix.id, otu_id: otu.id).id).to be_falsey
        end

        specify 'creating 2 MatrixRow with same matrix and same otu 2' do
          ObservationMatrixRow.create!(observation_matrix: observation_matrix, otu: otu)
          expect(ObservationMatrixRow.create(observation_matrix: observation_matrix, otu: otu).id).to be_falsey
        end

        specify 'creating 2 MatrixRow with same matrix and same collection object' do
          ObservationMatrixRow.create!(observation_matrix_id: observation_matrix.id, collection_object_id: collection_object.id)
          expect(ObservationMatrixRow.create(observation_matrix_id: observation_matrix.id, collection_object_id: collection_object.id).id).to be_falsey
        end

        specify 'creating 2 MatrixRow with same matrix and same collection object 2' do
          ObservationMatrixRow.create!(observation_matrix: observation_matrix, collection_object: collection_object)
          expect(ObservationMatrixRow.create(observation_matrix: observation_matrix, collection_object: collection_object).id).to be_falsey
        end

      end
    end
  end
end
