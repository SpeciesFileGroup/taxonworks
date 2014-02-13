require 'spec_helper'

describe CollectionObject do

  let(:collection_object) {FactoryGirl.build(:collection_object) }

  context 'associations' do
    context 'belongs_to' do
      specify 'preparation_type' do
        expect(collection_object).to respond_to(:preparation_type)
      end

      specify 'repository' do
        expect(collection_object).to respond_to(:repository)
      end
    end
  end

  context 'incoming data can be stored in buffers' do
    specify 'buffered_collecting_event' do
      expect(collection_object).to respond_to(:buffered_collecting_event) 
    end

    specify 'buffered_determination' do
      expect(collection_object).to respond_to(:buffered_determination)
    end

    specify 'buffered_other_labels' do
      expect(collection_object).to respond_to(:buffered_other_labels)
    end
  end

  context 'concerns' do
    it_behaves_like "identifiable"
    it_behaves_like "containable"
  end

end
