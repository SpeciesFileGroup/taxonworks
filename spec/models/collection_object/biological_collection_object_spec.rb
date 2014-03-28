require 'spec_helper'
describe CollectionObject::BiologicalCollectionObject do

  let(:biological_collection_object) { FactoryGirl.build(:collection_object_biological_collection_object) }

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biological_collection_object).to respond_to(:biocuration_classifications)
      end

      specify 'biocuration_classes' do
        expect(biological_collection_object).to respond_to(:biocuration_classes)
      end

      specify 'taxon_determinations' do
        expect(biological_collection_object).to respond_to(:taxon_determinations)
      end

      specify 'otus' do
        expect(biological_collection_object).to respond_to(:otus)
      end
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

  describe "mx, 3i,SpeciesFile features otherwise unplaced" do 
    context "SpeciesFile" do
      # presumed ok, missing, lost?, lost, damaged, unknown, data entered
    end
    context "3i" do
      pending
    end
    context "mx" do
      pending
    end
  end

  describe "concerns" do
    specify "biological attributes" # any property you want to define such as sex, host, Ph, unladen speed
  end

end
