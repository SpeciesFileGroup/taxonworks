require 'rails_helper'

RSpec.describe ObservationMatrix, type: :model, group: :matrix do
  let(:observation_matrix) { ObservationMatrix.new }
  let(:otu) { Otu.create!(name: 'Matix') }
  let(:descriptor) { Descriptor::Working.create!(name: 'working') }
  let(:collection_object) { Specimen.create! }

  context 'associations' do 
    context 'has_many' do
      specify '#observation_matrix_column_items' do
        expect(observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem.new).to be_truthy
      end

      specify '#observation_matrix_row_items' do
        expect(observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem.new).to be_truthy
      end
    end
  end

  context :validation do
    before { observation_matrix.valid? }
    specify '#name is required' do
      expect(observation_matrix.errors.include?(:name)).to be_truthy
    end
  end

  context '<<' do
    before do
      observation_matrix.name = 'Test'
      observation_matrix.save!
    end

    specify 'cascade creates rows from items 1' do
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleOtu.new(otu: otu) 
      expect(observation_matrix.observation_matrix_rows.count).to eq(1)
    end

    specify 'cascade creates rows from items 2' do
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleCollectionObject.new(collection_object: collection_object) 
      expect(observation_matrix.observation_matrix_rows.count).to eq(1)
    end

    specify 'cascade creates columns from items 1' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor) 
      expect(observation_matrix.observation_matrix_columns.count).to eq(1)
    end

  end


end
