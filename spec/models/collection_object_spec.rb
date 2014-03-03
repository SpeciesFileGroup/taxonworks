require 'spec_helper'

describe CollectionObject do

  let(:collection_object) {FactoryGirl.build(:collection_object) }

  context 'validation' do
    specify 'require type' do
      collection_object.valid?
      expect(collection_object.errors.include?(:type)).to be_true
    end
 
    specify 'both total and ranged_lot_category_id can not be present' do
      collection_object.total = 10
      collection_object.ranged_lot_category_id = 10
      expect(collection_object.valid?).to be_false
      expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_true
    end 
  end

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
      expect(collection_object).to respond_to(:buffered_determinations)
    end

    specify 'buffered_other_labels' do
      expect(collection_object).to respond_to(:buffered_other_labels)
    end
  end

  context 'concerns' do
    it_behaves_like "identifiable"
    it_behaves_like "containable"
    it_behaves_like "notable"
  end

end
