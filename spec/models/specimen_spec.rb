require 'spec_helper'

# Definition: The biological accession that is enumerated as 1
describe Specimen do

  let(:s) { Specimen.new }

  # Columns 
  describe "properties" do
    specify "current_location (the present location [time axis])" 

    specify "disposition ()"  #was boolean lost or not

    specify "destroyed? (gone, for real, never ever EVER coming back)"

    specify "condition (damaged/level)"
    specify "preparation" # pin/etc./etoh <- questions here
    specify "accession source (from whom the specimen came)"
    specify "deaccession recipient (to whom the specimen went to)"
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

  describe "instance methods" do
    specify "verbatim_determination_label" do # a text field with new lines for each field
      expect(s).to respond_to(:verbatim_determination_label)
    end

    specify "verbatim_locality_label" do # a text field with new lines for each field
      expect(s).to respond_to(:verbatim_locality_label)
    end

    specify "verbatim_other_label" do
      expect(s).to respond_to(:verbatim_other_label)
    end

    specify "verbatim_accession_number" do
      expect(s).to respond_to(:verbatim_accession_number)
    end

    it "should return the current determination"
    it "should return the depository"
    it "on update it should SCREAM AT YOU when you change implied verbatim data if more than one specimen uses that data" 
    it "should permit requirable properties (key/value pairs)"
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

end



