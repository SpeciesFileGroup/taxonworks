require 'rails_helper'

RSpec.describe ObservationMatrixRowItem::TaggedRowItem, type: :model, group: :observation_matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem::TaggedRowItem.new }

  context 'validation' do
    before { observation_matrix_row_item.valid? }

    context 'association' do
      specify 'belongs_to controlled_vocabulary_term' do
        expect(observation_matrix_row_item.controlled_vocabulary_term = Keyword.new()).to be_truthy
      end
    end

    specify 'controlled_vocabulary_term_id is required' do
      expect(observation_matrix_row_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
    end

    specify 'type is MatrixRowItem::TaggedRowItem' do
      expect(observation_matrix_row_item.type).to eq('ObservationMatrixRowItem::TaggedRowItem')
    end

    context 'other possible subclass attributes are nil' do
      specify 'collection_object_id' do
        observation_matrix_row_item.collection_object_id = FactoryBot.create(:valid_collection_object).id
        observation_matrix_row_item.valid?
        expect(observation_matrix_row_item.errors.include?(:collection_object_id)).to be_truthy
      end

      specify 'otu_id' do
        observation_matrix_row_item.otu_id = FactoryBot.create(:valid_otu).id
        observation_matrix_row_item.valid?
        expect(observation_matrix_row_item.errors.include?(:otu_id)).to be_truthy
      end
    end

    context 'with a observation_matrix_row_item saved' do
      let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
      let(:keyword) { FactoryBot.create(:valid_keyword) }

      let!(:otu1) { FactoryBot.create(:valid_otu) }
      let!(:otu2) { FactoryBot.create(:valid_otu) }
      let!(:co1) { FactoryBot.create(:valid_collection_object) }

      let!(:tag1) { Tag.create(keyword: keyword, tag_object: otu1) }
      let!(:tag2) { Tag.create(keyword: keyword, tag_object: otu2) }
      let!(:tag3) { Tag.create(keyword: keyword, tag_object: co1) }

      before{
        observation_matrix_row_item.controlled_vocabulary_term = keyword
        observation_matrix_row_item.observation_matrix = observation_matrix
        observation_matrix_row_item.save!
      }

      specify '.otus' do
        expect(observation_matrix_row_item.otus).to contain_exactly(otu1, otu2)
      end

      specify '.collection_objects' do
        expect(observation_matrix_row_item.collection_objects).to contain_exactly(co1)
      end

      context 'adding an item synchronizes observation_matrix_rows' do
        specify 'saving a record adds otus observation_matrix_rows' do
          expect(ObservationMatrixRow.all.map(&:otu)).to contain_exactly(otu1, otu2, nil)
        end

        specify 'saving a record adds collection objects observation_matrix_rows' do
          expect(ObservationMatrixRow.all.map(&:collection_object)).to contain_exactly(nil, nil, co1)
        end

        specify 'added observation_matrix_rows have reference_count = 1' do
          expect(ObservationMatrixRow.all.pluck(:reference_count)).to contain_exactly(1, 1, 1)
        end

        specify 'destroying a record removes otus and collection objects from observation_matrix_rows' do
          observation_matrix_row_item.destroy 
          expect(ObservationMatrixRow.count).to eq 0
        end
      end

      context 'overlapping sets' do
        let(:other_keyword) { FactoryBot.create(:valid_keyword) }
        let!(:tag4) { Tag.create(keyword: other_keyword, tag_object: co1) }

        let!(:other_observation_matrix_row_item) { ObservationMatrixRowItem::TaggedRowItem.create!(observation_matrix: observation_matrix, controlled_vocabulary_term: other_keyword) }

        specify 'observation_matrix_row otus are still unique' do
          expect(ObservationMatrixRow.all.map(&:otu)).to contain_exactly(otu1, otu2, nil)
        end

        specify 'observation_matrix_row collection objects are still unique' do
          expect(ObservationMatrixRow.all.map(&:collection_object)).to contain_exactly(nil, nil, co1)
        end

        specify 'observation_matrix_row reference_count is incremented' do
          expect(ObservationMatrixRow.all.pluck(:reference_count)).to contain_exactly(1, 1, 2)
        end

        context 'removing a set leaves overlap from other sets' do
          before { observation_matrix_row_item.destroy }

          specify 'observation_matrix_row_item reference_count is decremented' do
            expect(ObservationMatrixRow.all.pluck(:reference_count)).to contain_exactly(1)
          end

          specify 'observation_matrix_row collection_object are left in' do
            expect(ObservationMatrixRow.all.map(&:collection_object)).to contain_exactly(co1)
          end
        end

        context 'adding another tag to an existing controlled vocabulary term' do
          let(:otu3) { FactoryBot.create(:valid_otu) }
          let(:co2) { FactoryBot.create(:valid_collection_object) }
          let!(:new_tag1) { Tag.create(keyword: other_keyword, tag_object: otu3) }
          let!(:new_tag2) { Tag.create(keyword: other_keyword, tag_object: co2) }

          specify 'otu observation_matrix_row is added' do
            expect(ObservationMatrixRow.all.map(&:otu)).to contain_exactly(otu1, otu2, nil, otu3, nil)
          end

          specify 'collection_object observation_matrix_row is added' do
            expect(ObservationMatrixRow.all.map(&:collection_object)).to contain_exactly(nil, nil, co1, nil, co2)
          end

          specify 'only added observation_matrix rows are incremented' do
            expect(ObservationMatrixRow.all.pluck(:reference_count)).to contain_exactly(1, 1, 2, 1, 1)
          end

          specify 'destroying newly created tag only decrements its own observation_matrix row' do
            new_tag1.destroy
            expect(ObservationMatrixRow.all.pluck(:reference_count)).to contain_exactly(1, 1, 2, 1)
          end
        end
      end

      specify 'keyword/controlled_vocabulary_term can only be added once to a observation_matrix_row_item' do
        expect(ObservationMatrixRowItem::TaggedRowItem.new(observation_matrix: observation_matrix, controlled_vocabulary_term: keyword).valid?).to be_falsey
      end
    end
  end 
end
