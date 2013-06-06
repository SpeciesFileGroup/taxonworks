require 'spec_helper'

describe Specimen do

  let(:s) { Specimen.new }

  context "validation" do
    specify "it should be invalid when total not set" do 
      expect(s.save).to eq(false)
    end
  end

  context "reflections / foreign keys" do
    specify "it is containable" do
      expect(s).to respond_to(:container)
    end
 
    specify "it has many Otus through determinations" do
      expect(s).to respond_to(:otus)
    end
  end

  context "concerns" do
      it_behaves_like "identifiable"
  end

  # TODO: Move to Concern
  specify "it is determinable" do
    expect(s).to respond_to(:specimen_determinations)
  end

  
end



