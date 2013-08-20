require 'spec_helper'

describe Otu do

  let(:otu) { Otu.new }

  # foreign key relationships
  context 'reflections / foreign keys' do
    context 'has many' do
      specify 'taxon determinations' do
        expect(otu).to respond_to(:taxon_determinations)
        expect(otu.taxon_determinations).to eq([])
      end
      
      specify 'contents' do
        expect(otu).to respond_to(:contents)
      end  
     
      specify 'otu contents' do
        expect(otu).to respond_to(:otu_contents)
      end  
   
      specify 'topics' do
        expect(otu).to respond_to(:topics)
      end  

    end
  end

  context 'properties' do
    specify 'name' do
      expect(otu).to respond_to(:name)
    end
  end

  context 'validation' do
    specify 'it should require a name or taxon_name_id'
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
  end

  context 'when I create a new OTU' do
    context 'and it only has taxon_name_id populated' do
      specify 'its cached_name should be the taxon name cached_name'
    end
  end


end
