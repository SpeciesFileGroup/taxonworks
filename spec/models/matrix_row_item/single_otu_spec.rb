require 'rails_helper'

RSpec.describe MatrixRowItem::SingleOtu, type: :model, group: :matrix do
  let(:matrix_row_item) { MatrixRowItem::SingleOtu.new }

  context 'validation' do
    before { matrix_row_item.valid? }

    context 'association' do
      specify 'belongs_to otu' do
        expect(matrix_row_item.otu = Otu.new()).to be_truthy
      end
    end

    specify 'otu_id is required' do
      expect(matrix_row_item.errors.include?(:otu_id)).to be_truthy
    end

    specify 'type is "MatrixRowItem::SingleOtu"' do
      expect(matrix_row_item.type).to eq('MatrixRowItem::SingleOtu')
    end

    context 'other possible subclass attributes are nil' do
      specify 'collection_object_id' do
        matrix_row_item.collection_object_id = FactoryGirl.create(:valid_collection_object).id
        matrix_row_item.valid?
        expect(matrix_row_item.errors.include?(:collection_object_id)).to be_truthy
      end

      specify 'controlled_vocabulary_term_id' do
        matrix_row_item.controlled_vocabulary_term_id = FactoryGirl.create(:valid_keyword).id
        matrix_row_item.valid?
        expect(matrix_row_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
      end
    end 

    context 'with a matrix_row_item saved' do
      let(:matrix) { FactoryGirl.create(:valid_matrix) }
      let(:otu) { FactoryGirl.create(:valid_otu) }
      
      before {
        matrix_row_item.matrix = matrix
        matrix_row_item.otu = otu
        matrix_row_item.save!
      }

      context 'adding an item synchronizes matrix rows' do
        specify 'saving a record adds otu matrix_rows' do
          expect(MatrixRow.first.otu).to eq(otu)
        end

        specify 'added matrix_row has reference_count = 1' do
          expect(MatrixRow.first.reference_count).to eq 1
        end

        specify 'destroying a record removes otu from matrix_rows' do
          matrix_row_item.destroy
          expect(MatrixRow.count).to eq 0
        end
      end

      specify 'otu can only be added once to matrix_row_item' do
        expect(MatrixRowItem::SingleOtu.new(matrix: matrix, otu: otu).valid?).to be_falsey
      end
    end
  end
end