require 'spec_helper'

describe Specimen do
  let(:specimen) { Specimen.new }

  context "validation" do
    before(:each) do 
      specimen.save
    end

    context "before_validation" do
      specify "total must be one" do 
        expect(specimen.total).to eq(1)
      end
    end
  end

  context "concerns" do
    it_behaves_like "containable"
    it_behaves_like "identifiable"
    it_behaves_like "determinable"
  end

end


