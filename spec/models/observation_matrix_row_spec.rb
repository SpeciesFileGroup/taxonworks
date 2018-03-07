require 'rails_helper'

RSpec.describe ObservationMatrixRow, type: :model, group: :matrix do
  
=begin
  Co = collection_object

  Validation
    Valid matrix row
      When valid matrix
        When only Otu, pass
        When only Co, pass
    Invalid matix row
      When no valid matrix 
      When valid matrix
        When Otu AND Co, fail
        When no Otu AND no Co, fail
=end

  let(:observation_matrix_row) {ObservationMatrixRow.new}

  context :validation do
    let(:valid_matrix_given) do
      observation_matrix_row.observation_matrix = FactoryBot.create(:valid_observation_matrix)
    end

    let(:valid_otu_given) do
      observation_matrix_row.otu = FactoryBot.create(:valid_otu)
    end

    let(:valid_collection_object_given) do
      observation_matrix_row.collection_object = FactoryBot.create(:valid_collection_object)
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
          matrix = FactoryBot.create(:valid_observation_matrix)
          otu = FactoryBot.create(:valid_otu)

          ObservationMatrixRow.create!(observation_matrix_id: matrix.id, otu_id: otu.id)
          expect(ObservationMatrixRow.create(observation_matrix_id: matrix.id, otu_id: otu.id).id).to be_falsey
        end

        specify 'creating 2 MatrixRow with same matrix and same collection object' do
          matrix = FactoryBot.create(:valid_observation_matrix)
          co = FactoryBot.create(:valid_collection_object)

          ObservationMatrixRow.create!(observation_matrix_id: matrix.id, collection_object_id: co.id)
          expect(ObservationMatrixRow.create(observation_matrix_id: matrix.id, collection_object_id: co.id).id).to be_falsey
        end
      end
    end
  end
end
