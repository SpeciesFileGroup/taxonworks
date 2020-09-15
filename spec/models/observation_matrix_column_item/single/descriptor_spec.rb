require 'rails_helper'

RSpec.describe ObservationMatrixColumnItem::Single::Descriptor, type: :model, group: :observation_matrix  do
  let(:observation_matrix_column_item) { ObservationMatrixColumnItem::Single::Descriptor.new }
  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  let(:descriptor) { FactoryBot.create(:valid_descriptor) }

  context 'validation' do
    before {observation_matrix_column_item.valid?}

    context 'associations' do
      specify 'belongs_to descriptor' do
        expect(observation_matrix_column_item.descriptor = Descriptor.new()).to be_truthy
      end
    end

    specify 'descriptor is present' do
      expect(observation_matrix_column_item.errors.include?(:descriptor)).to be_truthy
    end

    context 'other possible subclass attributes are nil' do
      specify 'keyword_id' do
        observation_matrix_column_item.controlled_vocabulary_term_id =  FactoryBot.create(:valid_keyword).id 
        observation_matrix_column_item.valid?
        expect(observation_matrix_column_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy 
      end
    end

    context 'with a observation_matrix_column_item saved' do
      before do
        observation_matrix_column_item.descriptor = descriptor
        observation_matrix_column_item.observation_matrix = observation_matrix
        observation_matrix_column_item.save!
      end

      context 'adding a item syncronizes observation_matrix columns' do
        specify 'saving a record adds descriptor observation_matrix_columns' do
          expect(ObservationMatrixColumn.first.descriptor.metamorphosize).to eq(descriptor)
        end

        specify 'added observation_matrix_column has reference_count = 1' do
          expect(ObservationMatrixColumn.first.reference_count).to eq 1
        end

        specify '#cached_observation_matrix_column_item_id is set for correlated observation_matrix_column' do
          expect(ObservationMatrixColumn.first.cached_observation_matrix_column_item_id).to eq observation_matrix_column_item.id
        end

        specify 'destroying a record removes descriptor from observation_matrix_columns' do
          observation_matrix_column_item.destroy
          expect(ObservationMatrixColumn.count).to eq(0)
        end
      end

      specify 'descriptor can only be added once to observation_matrix_column_item' do
        expect(ObservationMatrixColumnItem::Single::Descriptor.new(observation_matrix: observation_matrix, descriptor: descriptor).valid?).to be_falsey
      end

    end
  end


end
