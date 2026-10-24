require 'rails_helper'

RSpec.describe ObservationMatrixRowItem::Single, type: :model, group: :observation_matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem::Single.new }
  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  let(:otu) { FactoryBot.create(:valid_otu) }

  specify '#observation_object required' do
    observation_matrix_row_item.valid?
    expect(observation_matrix_row_item.errors.include?(:observation_object)).to be_truthy
  end

  specify '#observation_matrix required' do
    observation_matrix_row_item.valid?
    expect(observation_matrix_row_item.errors.include?(:observation_matrix)).to be_truthy
  end

  context 'with an observation_matrix_row_item saved' do
    before { observation_matrix_row_item.update!(
      observation_matrix: observation_matrix,
      observation_object: otu)
    }

    context 'adding an item synchronizes observation_matrix rows' do
      specify 'saving a record adds otu observation_matrix_rows' do
        expect(ObservationMatrixRow.first.observation_object).to eq(otu)
      end

      specify 'added observation_matrix_row has reference_count = 1' do
        expect(ObservationMatrixRow.first.reference_count).to eq 1
      end

      specify '#cached_observation_matrix_row_item_id is set for correlated observation_matrix_row' do
        expect(ObservationMatrixRow.first.cached_observation_matrix_row_item_id).to eq observation_matrix_row_item.id
      end

      specify 'destroying a record removes observation_object from observation_matrix_rows' do
        observation_matrix_row_item.destroy
        expect(ObservationMatrixRow.count).to eq 0
      end

      specify 'updating an attribute other than observation_object does not change reference_count' do
        observation_matrix_row_item.update!(position: 5)
        expect(ObservationMatrixRow.first.reference_count).to eq 1
      end

      context 'changing the observation_object' do
        let(:collection_object) { FactoryBot.create(:valid_collection_object) }

        before { observation_matrix_row_item.update!(observation_object: collection_object) }

        specify 'removes the previous observation_object row' do
          expect(ObservationMatrixRow.where(observation_object: otu).count).to eq 0
        end

        specify 'adds a row for the new observation_object' do
          r = ObservationMatrixRow.where(observation_object: collection_object).first
          expect(r.reference_count).to eq 1
          expect(r.cached_observation_matrix_row_item_id).to eq observation_matrix_row_item.id
        end
      end

      context 'changing the observation_matrix' do
        let(:other_observation_matrix) { FactoryBot.create(:valid_observation_matrix) }

        before { observation_matrix_row_item.update!(observation_matrix: other_observation_matrix) }

        specify 'removes the row from the previous matrix' do
          expect(ObservationMatrixRow.where(observation_matrix:).count).to eq 0
        end

        specify 'adds a row to the new matrix' do
          r = ObservationMatrixRow.where(observation_matrix: other_observation_matrix).first
          expect(r.observation_object).to eq otu
          expect(r.reference_count).to eq 1
          expect(r.cached_observation_matrix_row_item_id).to eq observation_matrix_row_item.id
        end
      end
    end

    specify 'observation can only be added once to observation_matrix_row_item' do
      expect(ObservationMatrixRowItem::Single.new(observation_matrix: observation_matrix, observation_object: otu).valid?).to be_falsey
    end
  end
end
