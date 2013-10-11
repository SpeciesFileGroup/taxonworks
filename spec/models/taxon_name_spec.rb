require 'spec_helper'

# TODO:
# validation tests should be more generalized to cover botanical and potentially
# other nomenclature as well. Botanical ranks also have  endings of taxa encoded.

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
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
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
            taxon_name.rank_class = Ranks.lookup(:iczn, 'family') 
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
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
        expect(taxon_name.rank_class).to eq(NomenclaturalRank::Iczn::AboveFamilyGroup::Order)
      end
    end

    context "rank" do
      specify "returns nil when not a NomenclaturalRank (i.e. invalid)" do
        taxon_name.rank_class = "foo"
        expect(taxon_name.rank).to be_nil
      end

      specify "returns vernacular when rank_class is a NomenclaturalRank (i.e. valid)" do
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
        expect(taxon_name.rank).to eq('order')
      end

    end
  end

  context "hierarchy" do
    context "rank related" do
      context "ancestor_at_rank" do
        genus = FactoryGirl.create(:iczn_genus)
        subspecies = FactoryGirl.create(:iczn_subspecies)
                
        specify "returns an ancestor at given rank" do
          expect(subspecies.ancestor_at_rank('family').name).to eq('Cicadellidae')
        end
        
        specify "returns nil when given rank and name's rank is the same" do
          expect(subspecies.ancestor_at_rank('subspecies')).to be_nil
        end
        
        specify "returns nil when given rank is lower than name's rank" do
          expect(genus.ancestor_at_rank('species')).to be_nil
        end
        
        specify "returns nil when given rank is not present in the parent chain" do
          expect(genus.ancestor_at_rank('subtribe')).to be_nil
        end
      end
    end
    context "class methods from awesome_nested_set" do

      specify "permit one root per project" 

      specify "permit multiple roots across the database" do
        root1 = FactoryGirl.create(:root_taxon_name)
        root2 = FactoryGirl.build(:root_taxon_name)
        expect(root2.parent).to be_nil
        expect(root2.valid?).to be_true
      end

      # run through the awesome_nested_set methods: https://github.com/collectiveidea/awesome_nested_set/wiki/_pages
      context "handle a simple hierarchy with awesome_nested_set" do
      
        root = FactoryGirl.create(:root_taxon_name)
        family = FactoryGirl.create(:iczn_family, parent: root)
        genus1 = FactoryGirl.create(:iczn_genus, parent: family)
        genus2 = FactoryGirl.create(:iczn_genus, parent: family)
        species1 = FactoryGirl.create(:iczn_species, parent: genus1)
        species2 = FactoryGirl.create(:iczn_species, parent: genus2)

        root.reload

        specify "root" do 
          # returns the subclass, so test by id
          expect(species1.root).to eq(root)
        end

        specify "ancestors" do 
          expect(root.ancestors.size).to eq(0)
          expect(family.ancestors.size).to eq(1)
          expect(family.ancestors).to eq([root])
          expect(species1.ancestors.size).to eq(3)
        end

        specify "parent" do 
          expect(root.parent).to eq(nil)
          expect(family.parent).to eq(root)
        end

        specify "leaves" do
          expect(root.leaves).to eq([species1, species2])
        end

        specify "move_to_child_of" do
          species2.move_to_child_of(genus1)
          expect(genus2.children).to eq([])
          expect(genus1.children).to eq([species1,species2])
        end

        #TODO: others, but clearly it works as needed
      end


    end
  end

  context "relations / associations" do 
    specify "taxon_name_relationships" do
      expect(taxon_name.taxon_name_relationships).to eq([])
    end
  end

end
