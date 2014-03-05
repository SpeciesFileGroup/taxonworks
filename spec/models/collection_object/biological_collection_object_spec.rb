require 'spec_helper'
describe CollectionObject::BiologicalCollectionObject do

  let(:biological_collection_object) { FactoryGirl.build(:collection_object_biological_collection_object) }

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biological_collection_object).to respond_to(:biocuration_classifications)
      end
    end
  end

  describe "instance methods" do
    it "should return the current determination"
    it "should return the depository"
    it "on update it should SCREAM AT YOU when you change implied verbatim data if more than one biological_collection_object uses that data" 
    it "should permit arbitrary requirable properties (key/value pairs)"
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

 # Columns 
  describe "properties" do
    specify "current_location (the present location [time axis])" 
    specify "disposition ()"  # was boolean lost or not
    specify "destroyed? (gone, for real, never ever EVER coming back)"
    specify "condition (damaged/level)"
    specify "preparation" # pin/etc./etoh <- questions here
    specify "accession source (from whom the biological_collection_object came)"
    specify "deaccession recipient (to whom the biological_collection_object went)"
    specify "depository (where the)"  
  end

  # Foreign key relationships 
  describe "reflections/associations" do
    context "belongs_to" do
      specify "collecting event (field notes - who, where, when, how)" do
        pending
        # Includes verbatim fields pertaining to the collecting event etc.
      end
      specify "preparation (pin, etc.)"
    end

    context "has_many" do
    end
  end 

  describe "concerns" do
    specify "biological properties" # any property you want to define such as sex, host, Ph, unladen speed
    specify "determinable (taxon names)"
    specify "locatable (location)"
    specify "identifiable (catalog numbers)"
    specify "figurable (images)"
    specify "notable (notes)" # 
    specify "tagable (tags)"
  end

  describe "validation" do
    specify "once set, a verbatim label can not change"
  end

end
