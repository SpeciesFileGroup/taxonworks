require 'rails_helper'

describe CollectionObject, :type => :model do

  let(:collection_object) {FactoryGirl.build(:collection_object) }

  context 'validation' do
    specify 'type is set to a biological_collection_object when not provided' do
      collection_object.valid?
      expect(collection_object.type).to eq('CollectionObject::BiologicalCollectionObject') 
    end

    specify 'type is set to Specimen when type not provided but total is one' do
      collection_object.total = 1
      collection_object.valid?
      expect(collection_object.type).to eq('Specimen') 
    end

    specify 'type is set to Lot when type not provided but total is > 1' do
      collection_object.total = 5
      collection_object.valid?
      expect(collection_object.type).to eq('Lot') 
    end

    specify 'type is set to RangedLot when type not provided but ranged_lot_id is' do
      collection_object.ranged_lot_category = FactoryGirl.create(:valid_ranged_lot_category) 
      collection_object.valid?
      expect(collection_object.type).to eq('RangedLot') 
    end

    specify 'both total and ranged_lot_category_id can not be present' do
      collection_object.total = 10
      collection_object.ranged_lot_category_id = 10
      expect(collection_object.valid?).to be_falsey
      expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
    end 

    specify 'one of total or ranged_lot_category_id must be present' do
      collection_object.valid?
      expect(collection_object.errors.include?(:base)).to be_truthy
    end 

  end

  context 'associations' do
    context 'belongs_to' do
      specify 'preparation_type' do
        expect(collection_object.preparation_type = FactoryGirl.create(:valid_preparation_type)).to be_truthy
      end

      specify 'repository' do
        expect(collection_object.repository = FactoryGirl.create(:valid_repository) ).to be_truthy 
      end

      specify 'collecting_event' do
        expect(collection_object.collecting_event = FactoryGirl.create(:valid_collecting_event)).to be_truthy
      end

      specify 'ranged_lot_category' do
        expect(collection_object.ranged_lot_category = FactoryGirl.create(:valid_ranged_lot_category)).to be_truthy
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

  context 'attributes' do
    specify "current_location (the present location [time axis])" 
    specify "disposition ()"  # was boolean lost or not
    specify "destroyed? (gone, for real, never ever EVER coming back)"
    specify "condition (damaged/level)"
    specify "accession source (from whom the biological_collection_object came)"
    specify "deaccession recipient (to whom the biological_collection_object went)"
    specify "depository (where the)"  
  end

  context 'soft validation' do
    context 'accession fields are missing' do
      specify 'accessioned_at is missing' do
        o = Specimen.new(accession_provider_id: 1)
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:accessioned_at).count).to eq(1)
      end
      specify 'accession_recipient_id is missing' do
        o = Specimen.new(accessioned_at: '2014-06-02')
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:accession_provider_id).count).to eq(1)
      end
    end
    context 'deaccession fields are missing' do
      specify 'deaccessioned_at and deaccession_reason are missing' do
        o = Specimen.new(deaccession_recipient_id: 1)
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccession_at).count).to eq(1)
        expect(o.soft_validations.messages_on(:deaccession_reason).count).to eq(1)
      end
      specify 'deaccessioned_at and deaccession_reason are missing' do
        o = Specimen.new(deaccession_reason: 'gift')
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccession_at).count).to eq(1)
        expect(o.soft_validations.messages_on(:deaccession_recipient_id).count).to eq(1)
      end
    end
  end


  context 'concerns' do
    it_behaves_like "identifiable" 
    it_behaves_like "containable"
    it_behaves_like "notable"
    it_behaves_like "data_attributes"
    it_behaves_like "taggable"

    specify "locatable (location)"
    specify "figurable (images)"
  end
end
