require 'spec_helper'

describe SpecimenIndividual do

  let(:s) { SpecimenIndividual.new }

  # validation
  specify "it should be invalid when total != 1" do 
    s.total = 0
    expect(s.save).to eq(false)
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
