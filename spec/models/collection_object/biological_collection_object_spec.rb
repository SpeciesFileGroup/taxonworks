require 'spec_helper'
describe CollectionObject::BiologicalCollectionObject do

  let(:biological_collection_object) { FactoryGirl.build(:collection_object_biological_collection_object) }

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biological_collection_object.biocuration_classifications << BiocurationClassification.new()).to be_true 
      end

      specify 'biocuration_classes' do
        expect(biological_collection_object.biocuration_classes << BiocurationClass.new()).to be_true 
      end

      specify 'taxon_determinations' do
        expect(biological_collection_object.taxon_determinations << TaxonDetermination.new()).to be_true 
      end

      specify 'otus' do
        expect(biological_collection_object.otus << Otu.new()).to be_true 
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

  describe "use" do
    specify "create and also create otus, and determinations (nested_attributes_for :otus)" do
      o = Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}])
      expect(o.save).to be_true
      expect(o.otus).to have(2).things
      expect(o.taxon_determinations).to have(2).things
    end

    specify "#reorder_determinations_by(:year)" do
      expect(biological_collection_object).to respond_to(:reorder_determinations_by)
      o = Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}, {name: 'three'}])
      expect(o.save).to be_true
      expect(o.current_determination).to eq o.taxon_determinations.first

      o.taxon_determinations.first.update(year_made: 1920)
      o.taxon_determinations.last.update(year_made:  1980)

      expect(o.reorder_determinations_by()).to be_true
      expect(o.taxon_determinations.map(&:year_made)).to eq([2014, 1920, 1980])
    end
  end

  describe "instance methods" do
    specify "#current_determination" do
      expect(biological_collection_object).to respond_to(:current_determination)
      o = Specimen.new(otus_attributes: [{name: 'one'}, {name: 'two'}])
      expect(o.save).to be_true
      expect(o.current_determination).to eq(o.taxon_determinations.first)
    end
  end

end
