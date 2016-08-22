require 'rails_helper'

RSpec.describe MatrixColumnItem::TaggedDescriptor, type: :model, group: :matrix  do
  let(:matrix_column_item) { MatrixColumnItem::TaggedDescriptor.new }
  let(:matrix) { FactoryGirl.create(:valid_matrix) }
  let(:keyword) { FactoryGirl.create(:valid_keyword) }

  context 'validation' do
    before {matrix_column_item.valid?}

    context 'associations' do
      specify 'belongs_to descriptor' do
        expect(matrix_column_item.controlled_vocabulary_term = Keyword.new()).to be_truthy
      end
    end

    specify 'controlled_vocabulary_term_id is present' do
      expect(matrix_column_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
    end

    specify 'type is "MatrixColumnItem::TaggedDescriptor"' do
      expect(matrix_column_item.type).to eq('MatrixColumnItem::TaggedDescriptor')
    end

    context 'other possible subclass attributes are nil' do
      specify 'descriptor_id' do
        matrix_column_item.descriptor_id =  FactoryGirl.create(:valid_descriptor).id 
        matrix_column_item.valid?
        expect(matrix_column_item.errors.include?(:descriptor_id)).to be_truthy 
      end
    end

    context 'with a matrix_column_item saved' do
      let!(:descriptor1) { FactoryGirl.create(:valid_descriptor) } 
      let!(:descriptor2) { FactoryGirl.create(:valid_descriptor) } 
      let!(:descriptor3) { FactoryGirl.create(:valid_descriptor) } 

      let!(:tag1) { Tag.create(keyword: keyword, tag_object: descriptor1) }
      let!(:tag2) { Tag.create(keyword: keyword, tag_object: descriptor2) }
      let!(:tag3) { Tag.create(keyword: keyword, tag_object: descriptor3) }

      before {
        matrix_column_item.controlled_vocabulary_term = keyword
        matrix_column_item.matrix = matrix
        matrix_column_item.save!
      }

      specify '.descriptors' do
        expect(matrix_column_item.descriptors.map(&:metamorphosize)).to contain_exactly(descriptor1, descriptor2, descriptor3)
      end

      context 'adding a item syncronizes matrix columns' do
        specify 'saving a record adds descriptor matrix_columns' do
          expect(MatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly( descriptor1, descriptor2, descriptor3) 
        end

        specify 'added matrix_columns have reference_count = 1' do
          expect(MatrixColumn.all.pluck(:reference_count)).to contain_exactly(1,1,1)
        end

        specify 'destroying a record removes descriptor from matrix_columns' do
          matrix_column_item.destroy
          expect(MatrixColumn.count).to eq(0)
        end
      end


      context 'overlapping sets' do
        let(:other_keyword) { FactoryGirl.create(:valid_keyword) }
        let!(:tag4) { Tag.create(keyword: other_keyword, tag_object: descriptor3) }

        let!(:other_matrix_column_item) { MatrixColumnItem::TaggedDescriptor.create!(matrix: matrix, controlled_vocabulary_term: other_keyword) }

        specify 'matrix_column descriptors are still unique' do
          expect(MatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly( descriptor1, descriptor2, descriptor3) 
        end

        specify 'matrix_column reference_count is incremented' do
          expect(MatrixColumn.all.pluck(:reference_count)).to contain_exactly(1,1,2)
        end

        context 'removing a set leaves overlap from other sets' do
          before { matrix_column_item.destroy }

          specify 'matrix_column reference_count is decremented' do
            expect(MatrixColumn.all.pluck(:reference_count)).to contain_exactly(1)
          end

          specify 'matrix_column descriptor are left in' do
            expect(MatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly( descriptor3 ) 
          end
        end

        context 'adding another tag to an existing cvt' do
          let(:descriptor4) { FactoryGirl.create(:valid_descriptor) }
          let!(:new_tag) { Tag.create(keyword: other_keyword, tag_object: descriptor4) }

          specify 'matrix column is added' do
            expect(MatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly( descriptor1, descriptor2, descriptor3, descriptor4) 
          end

          specify 'only added matrix column is incremented' do
            expect(MatrixColumn.all.pluck(:reference_count)).to contain_exactly(1, 1, 2, 1)
          end

          specify 'destroying newly created tag only decrements its own matrix column' do
            new_tag.destroy
            expect(MatrixColumn.all.pluck(:reference_count)).to contain_exactly(1, 1, 2)
          end
        end
      end

      specify 'keyword/controlled vocabulary term can only be added once to matrix_column_item' do
        expect(MatrixColumnItem::TaggedDescriptor.new(matrix: matrix, controlled_vocabulary_term: keyword).valid?).to be_falsey
      end

    end
  end
end
