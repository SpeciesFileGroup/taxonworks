require 'rails_helper'
describe CollectionObject::BiologicalCollectionObject, type: :model, group: :collection_objects do

  let(:biological_collection_object) { FactoryGirl.build(:collection_object_biological_collection_object) }

  specify '.valid_new_object_classes' do
    expect(CollectionObject::BiologicalCollectionObject.valid_new_object_classes).to contain_exactly('Extract', 'CollectionObject::BiologicalCollectionObject')
  end

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
      expect(o.taxon_determinations.order('taxon_determinations.position').map(&:year_made)).to eq([y, 1980, 1920])
      expect(o.current_taxon_determination.year_made).to eq(y)
    end
  end

  context 'instance methods' do
    let(:o) { Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}]) }
    before { o.save }

    # expected behaviour is that the last determination created is the first on the list
    specify '#current_taxon_determination' do
      expect(o.current_taxon_determination.reload.position).to eq(1)
    end

    specify '#current_otu' do
      expect(o.current_otu.reload.name).to eq('two')
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

  context 'nested attributes' do
    let(:o) { Specimen.new }
    let(:otu) { Otu.create!(name: 'Zeezaw whee') }

    context 'taxon_determinations' do
      before {
        o.taxon_determinations_attributes = [ {otu_id: otu.id } ]
      }

      specify 'can be created' do
        expect(o.save).to be_truthy
        expect(o.taxon_determinations.first.valid?).to be_truthy
      end

      specify 'can be destroyed' do
        expect(o.save).to be_truthy
        o.update(taxon_determinations_attributes: [{id: o.taxon_determinations.first.id, _destroy: '1'}])
        expect(o.save).to be_truthy
        expect(TaxonDetermination.all.size).to eq(0)
      end
    end
  end
end
