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
        expect(taxon_name.errors.include?(:rank_class)).to be_true
      end

      specify "type" do
        expect(taxon_name.type).to eq('Protonym')
      end
    end

    context "rank_class" do
      specify "is valid when a NomenclaturalRank subclass" do
        taxon_name.rank_class = ::ICZN_LOOKUP['order']
        taxon_name.valid?
        expect(taxon_name.errors.include?(:rank_class)).to be_false
      end

      specify "is invalid when not a NomenclaturalRank subclass" do
        taxon_name.rank_class = "foo"
        taxon_name.valid? 
        expect(taxon_name.errors.include?(:rank_class)).to be_true
      end
    end

    context "name (= latinized version)" do
      context "format" do
        # TODO: Consider moving this to a different spec.
        context "when rank ICZN family" do
          specify "is valid when ending in 'idae'" do
            taxon_name.name = "Fooidae"
            taxon_name.valid?
            expect(taxon_name.errors.include?(:name)).to be_false
          end
          specify "is invalid when not ending in 'idae'" do
            taxon_name.name = "Aus"
            taxon_name.rank_class =  ::ICZN_LOOKUP['family'] 
            taxon_name.valid?
            expect(taxon_name.errors.include?(:name)).to be_true
          end 
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
    context "rank_class" do 
      specify "returns the passed value when not yet validated and not a NomenclaturalRank" do
        taxon_name.rank_class = "foo"
        expect(taxon_name.rank_class).to eq('foo') 
      end

      specify "returns a NomenclaturalRank when available" do
        taxon_name.rank_class = ::ICZN_LOOKUP['order']
        expect(taxon_name.rank_class).to eq(NomenclaturalRank::Iczn::Ungoverned::Order)
      end
   end

    context "rank" do
      specify "returns nil when not a NomenclaturalRank (i.e. invalid)" do
        taxon_name.rank_class = "foo"
        expect(taxon_name.rank).to be_nil
      end

      specify "returns vernacular when rank_class is a NomenclaturalRank (i.e. valid)" do
        taxon_name.rank_class = ::ICZN_LOOKUP['order']
        expect(taxon_name.rank).to eq('order')
      end

    end
  end

  context "heirarchy" do
    specify "a given hierarchy has only one root" do
      pending "requires nested set base"
    end
  end

  context "relations / associations" do 
    specify "taxon_name_relationships" do
        expect(taxon_name.taxon_name_relationships).to eq([])
    end
  end

end
