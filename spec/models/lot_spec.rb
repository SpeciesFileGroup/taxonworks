require 'spec_helper'
describe Lot do

  let(:lot) { FactoryGirl.build(:lot) }

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


