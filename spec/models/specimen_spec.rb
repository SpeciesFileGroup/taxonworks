require 'spec_helper'

# A class representing the metadata of one or more specimens.  Physical entities are instantiated from its subclasses SpecimenIndividual and SpecimenLot.

describe Specimen do

  let(:specimen) { Specimen.new }

  context "validation" do
    context "on creation" do
      specify "total to be nil" do 
        expect(specimen.type).to eq('Specimen')
      end
    end

    context "requires"
    before do
      specimen.save
    end

    specify "total to be nil" do 
      expect(specimen.total).to be_nil
    end

  end

  context "reflections / foreign keys" do
    context "has many" do 
      specify "it has many Otus through determinations" do
        expect(specimen).to respond_to(:otus)
      end

      specify "SpecimenDeterminations" do
        expect(specimen).to respond_to(:specimen_determinations)
      end
    end
  end

  context "concerns" do
    it_behaves_like "containable"
    it_behaves_like "identifiable"
  end

end
