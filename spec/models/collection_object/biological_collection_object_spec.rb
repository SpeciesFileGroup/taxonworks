require 'rails_helper'
describe CollectionObject::BiologicalCollectionObject, :type => :model do

  let(:biological_collection_object) { FactoryGirl.build(:collection_object_biological_collection_object) }

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biological_collection_object.biocuration_classifications << BiocurationClassification.new()).to be_truthy
      end

      specify 'biocuration_classes' do
        expect(biological_collection_object.biocuration_classes << BiocurationClass.new()).to be_truthy
      end

      specify 'taxon_determinations' do
        expect(biological_collection_object.taxon_determinations << TaxonDetermination.new()).to be_truthy
      end

      specify 'otus' do
        expect(biological_collection_object.otus << Otu.new()).to be_truthy
      end
    end
  end

  context 'validation' do 
    specify 'subclass is properly assigned when total is 1' do
      biological_collection_object.total = 1
      biological_collection_object.save!
      expect(biological_collection_object.type).to eq('Specimen')
    end
    
    specify 'subclass is properly assigned when total is > 1' do
      biological_collection_object.total = 5
      biological_collection_object.save!
      expect(biological_collection_object.type).to eq('Lot')
    end
  end

  context 'use' do

    context 'with a saved off OTU' do
      specify 'create and also create otus, and determinations (nested_attributes_for :otus)' do
        o = Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}])
        expect(o.save).to be_truthy
        o.reload
        expect(o.otus.count).to eq(2)
        expect(o.taxon_determinations.count).to eq(2)
      end
    end

    specify '#reorder_determinations_by(:year)' do
      expect(biological_collection_object).to respond_to(:reorder_determinations_by)
      o = Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}, {name: 'three'}])
      
      expect(o.save).to be_truthy

      o.taxon_determinations.first.update(year_made: 1920)
      o.taxon_determinations.last.update(year_made:  1980)

      expect(o.reorder_determinations_by()).to be_truthy
      o.reload
      y = Time.now.year.to_i
      expect(o.taxon_determinations.map(&:year_made)).to eq([1920, 1980, y])
      expect(o.current_determination.year_made).to eq(y)
    end
  end

  context 'instance methods' do

    specify '#current_determination' do
      expect(biological_collection_object).to respond_to(:current_determination)
      o = Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}])
      expect(o.save).to be_truthy
      expect(o.current_determination.otu.name).to eq('two')
    end
  end

  context 'soft validation' do
    specify 'determination is missing' do
      o = Specimen.new
      expect(o.save).to be_truthy
      o.soft_validate(:missing_determination)
      expect(o.soft_validations.messages_on(:base).count).to eq(1)
      o.update(otus_attributes: [{name: 'name'}])
      expect(o.save).to be_truthy
      o.soft_validate(:missing_determination)
      expect(o.soft_validations.messages_on(:base).count).to eq(0)
    end

    specify 'collecting_event and preparation_type are missing' do
      o = Specimen.new
      o.soft_validate(:missing_collecting_event)
      expect(o.soft_validations.messages_on(:collecting_event_id).count).to eq(1)
      o.soft_validate(:missing_preparation_type)
      expect(o.soft_validations.messages_on(:preparation_type_id).count).to eq(1)
      o.soft_validate(:missing_repository)
      expect(o.soft_validations.messages_on(:repository_id).count).to eq(1)
    end
  end

end
