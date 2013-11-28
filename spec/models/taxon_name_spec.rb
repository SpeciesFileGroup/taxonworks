require 'spec_helper'
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

      before(:all) do
        @type_of_genus = FactoryGirl.create(:iczn_genus, name: 'Bus')
        @original_genus = FactoryGirl.create(:iczn_genus, name: 'Cus')
        @taxon_name = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus', parent: @type_of_genus)
        @relationship1 = FactoryGirl.create(:type_species_relationship, subject: @taxon_name, object: @type_of_genus )
        @relationship2 = FactoryGirl.create(:taxon_name_relationship, subject: @original_genus, object: @taxon_name, type: TaxonNameRelationship::OriginalCombination::OriginalGenus)
      end

      context 'methods related to taxon_name_relationship associations (returning Array)' do
        # TaxonNameRelationships in which the taxon name is the subject
        specify 'taxon_name_relationships' do
          expect(@taxon_name).to respond_to (:taxon_name_relationships)
          expect(@taxon_name.taxon_name_relationships.to_a).to eq([@relationship1.becomes(@relationship1.type)])
        end

        # TaxonNameRelationships in which the taxon name is the subject OR object
        specify 'all_taxon_name_relationships' do
          expect(@taxon_name).to respond_to (:all_taxon_name_relationships)
          expect(@taxon_name.all_taxon_name_relationships).to eq([@relationship1.becomes(@relationship1.type), @relationship2.becomes(@relationship2.type)])
        end

        # TaxonNames related by all_taxon_name_relationships
        specify 'related_taxon_names' do
          expect(@taxon_name.related_taxon_names.sort).to eq([@type_of_genus, @original_genus].sort)
        end
      end
    end
  end

  context 'validation' do
    before do
      taxon_name.valid?
    end
 
    context 'requires' do
      specify 'rank' do
        expect(taxon_name.errors.include?(:rank_class)).to be_true
      end

      specify 'type' do
        expect(taxon_name.type).to eq('Protonym')
      end

      specify 'parent rank is higher' do
        taxon_name.update(rank_class: Ranks.lookup(:iczn, 'Genus'), name: 'Aus')
        taxon_name.parent = TaxonName.new(name: 'aaa', rank_class: Ranks.lookup(:iczn, 'species'))
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
      specify 'is validly_published when a NomenclaturalRank subclass' do
        taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
        taxon_name.name = 'Aaa'
        taxon_name.valid?
        expect(taxon_name.errors.include?(:rank_class)).to be_false
      end

      specify 'is invalidly_published when not a NomenclaturalRank subclass' do
        taxon_name.rank_class = 'foo'
        taxon_name.valid? 
        expect(taxon_name.errors.include?(:rank_class)).to be_true
      end
    end

    context 'name' do
      context 'format' do
        before(:all) do
          @subspecies = FactoryGirl.create(:iczn_subspecies)
          @variety = FactoryGirl.create(:icn_variety)
        end

        context 'double checking FactoryGirl' do
          specify 'is building all related names for respective models' do
            expect(@subspecies.ancestors.length).to be >= 10
            expect(@variety.ancestors.length).to be >= 15
          end
        end

        context 'after_validation' do
          specify 'cached_names are be set with ancestors' do
            @subspecies.valid?
            expect(@subspecies.cached_higher_classification).to eq('Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini')
            expect(@subspecies.cached_author_year).to eq('McAtee, 1900')
            expect(@subspecies.cached_name).to eq('Erythroneura (Erythroneura) vitis ssp')
            @variety.valid?
            expect(@variety.cached_higher_classification).to eq('Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae')
            expect(@variety.cached_author_year).to eq('McAtee (1900)')
            expect(@variety.cached_name).to eq('Aus (Aus sect. Aus ser. Aus) aaa bbb var. ccc')
          end
          specify 'nil author and year - cashed value should be empty' do
            t = FactoryGirl.build(:iczn_kingdom)
            t.valid?
            expect(t.cached_author_year).to eq('')
          end
        end

        context 'soft_validations' do
          context 'valid parent rank' do
            specify 'parent rank should be valid' do
              taxa = @subspecies.ancestors + [@subspecies] + @variety.ancestors + [@variety]
              taxa.each do |t|
                t.soft_validate
                expect(t.soft_validations.messages_on(:rank_class).empty?).to be_true
              end
            end
            specify 'invalid parent rank' do
              t = FactoryGirl.create(:iczn_subgenus, parent: @subspecies.ancestor_at_rank('family'))
              t.soft_validate
              expect(t.soft_validations.messages_on(:rank_class).empty?).to be_false
            end
          end

          context 'missing_fields' do
            specify "source is missing" do
              species = @subspecies.ancestor_at_rank('species')
              species.soft_validate
              expect(species.soft_validations.messages_on(:source_id).empty?).to be_false
              expect(species.soft_validations.messages_on(:verbatim_author).empty?).to be_true
              expect(species.soft_validations.messages_on(:year_of_publication).empty?).to be_true
            end
            specify 'author and year are missing' do
              kingdom = @subspecies.ancestor_at_rank('kingdom')
              kingdom.soft_validate
              expect(kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_false
              expect(kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_false
            end
            specify 'fix author and year' do
              s = Source.new(year: 1950, author: 'aaa')
              s.save
              t = FactoryGirl.build(:iczn_kingdom)
              t.source = s
              t.soft_validate
              expect(t.soft_validations.messages_on(:verbatim_author).count).to be > 0
              expect(t.soft_validations.messages_on(:year_of_publication).count).to be > 0
              t.fix_soft_validations
              t.soft_validate
              expect(t.soft_validations.messages_on(:verbatim_author).empty?).to be_true
              expect(t.soft_validations.messages_on(:year_of_publication).empty?).to be_true
              expect(t.verbatim_author).to eq('aaa')
              expect(t.year_of_publication).to eq(1950)
            end
            specify "missing relationships" do
              expect(@subspecies.soft_validations.messages_on(:base).include?('Original genus is missing')).to be_true
            end
          end
        end

      end

      context 'when rank ICZN family' do
        specify "is validly_published when ending in '-idae'" do
          taxon_name.name = 'Fooidae'
          taxon_name.rank_class = Ranks.lookup(:iczn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_false
        end
        specify "is invalidly_published when not ending in '-idae'" do
          taxon_name.name = 'Aus'
          taxon_name.rank_class = Ranks.lookup(:iczn, 'family') 
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_true
        end
        specify 'is validly_published when capitalized' do
          taxon_name.name = 'Fooidae'
          taxon_name.rank_class = Ranks.lookup(:iczn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_false
        end
        specify 'is invalidly_published when not capitalized' do
          taxon_name.name = 'fooidae'
          taxon_name.rank_class = Ranks.lookup(:iczn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_true
        end
      end

      context 'when rank ICN family' do
        specify "is validly_published when ending in '-aceae'" do
          taxon_name.name = 'Fooaceae'
          taxon_name.rank_class = Ranks.lookup(:icn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_false
        end
        specify "is invalidly_published when not ending in '-aceae'" do
          taxon_name.name = 'Aus'
          taxon_name.rank_class = Ranks.lookup(:icn, 'family')
          taxon_name.valid?
          expect(taxon_name.errors.include?(:name)).to be_true
        end
      end

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
      specify 'returns nil when not a NomenclaturalRank (i.e. invalidly_published)' do
        taxon_name.rank_class = 'foo'
        expect(taxon_name.rank).to be_nil
      end

      specify 'returns vernacular when rank_class is a NomenclaturalRank (i.e. validly_published)' do
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
        before(:all) do
          @genus = FactoryGirl.create(:iczn_genus)
          @family = FactoryGirl.create(:icn_family)
        end

        specify 'returns an ancestor at given rank' do
          expect(@genus.ancestor_at_rank('family').name).to eq('Cicadellidae')
          expect(@family.ancestor_at_rank('class').name).to eq('Aopsida')
        end

        specify "returns nil when given rank and name's rank are the same" do
          expect(@genus.ancestor_at_rank('genus')).to be_nil
        end

        specify "returns nil when given rank is lower than name's rank" do
          expect(@genus.ancestor_at_rank('species')).to be_nil
        end

        specify 'returns nil when given rank is not present in the parent chain' do
          expect(@genus.ancestor_at_rank('subtribe')).to be_nil
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
        before(:all) do
          @root = FactoryGirl.create(:root_taxon_name)
          @family = FactoryGirl.create(:iczn_family, parent: @root)
          @genus1 = FactoryGirl.create(:iczn_genus, parent: @family)
          @genus2 = FactoryGirl.create(:iczn_genus, parent: @family)
          @species1 = FactoryGirl.create(:iczn_species, parent: @genus1)
          @species2 = FactoryGirl.create(:iczn_species, parent: @genus2)
          @root.reload
        end

        specify 'root' do
          expect(@species1.root).to eq(@root)
        end

        specify 'ancestors' do
          expect(@root.ancestors.size).to eq(0)
          expect(@family.ancestors.size).to eq(1)
          expect(@family.ancestors).to eq([@root])
          expect(@species1.ancestors.size).to eq(3)
        end

        specify 'parent' do
          expect(@root.parent).to eq(nil)
          expect(@family.parent).to eq(@root)
        end

        specify 'leaves' do
          expect(@root.leaves).to eq([@species1, @species2])
        end

        specify 'move_to_child_of' do
          @species2.move_to_child_of(@genus1)
          expect(@genus2.children).to eq([])
          expect(@genus1.children).to eq([@species1,@species2])
        end

        #TODO: others, but clearly it works as needed
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'citable'
  end
end
