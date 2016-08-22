require 'rails_helper'

RSpec.describe MatrixRowItem::TaggedRowItem, type: :model, group: :matrix do
  let(:matrix_row_item) { MatrixRowItem::TaggedRowItem.new }

  context 'validation' do
    before { matrix_row_item.valid? }

    context 'association' do
      specify 'belongs_to controlled_vocabulary_term' do
        expect(matrix_row_item.controlled_vocabulary_term = Keyword.new()).to be_truthy
      end
    end

    specify 'controlled_vocabulary_term_id is required' do
      expect(matrix_row_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
    end

    specify 'type is MatrixRowItem::TaggedRowItem' do
      expect(matrix_row_item.type).to eq('MatrixRowItem::TaggedRowItem')
    end

    context 'other possible subclass attributes are nil' do
      specify 'collection_object_id' do
        matrix_row_item.collection_object_id = FactoryGirl.create(:valid_collection_object).id
        matrix_row_item.valid?
        expect(matrix_row_item.errors.include?(:collection_object_id)).to be_truthy
      end

      specify 'otu_id' do
        matrix_row_item.otu_id = FactoryGirl.create(:valid_otu).id
        matrix_row_item.valid?
        expect(matrix_row_item.errors.include?(:otu_id)).to be_truthy
      end
    end

    context 'with a matrix_row_item saved' do
      let(:matrix) { FactoryGirl.create(:valid_matrix) }
      let(:keyword) { FactoryGirl.create(:valid_keyword) }

      let!(:otu1) { FactoryGirl.create(:valid_otu) }
      let!(:otu2) { FactoryGirl.create(:valid_otu) }
      let!(:co1) { FactoryGirl.create(:valid_collection_object) }

      let!(:tag1) { Tag.create(keyword: keyword, tag_object: otu1) }
      let!(:tag2) { Tag.create(keyword: keyword, tag_object: otu2) }
      let!(:tag3) { Tag.create(keyword: keyword, tag_object: co1) }

      before{
        matrix_row_item.controlled_vocabulary_term = keyword
        matrix_row_item.matrix = matrix
        matrix_row_item.save!
      }

      specify '.otus' do
        expect(matrix_row_item.otus).to contain_exactly(otu1, otu2)
      end

      specify '.collection_objects' do
        expect(matrix_row_item.collection_objects.map(&:metamorphosize)).to contain_exactly(co1)
      end

      context 'adding an item synchronizes matrix_rows' do
        specify 'saving a record adds otus matrix_rows' do
          expect(MatrixRow.all.map(&:otu)).to contain_exactly(otu1, otu2, nil)
        end

        specify 'saving a record adds collection objects matrix_rows' do
          expect(MatrixRow.all.map(&:collection_object).map do |o| o.metamorphosize if !o.nil? end).to contain_exactly(nil, nil, co1)
        end

        specify 'added matrix_rows have reference_count = 1' do
          expect(MatrixRow.all.pluck(:reference_count)).to contain_exactly(1, 1, 1)
        end

        specify 'destroying a record removes otus and collection objects from matrix_rows' do
          matrix_row_item.destroy 
          expect(MatrixRow.count).to eq 0
        end
      end

      context 'overlapping sets' do
        let(:other_keyword) { FactoryGirl.create(:valid_keyword) }
        let!(:tag4) { Tag.create(keyword: other_keyword, tag_object: co1) }

        let!(:other_matrix_row_item) { MatrixRowItem::TaggedRowItem.create!(matrix: matrix, controlled_vocabulary_term: other_keyword) }

        specify 'matrix_row otus are still unique' do
          expect(MatrixRow.all.map(&:otu)).to contain_exactly(otu1, otu2, nil)
        end

        specify 'matrix_row collection objects are still unique' do
          expect(MatrixRow.all.map(&:collection_object).map do |o| o.metamorphosize if !o.nil? end).to contain_exactly(nil, nil, co1)
        end

        specify 'matrix_row reference_count is incremented' do
          expect(MatrixRow.all.pluck(:reference_count)).to contain_exactly(1, 1, 2)
        end

        context 'removing a set leaves overlap from other sets' do
          before { matrix_row_item.destroy }

          specify 'matrix_row_item reference_count is decremented' do
            expect(MatrixRow.all.pluck(:reference_count)).to contain_exactly(1)
          end

          specify 'matrix_row collection_object are left in' do
            expect(MatrixRow.all.map(&:collection_object).map(&:metamorphosize)).to contain_exactly(co1)
          end
        end

        context 'adding another tag to an existing controlled vocabulary term' do
          let(:otu3) { FactoryGirl.create(:valid_otu) }
          let(:co2) { FactoryGirl.create(:valid_collection_object) }

          before {
            Tag.create(keyword: other_keyword, tag_object: otu3)
            Tag.create(keyword: other_keyword, tag_object: co2)
          }

          specify 'otu matrix_row is added' do
            expect(MatrixRow.all.map(&:otu)).to contain_exactly(otu1, otu2, nil, otu3, nil)
          end

          specify 'collection_object matrix_row is added' do
            expect(MatrixRow.all.map(&:collection_object).map do |o| o.metamorphosize if !o.nil? end).to contain_exactly(nil, nil, co1, nil, co2)
          end
        end
      end

      specify 'keyword/controlled_vocabulary_term can only be added once to a matrix_row_item' do
        expect(MatrixRowItem::TaggedRowItem.new(matrix: matrix, controlled_vocabulary_term: keyword).valid?).to be_falsey
      end
    end
  end 
end