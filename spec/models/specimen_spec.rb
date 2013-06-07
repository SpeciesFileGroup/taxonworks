require 'spec_helper'

describe Specimen do

  let(:specimen) { Specimen.new }

  context "validation" do
    specify "total must be nil" do 
      specimen.save
      expect(specimen.total).to be_nil
    end

  end

  context "reflections / foreign keys" do

    specify "it has many Otus through determinations" do
      expect(specimen).to respond_to(:otus)
    end
  end

  context "concerns" do
    it_behaves_like "containable"
    it_behaves_like "identifiable"
  end

  # TODO: Move to Concern
  specify "it is determinable" do
    expect(specimen).to respond_to(:specimen_determinations)
  end

end



