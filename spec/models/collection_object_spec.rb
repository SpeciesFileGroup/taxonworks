require 'rails_helper'

describe CollectionObject, :type => :model do

  let(:collection_object) {FactoryGirl.build(:collection_object) }
  let(:ranged_lot_category) {FactoryGirl.create(:valid_ranged_lot_category) }

  context 'validation' do
    specify 'type is not set when total/ranged_lot are not provided' do
      collection_object.valid?
      expect(collection_object.type).to eq(nil) 
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

    context 'both total and ranged_lot_category_id may not be present' do
      before {
        collection_object.total = 10
        collection_object.ranged_lot_category_id = 10
      }
      specify 'when a CollectionObject' do
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end 

      specify 'when a Specimen' do
        collection_object.type = 'Specimen'
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end

      specify 'when a Lot' do
        collection_object.type = 'Lot'
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end

      specify 'when a RangedLot' do
        collection_object.type = 'RangedLot'
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end
    end

    specify 'one of total or ranged_lot_category_id must be present' do
      collection_object.valid?
      expect(collection_object.errors.include?(:base)).to be_truthy
    end 

    context 'switching roles' do
      let(:s) { Specimen.create }
      let(:l) { Lot.create(total: 4) }

      specify 'a specimen when total changed to > 1 changes to a Lot' do
        s.total = 5
        s.save!
        expect(s.type).to eq('Lot')
      end
      
      specify 'a Lot when total changes to 1 changes to Specimen' do
        l.total = 1
        l.save!
        expect(l.type).to eq('Specimen')
      end

      specify 'a Lot when assigned a ranged lot and nilled total changes to RangedLot' do
        l.total = nil
        l.ranged_lot_category = ranged_lot_category
        l.save!
        expect(l.type).to eq('RangedLot')
      end

      specify 'a Specimen when assigned a ranged lot and nilled total changes to RangedLot' do
        s.total = nil
        s.ranged_lot_category = ranged_lot_category
        s.save!
        expect(s.type).to eq('RangedLot')
      end

      context 'using .update' do
        specify 'a specimen when total changed to > 1 changes to a Lot' do
          s.update(total: 5)
          expect(s.type).to eq('Lot')
        end

        specify 'a Lot when total changes to 1 changes to Specimen' do
          l.update(total: 1) 
          expect(l.type).to eq('Specimen')
        end

        specify 'a Lot when assigned a ranged lot and nilled total changes to RangedLot' do
          l.update(total: nil, ranged_lot_category: ranged_lot_category  )
          expect(l.type).to eq('RangedLot')
        end

        specify 'a Specimen when assigned a ranged lot and nilled total changes to RangedLot' do
          s.update(total: nil, ranged_lot_category: ranged_lot_category)
          expect(s.type).to eq('RangedLot')
        end


      end


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
    xspecify "destroyed? (gone, for real, never ever EVER coming back)"
    xspecify "condition (damaged/level)"

    specify '#accession_provider' do
      expect(collection_object.accession_provider = FactoryGirl.build(:valid_person)).to be_truthy
    end
    
    specify '#deaccession_recipient' do
      expect(collection_object.deaccession_recipient = FactoryGirl.build(:valid_person)).to be_truthy
    end
  end

  context 'soft validation' do

    let(:o) {Specimen.new}
    let(:p) {Person.new}
 
    context 'accession fields are missing' do
      specify 'accessioned_at is missing' do
        o.accession_provider = p
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:accessioned_at).count).to eq(1)
      end

      specify 'accession_recipient is missing' do
        o.accessioned_at = '12/12/2014'
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:base).count).to eq(1)
      end

    end

    context 'deaccession fields are missing' do
      specify 'deaccession_reason is missing' do
        o.deaccessioned_at = '12/12/2014'
        o.deaccession_recipient = p
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccession_reason).count).to eq(1)

      end
      specify 'deaccessioned_at is missing' do
        o.deaccession_reason = 'Because.'
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccessioned_at).count).to eq(1)
      end

      specify 'deaccessioned_at is missing' do
        o.deaccession_reason = 'Because.'
        o.deaccessioned_at = '12/12/2014'
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:base).count).to eq(1)
      end
    
    end
  end


  context 'concerns' do
    it_behaves_like "identifiable" 
    it_behaves_like "containable"
    it_behaves_like "notable"
    it_behaves_like "data_attributes"
    it_behaves_like "taggable"
  end
end
