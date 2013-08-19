require 'spec_helper'

# A class representing the metadata of one or more specimens.  Physical entities are instantiated from its subclasses SpecimenIndividual and SpecimenLot.

describe Specimen do

  let(:specimen) { Specimen.new }

  context "validation" do
    context "on creation" do
      specify "total to be 1" do 
        expect(specimen).to be_a(Specimen)
      end
    end

    context "requires"
    before do
      specimen.save
    end

    specify "total to be one" do 
      expect(specimen.total).to eq(1)
    end

  end

  context "reflections / foreign keys" do
    context "has many" do 
    end
  end

  context "concerns" do
    it_behaves_like "containable"
    it_behaves_like "identifiable"
    it_behaves_like "determinable"
  end

end


