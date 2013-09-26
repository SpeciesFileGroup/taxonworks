require 'spec_helper'

# A class representing physical, biological, collection enumerated (precisely, see also RangedLot) to > 1, i.e. a group of individuals.

describe Lot do

  let(:lot) { Lot.new }

  context "validation" do
  
    before do 
      lot.save
    end

    context "before validation" do
      specify "total must be > 1" do 
        expect(lot.errors.keys).to include(:total)
      end
    end
  end

  context "concerns" do
    it_behaves_like "containable"
    it_behaves_like "identifiable"
    it_behaves_like "determinable"
  end

end


