require 'spec_helper'

describe SpecimenLot do

  let(:s) { SpecimenLot.new }
  
  # validation
  specify "it should be invalid when total is not > 1" do 
    [0,1,nil].each do |v|
      s.total = v
      expect(s.save).to eq(false)
      expect(s.errors.include?(:total)).to be_true
    end
  end

end
