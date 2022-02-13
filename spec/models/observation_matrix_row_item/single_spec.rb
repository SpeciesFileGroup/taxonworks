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

  specify '#controlled_vocabulary_term_id (subclass) is not allowed' do
    observation_matrix_row_item.controlled_vocabulary_term_id = FactoryBot.create(:valid_keyword).id
    observation_matrix_row_item.valid?
    expect(observation_matrix_row_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
  end

  context 'with a observation_matrix_row_item saved' do
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
    end

    specify 'observation can only be added once to observation_matrix_row_item' do
      expect(ObservationMatrixRowItem::Single.new(observation_matrix: observation_matrix, observation_object: otu).valid?).to be_falsey
    end
  end
end
