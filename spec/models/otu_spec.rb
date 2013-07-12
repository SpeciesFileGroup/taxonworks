require 'spec_helper'

describe Otu do
  let(:otu) { Otu.new }

  # foreign key relationships
  context "reflections / foreign keys" do
    
    context "has many" do
      specify "specimen determinations" do
        expect(otu).to respond_to(:specimen_determinations)
      end

      specify "contents" do
        # @otu.contents
        expect(otu).to respond_to(:contents)
      end  
 

      specify "otu contents" do
        # @otu.otu_contents
        expect(otu).to respond_to(:otu_contents)
      end  
    
    end

  end

  context "concerns" do
    it_behaves_like "identifiable"
  end


end
