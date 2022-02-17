require 'rails_helper'

RSpec.describe ObservationMatrixRowItem, type: :model, group: :observation_matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem.new }
  let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
  
  specify 'observation_matrix is required' do
    observation_matrix_row_item.valid?
    expect(observation_matrix_row_item.errors.include?(:observation_matrix)).to be_truthy
  end

  specify 'observation_object is required' do
    observation_matrix_row_item.valid?
    expect(observation_matrix_row_item.errors.include?(:observation_object)).to be_truthy
  end

  context '.batch_create' do
    let(:s1) { FactoryBot.create(:valid_specimen) } 
    let(:s2) { FactoryBot.create(:valid_specimen) } 
    let(:o1) { FactoryBot.create(:valid_otu) } 
    let(:o2) { FactoryBot.create(:valid_otu) } 

    context 'from tags' do
      let(:keyword) { FactoryBot.create(:valid_keyword) }
      let!(:t1) { Tag.create!(keyword: keyword, tag_object: s1) }  
      let!(:t2) { Tag.create!(keyword: keyword, tag_object: o1) }  
      let!(:t3) { Tag.create!(keyword: keyword, tag_object: o2) }  

      context 'not supplying klass' do
        let(:params) { { keyword_id: keyword.id, batch_type: 'tags', observation_matrix_id: observation_matrix.id } }
        before { ObservationMatrixRowItem.batch_create(params) }
        specify 'observation_matrix_row_items are created for all types' do
          expect(ObservationMatrixRowItem.count).to eq(3)
        end
      end

      context 'supplying klass' do
        let(:params) { { keyword_id: keyword.id, batch_type: 'tags', observation_matrix_id: observation_matrix.id } }

        specify 'Otu' do
          ObservationMatrixRowItem.batch_create(params.merge(klass: 'Otu'))
          expect(ObservationMatrixRowItem.count).to eq(2)
        end

        specify 'CollectionObject' do
          ObservationMatrixRowItem.batch_create(params.merge(klass: 'CollectionObject'))
          expect(ObservationMatrixRowItem.count).to eq(1)
        end
      end
    end

    context 'from pinboard' do
      let!(:p1) { PinboardItem.create!(pinned_object: s1, user_id: user_id) }
      let!(:p2) { PinboardItem.create!(pinned_object: o2, user_id: user_id) }

      let(:params) { { batch_type: 'pinboard', observation_matrix_id: observation_matrix.id, user_id: user_id, project_id: project_id } }

      context 'not supplying klass' do
        before { ObservationMatrixRowItem.batch_create(params) }
        specify 'observation_matrix_row_items are created for all types' do
          expect(ObservationMatrixRowItem.count).to eq(2)
        end
      end

      context 'supplying klass' do
        specify 'Otu' do
          ObservationMatrixRowItem.batch_create(params.merge(klass: 'Otu'))
          expect(ObservationMatrixRowItem.count).to eq(1)
        end

        specify 'CollectionObject' do
          ObservationMatrixRowItem.batch_create(params.merge(klass: 'CollectionObject'))
          expect(ObservationMatrixRowItem.count).to eq(1)
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
