require 'rails_helper'

RSpec.describe ObservationMatrixRowItem::Single::Otu, type: :model, group: :observation_matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem::Single::Otu.new }

  context 'validation' do
    before { observation_matrix_row_item.valid? }

    context 'association' do
      specify 'belongs_to otu' do
        expect(observation_matrix_row_item.otu = Otu.new()).to be_truthy
      end
    end

    specify 'otu is required' do
      expect(observation_matrix_row_item.errors.include?(:otu)).to be_truthy
    end

    specify 'type is "ObservationMatrixRowItem::Single::Otu"' do
      expect(observation_matrix_row_item.type).to eq('ObservationMatrixRowItem::Single::Otu')
    end

    context 'other possible subclass attributes are nil' do
      specify 'collection_object_id' do
        observation_matrix_row_item.collection_object_id = FactoryBot.create(:valid_collection_object).id
        observation_matrix_row_item.valid?
        expect(observation_matrix_row_item.errors.include?(:collection_object_id)).to be_truthy
      end

      specify 'controlled_vocabulary_term_id' do
        observation_matrix_row_item.controlled_vocabulary_term_id = FactoryBot.create(:valid_keyword).id
        observation_matrix_row_item.valid?
        expect(observation_matrix_row_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
      end
    end 

    context 'with a observation_matrix_row_item saved' do
      let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
      let(:otu) { FactoryBot.create(:valid_otu) }
      
      before {
        observation_matrix_row_item.observation_matrix = observation_matrix
        observation_matrix_row_item.otu = otu
        observation_matrix_row_item.save!
      }

      context 'adding an item synchronizes observation_matrix rows' do
        specify 'saving a record adds otu observation_matrix_rows' do
          expect(ObservationMatrixRow.first.otu).to eq(otu)
        end

        specify 'added observation_matrix_row has reference_count = 1' do
          expect(ObservationMatrixRow.first.reference_count).to eq 1
        end

        specify '#cached_observation_matrix_row_item_id is set for correlated observation_matrix_row' do
          expect(ObservationMatrixRow.first.cached_observation_matrix_row_item_id).to eq observation_matrix_row_item.id
        end

        specify 'destroying a record removes otu from observation_matrix_rows' do
          observation_matrix_row_item.destroy
          expect(ObservationMatrixRow.count).to eq 0
        end
      end

      specify 'otu can only be added once to observation_matrix_row_item' do
        expect(ObservationMatrixRowItem::Single::Otu.new(observation_matrix: observation_matrix, otu: otu).valid?).to be_falsey
      end
    end
  end
end
