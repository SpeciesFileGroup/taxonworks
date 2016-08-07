require 'rails_helper'

RSpec.describe MatrixColumnItem::SingleDescriptor, type: :model, group: :matrix  do
  let(:matrix_column_item) { MatrixColumnItem::SingleDescriptor.new }
  let(:matrix) { FactoryGirl.create(:valid_matrix) }
  let(:descriptor) { FactoryGirl.create(:valid_descriptor) }

  context 'validation' do
    before {matrix_column_item.valid?}

    context 'associations' do
      specify 'belongs_to descriptor' do
        expect(matrix_column_item.descriptor = Descriptor.new()).to be_truthy
      end
    end

    specify 'descriptor_id is present' do
      expect(matrix_column_item.errors.include?(:descriptor_id)).to be_truthy
    end

    specify 'type is "MatrixColumnItem::SingleDescriptor"' do
      expect(matrix_column_item.type).to eq('MatrixColumnItem::SingleDescriptor')
    end

    context 'other possible subclass attributes are nil' do
      specify 'keyword_id' do
        matrix_column_item.controlled_vocabulary_term_id =  FactoryGirl.create(:valid_keyword).id 
        matrix_column_item.valid?
        expect(matrix_column_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy 
      end
      # ... other checks are possible as addition subclasses created      
    end

    context 'with a matrix_column_item saved' do

      before {
        matrix_column_item.descriptor = descriptor
        matrix_column_item.matrix = matrix
        matrix_column_item.save!
      }

      context 'adding a item syncronizes matrix columns' do

        specify 'saving a record adds descriptor matrix_columns' do
          expect(MatrixColumn.first.descriptor.metamorphosize).to eq(descriptor) 
        end

        specify 'added matrix_column has reference_count = 1' do
          expect(MatrixColumn.first.reference_count).to eq 1 
        end

        specify 'destroying a record removes descriptor from matrix_columns' do
          matrix_column_item.destroy
          expect(MatrixColumn.count).to eq(0)
        end
      end

      specify 'descriptor can only be added once to matrix_column_item' do
        expect(MatrixColumnItem::SingleDescriptor.new(matrix: matrix, descriptor: descriptor).valid?).to be_falsey
      end

    end
  end


end
