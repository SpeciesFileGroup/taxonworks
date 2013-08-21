require 'spec_helper'

describe TaxonName do

  let(:taxon_name) { TaxonName.new }

  context "validation" do 

    context "requires" do
      before do
        taxon_name.valid?
      end

      specify "name" do
        expect(taxon_name.errors.include?(:name)).to be_true
      end

      specify "rank" do
        expect(taxon_name.errors.include?(:rank)).to be_true
      end

    end

    context "after save" do
       before do
         taxon_name.save
       end

      specify "cached_name should be set" do
        name = "Foo"
        taxon_name.name = name 
        taxon_name.rank = "FOO"
        taxon_name.save
        expect(taxon_name.cached_name).to eq(name)
      end

    end

    context "heirarchy" do
      specify "a given hierarchy has only one root" do
          pending
      end
    end

    context "methods" do

      specify "it should short hierarchically" do
        pending
      end

      specify "it should short hierarchically" do
        pending
      end

      specify "it should swap out the root for a new name" do
        pending
      end



    end



  end
end
