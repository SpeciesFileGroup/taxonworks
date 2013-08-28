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

    context "rank" do
      specify "is valid when a NomenclaturalRank subclass" do
        taxon_name.rank = ::ICZN_LOOKUP['order']
        taxon_name.valid?
        expect(taxon_name.errors.include?(:rank)).to be_false
      end

      specify "is not valid when not a NomenclaturalRank subclass" do
        taxon_name.rank = "foo"
        taxon_name.valid? 
        expect(taxon_name.errors.include?(:rank)).to be_true
      end
    end

    context "name" do
      context "format" do
        specify "is validated based on NomenclaturalRank" do
          taxon_name.name = "Aus"
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_true
        end
      end
    end

    context "after save" do
      before do
        taxon_name.save
      end

      specify "cached_name should be set" do
        # expect(taxon_name.cached_name.nil?).to be false 
        pending "requires code in NomenclaturalRank subclasses"
      end
    end
  end

  context "methods" do
    specify "rank_class" do
      expect(taxon_name).to respond_to(:rank_class)
    end
  end

  context "heirarchy" do
    specify "a given hierarchy has only one root" do
      pending "requires nested set base"
    end
  end

end
