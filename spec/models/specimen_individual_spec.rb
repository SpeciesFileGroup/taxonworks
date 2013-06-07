require 'spec_helper'

# "A biological entity enumerated to 1. Implies the existence of a physical entity at some point in time."

describe SpecimenIndividual do

  let(:specimen_individual) { SpecimenIndividual.new }

  context "on creation" do
    specify "type is SpecimenIndividual" do
      expect(specimen_individual.type).to eq('SpecimenIndividual')
    end
  end

  context "validation" do
    before do
      specimen_individual.save
    end 

    specify "it should be invalid when total != 1" do 
      specimen_individual.total = 0
      expect(specimen_individual.valid?).to eq(false)
      specimen_individual.total = nil
      expect(specimen_individual.valid?).to eq(false)
      specimen_individual.total = 2
      expect(specimen_individual.valid?).to eq(false)
    end

    # describe "existence and type of object" do
    #   specify("exists as an object of the class 'Specimen'") do
    #     expect(s).not_to be_nil
    #     expect(s).to be_a(Specimen)
    #     s.save
    #     expect(s.id).to be_an(Integer)
    #   end
    # end


  end
end

