require 'spec_helper'

describe CollectionObject::BiologicalCollectionObject do

   let(:biological_collection_object) { CollectionObject::BiologicalCollectionObject.new }

  describe "instance methods" do
   
    # TODO: true? 
    it "should have a verbatim_determination_label"
    # it seems as though these method tests could be refactored as a loop of methods
    #specify "verbatim_determination_label" do # a text field with new lines for each field
    #  expect(biological_collection_object).to respond_to(:verbatim_determination_label)
    #  expect(biological_collection_object.verbatim_determination_label).to be_a(String)
    #  expect(biological_collection_object.verbatim_determination_label).not_to eq('This must be replaced by the \'verbatim_determination_label\' string.')
    #end

    # TODO: true?
    it "should have a verbatim_locality_label" 
    #specify "verbatim_locality_label" do # a text field with new lines for each field
    #  expect(biological_collection_object).to respond_to(:verbatim_locality_label)
    #  expect(biological_collection_object.verbatim_locality_label).to be_a(String)
    #  expect(biological_collection_object.verbatim_locality_label).not_to eq('This must be replaced by the \'verbatim_locality_label\' string.')
    #end

    it "should have a verbatim_other_label" 
    #specify "verbatim_other_label" do
    #  expect(biological_collection_object).to respond_to(:verbatim_other_label)
    #  expect(biological_collection_object.verbatim_other_label).to be_a(String)
    #  expect(biological_collection_object.verbatim_other_label).not_to eq('This must be replaced by the \'verbatim_other_label\' string.')
    #end

    # TODO: true?
    it "should have a verbatim_accession_number"
    #specify "verbatim_accession_number" do
    #  expect(biological_collection_object).to respond_to(:verbatim_accession_number)
    #  expect(biological_collection_object.verbatim_accession_number).to be_a(String)
    #  expect(biological_collection_object.verbatim_accession_number).not_to eq('This must be replaced by the \'verbatim_accession_number\' string.')
    #end

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
    specify "disposition ()"  #was boolean lost or not
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

    # Are these the same things?
    specify "notable (notes)" # 
    specify "tagable (tags)"
  end

  describe "validation" do
    specify "once set, a verbatim label can not change"
  end

end
