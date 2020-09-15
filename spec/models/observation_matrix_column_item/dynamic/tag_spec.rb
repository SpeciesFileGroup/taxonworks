require 'rails_helper'

RSpec.describe ObservationMatrixColumnItem::Dynamic::Tag, type: :model, group: :observation_matrix  do
  let(:observation_matrix_column_item) { ObservationMatrixColumnItem::Dynamic::Tag.new }
  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  let(:keyword) { FactoryBot.create(:valid_keyword) }

  context 'validation' do
    before {observation_matrix_column_item.valid?}

    specify 'belongs_to :descriptor' do
      expect(observation_matrix_column_item.controlled_vocabulary_term = Keyword.new).to be_truthy
    end

    specify '#controlled_vocabulary_term_id is required' do
      expect(observation_matrix_column_item.errors.include?(:controlled_vocabulary_term_id)).to be_truthy
    end

    specify 'other possible subclass attributes are nil (descriptor_id)' do
      observation_matrix_column_item.descriptor_id = FactoryBot.create(:valid_descriptor).id 
      observation_matrix_column_item.valid?
      expect(observation_matrix_column_item.errors.include?(:descriptor_id)).to be_truthy 
    end
  end

  specify 'with a item created, tagging adds row' do
    observation_matrix_column_item.update!( controlled_vocabulary_term: keyword, observation_matrix: observation_matrix)
    Tag.create!(keyword: keyword, tag_object: FactoryBot.create(:valid_descriptor))
    expect(ObservationMatrixColumn.count).to eq(1)
  end

  context 'with a observation_matrix_column_item saved' do
    let!(:descriptor1) { FactoryBot.create(:valid_descriptor) } 
    let!(:descriptor2) { FactoryBot.create(:valid_descriptor) } 
    let!(:descriptor3) { FactoryBot.create(:valid_descriptor) } 

    let!(:tag1) { Tag.create!(keyword: keyword, tag_object: descriptor1) }
    let!(:tag2) { Tag.create!(keyword: keyword, tag_object: descriptor2) }
    let!(:tag3) { Tag.create!(keyword: keyword, tag_object: descriptor3) }

    before { observation_matrix_column_item.update!( controlled_vocabulary_term: keyword, observation_matrix: observation_matrix)}

    specify '#descriptors' do
      expect(observation_matrix_column_item.descriptors.map(&:metamorphosize)).to contain_exactly(descriptor1, descriptor2, descriptor3)
    end

    context 'adding a item syncronizes observation_matrix columns' do
      specify 'saving a record adds descriptor observation_matrix_columns' do
        expect(ObservationMatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly(descriptor1, descriptor2, descriptor3)
      end

      specify 'added observation_matrix_columns have reference_count = 1' do
        expect(ObservationMatrixColumn.all.pluck(:reference_count)).to contain_exactly(1, 1, 1)
      end

      specify 'destroying a record removes descriptor from observation_matrix_columns' do
        observation_matrix_column_item.destroy
        expect(ObservationMatrixColumn.count).to eq(0)
      end
    end

    context 'overlapping single item' do
      let!(:other_observation_matrix_column_item) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: observation_matrix, descriptor: descriptor1) }
      let(:observation_matrix_column) { ObservationMatrixColumn.where(observation_matrix: observation_matrix, descriptor: descriptor1).first} 

      specify 'count is incremented' do
        expect(observation_matrix_column.reference_count).to eq(2)
      end

      specify 'cached_observation_matrix_column_item_id is returned' do
        expect(observation_matrix_column.cached_observation_matrix_column_item_id).to eq(other_observation_matrix_column_item.id)
      end

      context 'overlap (tag) is removed' do
        before { observation_matrix_column_item.destroy! }

        specify 'count is decremented' do
          expect(observation_matrix_column.reference_count).to eq(1)
        end

        specify 'cached_observation_matrix_column_item_id remains' do
          expect(observation_matrix_column.cached_observation_matrix_column_item_id).to eq(other_observation_matrix_column_item.id)
        end
      end 
    end

    context 'overlapping sets' do
      let(:other_keyword) { FactoryBot.create(:valid_keyword) }
      let!(:tag4) { Tag.create!(keyword: other_keyword, tag_object: descriptor3) }

      let!(:other_observation_matrix_column_item) { ObservationMatrixColumnItem::Dynamic::Tag.create!(observation_matrix: observation_matrix, controlled_vocabulary_term: other_keyword) }

      specify 'observation_matrix_column descriptors are still unique' do
        expect(ObservationMatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly(descriptor1, descriptor2, descriptor3)
      end

      specify 'observation_matrix_column reference_count is incremented' do
        expect(ObservationMatrixColumn.all.pluck(:reference_count)).to contain_exactly(1, 1, 2)
      end

      context 'removing a set leaves overlap from other sets' do
        before { observation_matrix_column_item.destroy }

        specify 'observation_matrix_column reference_count is decremented' do
          expect(ObservationMatrixColumn.all.pluck(:reference_count)).to contain_exactly(1)
        end

        specify 'observation_matrix_column descriptor are left in' do
          expect(ObservationMatrixColumn.all.map(&:descriptor).map(&:metamorphosize)).to contain_exactly(descriptor3 )
        end
      end

      context 'adding another tag to an existing cvt' do
        let!(:descriptor4) { FactoryBot.create(:valid_descriptor) }

       let!(:new_tag) { Tag.create!(keyword: other_keyword, tag_object: descriptor4) }

        specify 'observation_matrix column is added' do
          expect(ObservationMatrixColumn.all.map(&:descriptor_id)).to contain_exactly(descriptor1.id, descriptor2.id, descriptor3.id, descriptor4.id)
        end

        specify 'only added observation_matrix column is incremented' do
          expect(ObservationMatrixColumn.all.pluck(:reference_count)).to contain_exactly(1, 1, 2, 1)
        end

        specify 'destroying newly created tag only decrements its own observation_matrix column' do
          new_tag.destroy
          expect(ObservationMatrixColumn.all.pluck(:reference_count)).to contain_exactly(1, 1, 2)
        end
      end
    end

    specify 'keyword/controlled vocabulary term can only be added once to observation_matrix_column_item' do
      expect(ObservationMatrixColumnItem::Dynamic::Tag.new(observation_matrix: observation_matrix, controlled_vocabulary_term: keyword).valid?).to be_falsey
    end

  end
end
