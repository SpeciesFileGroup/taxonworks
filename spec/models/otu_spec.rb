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
        expect(otu).to respond_to(:contents)
      end  
     
      specify "otu contents" do
        expect(otu).to respond_to(:otu_contents)
      end  
   
      specify "topics" do
        expect(otu).to respond_to(:topics)
      end  

    end

  end

  context "concerns" do
    it_behaves_like "identifiable"
  end


end
