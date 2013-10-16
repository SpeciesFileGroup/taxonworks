require 'spec_helper'

# TODO: validation tests should be more generalized to cover botanical and potentially
# other nomenclature as well.
# Botanical ranks also have endings of taxa encoded. <- this should be 'specified'

describe TaxonName do

  let(:taxon_name) { TaxonName.new }

  context 'associations' do 
    specify 'source' do
      expect(taxon_name).to respond_to(:source)
    end 

    context 'taxon_name_relationships' do

      specify 'taxon_name_relationships' do
        expect(taxon_name).to respond_to(:taxon_name_relationships)
      end 

      before do
        taxon_name.update(rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus')
        taxon_name.save!
        @type_of_genus =  FactoryGirl.create(:iczn_genus, name: 'Bus')
        @original_genus = FactoryGirl.create(:iczn_genus, name: 'Cus')
        @relationship1 = FactoryGirl.create(:type_species_relationship, subject: taxon_name, object: @type_of_genus )
        @relationship2 = FactoryGirl.create(:taxon_name_relationship, subject: @original_genus, object: taxon_name, type: TaxonNameRelationship::OriginalDescription::OriginalGenus)
      end

      context 'methods related to taxon_name_relationship associations (returning Array)' do
        # TaxonNameRelationships in which the taxon name is the subject
        specify 'taxon_name_relationships' do
          expect(taxon_name).to respond_to (:taxon_name_relationships)
          expect(taxon_name.taxon_name_relationships.to_a).to eq([@relationship1.becomes(@relationship1.type)])
        end

        # TaxonNameRelationships in which the taxon name is the subject OR object
        specify 'all_taxon_name_relationships' do
          expect(taxon_name).to respond_to (:all_taxon_name_relationships)
          expect(taxon_name.all_taxon_name_relationships).to eq([@relationship1.becomes(@relationship1.type), @relationship2.becomes(@relationship2.type)])
        end

        # TaxonNames related by all_taxon_name_relationships
        specify 'related_taxon_names' do
          expect(taxon_name.related_taxon_names).to eq([@type_of_genus, @original_genus])
        end
      end
    end
  end

  context 'validation' do 
    context 'requires' do
      before do
        taxon_name.valid?
      end

      specify 'name' do
        expect(taxon_name.errors.include?(:name)).to be_true
      end

      specify 'rank' do
        expect(taxon_name.errors.include?(:rank_class)).to be_true
      end

      specify 'type' do
        expect(taxon_name.type).to eq('Protonym')
      end

      specify 'parent rank is higher' do
        taxon_name.update(rank_class: Ranks.lookup(:iczn, 'Genus'), name: 'Aus')
        taxon_name.parent = FactoryGirl.build(:iczn_species)
        taxon_name.valid?
        expect(taxon_name.errors.include?(:parent_id)).to be_true
      end

    end

    context 'source' do
      specify 'when provided, is type Source::Bibtex' do
        h = FactoryGirl.build(:human_source)
        taxon_name.source = h
        taxon_name.valid?
        expect(taxon_name.errors.include?(:source_id)).to be_true
        b = FactoryGirl.build(:bibtex_source)
        taxon_name.source = b
        taxon_name.valid?
        expect(taxon_name.errors.include?(:source_id)).to be_false
      end
    end

    context 'rank_class' do
      specify 'is valid when a NomenclaturalRank subclass' do
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
        taxon_name.name = "Aaa"
        taxon_name.valid?
        expect(taxon_name.errors.include?(:rank_class)).to be_false
      end

      specify 'is invalid when not a NomenclaturalRank subclass' do
        taxon_name.rank_class = 'foo'
        taxon_name.valid? 
        expect(taxon_name.errors.include?(:rank_class)).to be_true
      end
    end

    context 'name (= latinized version)' do
      context 'format' do
        # TODO: Consider moving this to a different spec.
        context "validate taxon_name FactoryGirl" 
        subspecies = FactoryGirl.create(:iczn_subspecies)
        kingdom1 = subspecies.ancestor_at_rank("kingdom")
        variety = FactoryGirl.create(:icn_variety)
        kingdom2 = variety.ancestor_at_rank("kingdom")

        specify "all FactoryGirl ICZN fixtures are valid" do
          expect(kingdom1.descendants.length).to be >= 10
          kingdom1.descendants.each do |t|
            expect(t.valid?).to be_true
          end
        end

        specify "all ICN FactoryGirl fixtures are valid" do
          expect(kingdom2.descendants.length).to be >= 15
          kingdom2.descendants.each do |t|
            expect(t.valid?).to be_true
          end
        end

        fail1 = FactoryGirl.build(:iczn_kingdom, rank_class: "Foo")
        specify "altered FactoryGirl fixtures should fail" do
          expect(fail1.valid?).to be_false
        end

      end
      context "when rank ICZN family" do
        specify "is valid when ending in '-idae'" do
          taxon_name.name = "Fooidae"
          taxon_name.rank_class = Ranks.lookup(:iczn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_false
        end
        specify "is invalid when not ending in '-idae'" do
          taxon_name.name = "Aus"
          taxon_name.rank_class = Ranks.lookup(:iczn, 'family') 
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_true
        end
      end
      context "when rank ICN family" do
        specify "is valid when ending in '-aceae'" do
          taxon_name.name = "Fooaceae"
          taxon_name.rank_class = Ranks.lookup(:icn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_false
        end
        specify "is invalid when not ending in '-aceae'" do
          taxon_name.name = "Aus"
          taxon_name.rank_class = Ranks.lookup(:icn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_true
        end
      end
    end
  end

  context 'after save' do
    before do
      taxon_name.save
    end

    specify 'cached_name should be set' do
      # expect(taxon_name.cached_name.nil?).to be false
      pending "requires code in NomenclaturalRank subclasses"

      #specify "cached_higher_classification" do
      #  expect(family.cached_higher_classification).to !eq(nil)
      #end
      #specify "cached_name" do
      #  expect(family.cached_name).to eq(nil)
      #end

    end
  end

  context 'methods' do
    context 'verbatim_author' do 
      specify 'parens are allowed' do
        taxon_name.verbatim_author = '(Smith)' 
        taxon_name.valid?
        expect(taxon_name.errors.include?(:verbatim_author)).to be_false
      end
    end

    context 'rank_class' do 
      specify 'returns the passed value when not yet validated and not a NomenclaturalRank' do
        taxon_name.rank_class = 'foo'
        expect(taxon_name.rank_class).to eq('foo') 
      end

      specify 'returns a NomenclaturalRank when available' do
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
        expect(taxon_name.rank_class).to eq(NomenclaturalRank::Iczn::AboveFamilyGroup::Order)
        taxon_name.rank_class = Ranks.lookup(:icn, 'family')
        expect(taxon_name.rank_class).to eq(NomenclaturalRank::Icn::FamilyGroup::Family)
      end
    end

    context 'rank' do
      specify 'returns nil when not a NomenclaturalRank (i.e. invalid)' do
        taxon_name.rank_class = 'foo'
        expect(taxon_name.rank).to be_nil
      end

      specify 'returns vernacular when rank_class is a NomenclaturalRank (i.e. valid)' do
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
        expect(taxon_name.rank).to eq('order')
        taxon_name.rank_class = Ranks.lookup(:icn, 'family')
        expect(taxon_name.rank).to eq('family')
      end
    end
  end

  context 'hierarchy' do
    context 'rank related' do
      context 'ancestor_at_rank' do
        genus = FactoryGirl.create(:iczn_genus)
        subspecies = FactoryGirl.create(:iczn_subspecies)
        family = FactoryGirl.create(:icn_family)


        specify 'returns an ancestor at given rank' do
          expect(subspecies.ancestor_at_rank('family').name).to eq('Cicadellidae')
          expect(family.ancestor_at_rank('class').name).to eq('Aopsida')
        end

        specify "returns nil when given rank and name's rank are the same" do
          expect(subspecies.ancestor_at_rank('subspecies')).to be_nil
        end

        specify "returns nil when given rank is lower than name's rank" do
          expect(genus.ancestor_at_rank('species')).to be_nil
        end

        specify 'returns nil when given rank is not present in the parent chain' do
          expect(genus.ancestor_at_rank('subtribe')).to be_nil
        end
      end
    end

    context 'class methods from awesome_nested_set' do
      specify 'permit one root per project' 

      specify 'permit multiple roots across the database' do
        root1 = FactoryGirl.create(:root_taxon_name)
        root2 = FactoryGirl.build(:root_taxon_name)
        expect(root2.parent).to be_nil
        expect(root2.valid?).to be_true
      end

      # run through the awesome_nested_set methods: https://github.com/collectiveidea/awesome_nested_set/wiki/_pages
      context 'handle a simple hierarchy with awesome_nested_set' do
        root = FactoryGirl.create(:root_taxon_name)
        family = FactoryGirl.create(:iczn_family, parent: root)
        genus1 = FactoryGirl.create(:iczn_genus, parent: family)
        genus2 = FactoryGirl.create(:iczn_genus, parent: family)
        species1 = FactoryGirl.create(:iczn_species, parent: genus1)
        species2 = FactoryGirl.create(:iczn_species, parent: genus2)
        root.reload

        specify 'root' do 
          # returns the subclass, so test by id
          expect(species1.root).to eq(root)
        end

        specify "ancestors" do 
          expect(root.ancestors.size).to eq(0)
          expect(family.ancestors.size).to eq(1)
          expect(family.ancestors).to eq([root])
          expect(species1.ancestors.size).to eq(3)
        end

        specify 'parent' do 
          expect(root.parent).to eq(nil)
          expect(family.parent).to eq(root)
        end

        specify 'leaves' do
          expect(root.leaves).to eq([species1, species2])
        end

        specify 'move_to_child_of' do
          species2.move_to_child_of(genus1)
          expect(genus2.children).to eq([])
          expect(genus1.children).to eq([species1,species2])
        end

        #TODO: others, but clearly it works as needed
      end
    end
  end
end
