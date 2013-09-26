require 'spec_helper'

# A class representing a single, physical, and biological individual that has been collected.  Used when the curator has enumerated something to 1.

describe Specimen do

  let(:specimen) { Specimen.new }

  context "validation" do

    # Trigger the callbacks
    before do 
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


