require 'rails_helper'
describe CollectionObject::BiologicalCollectionObject, type: :model, group: :collection_objects do

  let(:biological_collection_object) { CollectionObject::BiologicalCollectionObject.new }
  let(:otu) {Otu.create(name: 'zzz')}

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biological_collection_object.biocuration_classifications.push BiocurationClassification.new()).to be_truthy
      end

      specify 'biocuration_classes' do
        expect(biological_collection_object.biocuration_classes.push BiocurationClass.new()).to be_truthy
      end

      specify 'taxon_determinations' do
        expect(biological_collection_object.taxon_determinations.push TaxonDetermination.new()).to be_truthy
      end

      specify 'otus' do
        expect(biological_collection_object.otus.push Otu.new()).to be_truthy
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

  context 'dependencies' do
    let(:descriptor) { Descriptor::Continuous.create!(name: 'Count') }

    before { biological_collection_object.update(total: 1) }

    specify '#taxon_determinations are destroyed' do
      d = TaxonDetermination.create!(biological_collection_object: biological_collection_object, otu: otu)
      biological_collection_object.destroy
      expect(TaxonDetermination.where(id: d.id).any?).to be_falsey
    end 

    specify '#biocuration_classifications are destroyed' do
      b = FactoryBot.create(:valid_biocuration_class)
      d = BiocurationClassification.create!(biological_collection_object: biological_collection_object, biocuration_class: b) 
      biological_collection_object.destroy
      expect(BiocurationClassification.where(id: d.id).any?).to be_falsey
    end 

    specify '#observations prevent destruction' do
      o = Observation::Continuous.create!(observation_object_global_id: biological_collection_object.to_global_id.to_s, continuous_value: 22, descriptor: descriptor)
      expect(biological_collection_object.destroy).to be_falsey
      expect(biological_collection_object.errors.include?(:base)).to be_truthy
    end


  end

  context 'nested attributes' do

    let(:s) {Specimen.create!(otus_attributes: [{name: 'one'}, {name: 'two'}])}
    let(:t) {Specimen.create!(taxon_determinations_attributes: [{otu: Otu.create(name: 'abc')}, {otu_id: otu.id}])}

    context 'via otus_attributes' do
      specify 'creates otus' do
        expect(s.otus.count).to eq(2)
      end

      specify 'creates taxon_determinations' do
        expect(s.taxon_determinations.count).to eq(2)
      end
    end

    context 'via taxon_determinations_attributes' do
      specify 'creates otus' do
        expect(t.otus.count).to eq(2)
      end

      specify 'creates taxon_determinations' do
        expect(s.taxon_determinations.count).to eq(2)
      end
    end

    specify 'can be destroyed' do
      s.update(taxon_determinations_attributes: [{id: s.taxon_determinations.first.id, _destroy: '1'}])
      s.save
      expect(s.taxon_determinations.reload.count).to eq(1)
    end
  end

  context 'ordering deteriminations' do
    let!(:o) {
      Specimen.create!(total: 1, otus_attributes: [{name: 'one'}, {name: 'two'}, {name: 'three'}])
    }

    specify '#current_taxon_determination, last created, first on list by default' do
      expect(o.current_taxon_determination.reload.position).to eq(1)
    end

    specify '#current_otu (is last created)' do
      expect(o.current_otu.reload.name).to eq('three')
    end

    specify '#reorder_determinations_by(:year)' do
      expect(biological_collection_object).to respond_to(:reorder_determinations_by)
    end

    specify '#reorder_determinations()' do
      expect(o.reorder_determinations_by()).to be_truthy
    end

    context 'when reordered' do
      let(:y) {Time.now.year.to_i}
      before do
        o.taxon_determinations.first.update(year_made: 1920)
        o.taxon_determinations.last.update(year_made: 1980)
        o.reorder_determinations_by()
        o.reload
      end

      specify 'ordered by position' do
        expect(o.taxon_determinations.reload.order('taxon_determinations.position').map(&:year_made)).to eq([1980, 1920, nil])
      end

      specify '#current_taxon_determination' do
        expect(o.current_taxon_determination.year_made).to eq(1980)
      end
    end
  end

  context 'soft validation' do
    let(:o) {Specimen.create}

    specify 'determination is missing' do
      o.soft_validate(only_sets: :missing_determination)
      expect(o.soft_validations.messages_on(:base).count).to eq(1)
    end

    specify 'determination not missing' do
      o.update(otus_attributes: [{name: 'name'}])
      o.soft_validate(only_sets: :missing_determination)
      expect(o.soft_validations.messages_on(:base).count).to eq(0)
    end

    specify 'determination is preceding collecting' do
      o.taxon_determinations << FactoryBot.create(:valid_taxon_determination, year_made: 2000)
      o.collecting_event = FactoryBot.create(:valid_collecting_event)
      o.collecting_event.start_date_year = 2001
      o.soft_validate(only_sets: :determined_before_collected)
      expect(o.soft_validations.messages_on(:base).count).to eq(1)
      o.collecting_event.start_date_year = 1999
      o.soft_validate(only_sets: :determined_before_collected)
      expect(o.soft_validations.messages_on(:base).count).to eq(0)
    end

    specify 'collecting_event missing' do
      o.soft_validate(only_sets: :missing_collecting_event)
      expect(o.soft_validations.messages_on(:collecting_event_id).count).to eq(1)
    end

    specify 'preparation_type missing' do
      o.soft_validate(only_sets: :missing_preparation_type)
      expect(o.soft_validations.messages_on(:preparation_type_id).count).to eq(1)
    end

    specify 'repository missing' do
      o.soft_validate(only_sets: :missing_repository)
      expect(o.soft_validations.messages_on(:repository_id).count).to eq(1)
    end
  end

end

