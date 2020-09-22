require 'rails_helper'

RSpec.describe ObservationMatrixColumnItem, type: :model, group: :observation_matrix do
  let(:matrix_column_item) { ObservationMatrixColumnItem.new }
  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }

  specify 'observation_matrix is required' do
    matrix_column_item.valid?
    expect(matrix_column_item.errors.include?(:observation_matrix)).to be_truthy
  end

  # TODO: check for STI raise

  context 'subclass STI' do
    MATRIX_COLUMN_ITEM_TYPES.each_key do |k|
      context k do
        let(:klass) { k.constantize }

        specify '.subclass_attributes is defined' do
          expect(klass.respond_to?(:subclass_attributes)).to be_truthy
        end

        specify '.subclass_attributes is populated' do
          expect(klass.subclass_attributes.size).to be > 0
        end

        specify '.subclass_attributes are present in ALL_STI_ATTRIBUTES' do
          expect((klass.subclass_attributes - ObservationMatrixColumnItem::ALL_STI_ATTRIBUTES).size).to be 0
        end

        context "#descriptors" do
          let(:i) { klass.new }

          specify 'method is present' do
            expect(i.respond_to?(:descriptors)).to be_truthy
          end

          specify 'returns Array' do
            expect(i.descriptors.class.name).to eq 'Array'
          end
        end
      end
    end
  end

  context '.create' do
    let(:d1) { FactoryBot.create(:valid_descriptor_continuous) } 
    let(:d2) { FactoryBot.create(:valid_descriptor_sample) }
    let(:d3) { FactoryBot.create(:valid_descriptor_working) }

    specify 'singly' do
      expect(ObservationMatrixColumnItem.create!(descriptor: d1, observation_matrix: observation_matrix, type: 'ObservationMatrixColumnItem::Single::Descriptor')).to be_truthy
    end

    context '.batch_create' do
      context 'from tags' do
        let(:keyword) { FactoryBot.create(:valid_keyword) }
        let!(:t1) { Tag.create!(keyword: keyword, tag_object: d1) }
        let!(:t2) { Tag.create!(keyword: keyword, tag_object: d2) }
        let!(:t3) { Tag.create!(keyword: keyword, tag_object: d3) }

        context 'not supplying klass' do
          let(:params) { { keyword_id: keyword.id, batch_type: 'tags', observation_matrix_id: observation_matrix.id } }
          before { ObservationMatrixColumnItem.batch_create(params) }

          specify 'observation_matrix_column_items are created for all types' do
            expect(ObservationMatrixColumnItem.count).to eq(3)
          end
        end

        context 'supplying klass' do
          let(:params) { { keyword_id: keyword.id, batch_type: 'tags', observation_matrix_id: observation_matrix.id } }

          specify 'Descriptor::Working' do
            ObservationMatrixColumnItem.batch_create(params.merge(klass: 'Descriptor::Working'))
            expect(ObservationMatrixColumnItem.count).to eq(1)
          end

          specify 'Descriptor::Continuous' do
            ObservationMatrixColumnItem.batch_create(params.merge(klass: 'Descriptor::Continuous'))
            expect(ObservationMatrixColumnItem.count).to eq(1)
          end
        end
      end

      context 'from pinboard' do
        let!(:p1) { PinboardItem.create!(pinned_object: d1, user_id: user_id) }
        let!(:p2) { PinboardItem.create!(pinned_object: d3, user_id: user_id) }

        let(:params) { { batch_type: 'pinboard', observation_matrix_id: observation_matrix.id, user_id: user_id, project_id: project_id } }

        context 'not supplying klass' do
          before { ObservationMatrixColumnItem.batch_create(params) }
          specify 'observation_matrix_column_items are created for all types' do
            expect(ObservationMatrixColumnItem.count).to eq(2)
          end
        end

        context 'supplying klass' do
          specify 'Descriptor:Continuous' do
            ObservationMatrixColumnItem.batch_create(params.merge(klass: 'Descriptor::Continuous'))
            expect(ObservationMatrixColumnItem.count).to eq(1)
          end

          specify 'Descriptor::Working' do
            ObservationMatrixColumnItem.batch_create(params.merge(klass: 'Descriptor::Working'))
            expect(ObservationMatrixColumnItem.count).to eq(1)
          end
        end
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'is_data'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
  end

end
