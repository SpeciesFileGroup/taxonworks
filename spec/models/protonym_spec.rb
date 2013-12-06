require 'spec_helper'

describe Protonym do
  let(:protonym) { Protonym.new }

  context 'associations' do
    before(:all) do
      @order = FactoryGirl.create(:iczn_order)
      @family = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'family'), name: 'Aidae', parent: @order)
      @genus = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Aus', parent: @family)
      @protonym = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus', parent: @genus)
      @species_type_of_genus = FactoryGirl.create(:taxon_name_relationship,
                                                  subject_taxon_name: @protonym,
                                                  object_taxon_name: @genus,
                                                  type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Original')

      @genus_type_of_family = FactoryGirl.create(:taxon_name_relationship,
                                                 subject_taxon_name: @genus,
                                                 object_taxon_name: @family,
                                                 type: 'TaxonNameRelationship::Typification::Family')
    end

    context 'has_many' do
      specify 'original_combination_relationships' do 
        expect(@protonym).to respond_to(:original_combination_relationships)
        expect(@genus).to respond_to(:type_species)
        expect(@family).to respond_to(:type_genus)
        #those tests fail, because the relationships was not been established yet.
        #expect(@protonym).to respond_to(:original_genus)
        #expect(@protonym).to respond_to(:original_subgenus)
        #expect(@protonym).to respond_to(:original_section)
        #expect(@protonym).to respond_to(:original_subsection)
        #expect(@protonym).to respond_to(:original_series)
        #expect(@protonym).to respond_to(:original_subseries)
        #expect(@protonym).to respond_to(:original_species)
        #expect(@protonym).to respond_to(:original_subspecies)
        #expect(@protonym).to respond_to(:original_variety)
        #expect(@protonym).to respond_to(:original_subvariety)
        #expect(@protonym).to respond_to(:original_form)
        #expect(@protonym).to respond_to(:source_classified_as)
      end
      specify 'type_of_relationships' do
        expect(@protonym.type_of_relationships.collect{|i| i.id}).to eq([@species_type_of_genus.id])
      end
      specify 'type_of_taxon_names' do
        expect(@protonym.type_of_taxon_names).to eq([@genus])
      end
    end

    context 'has_one' do
      TaxonNameRelationship.descendants.each do |d|
        if d.respond_to?(:assignment_method) 
          relationship = "#{d.assignment_method}_relationship".to_sym
          specify relationship do
            expect(@protonym).to respond_to(relationship)
          end 
          specify d.assignment_method.to_s do
            expect(@protonym).to respond_to(d.assignment_method.to_sym)
          end
        end
      end

      context 'typification' do
        specify 'type_taxon_name' do
          expect(@genus).to respond_to(:type_taxon_name)
          expect(@genus.type_taxon_name).to eq(@protonym)
          expect(@family.type_taxon_name).to eq(@genus)
        end 
        specify 'type_taxon_name_relationship' do
          expect(@protonym).to respond_to(:type_taxon_name_relationship)
          expect(@genus.type_taxon_name_relationship.id).to eq(@species_type_of_genus.id)
          expect(@family.type_taxon_name_relationship.id).to eq(@genus_type_of_family.id)
        end 
        specify 'has at most one has_type relationship' do
          extra_type_relation = FactoryGirl.build(:taxon_name_relationship,
                                                  subject_taxon_name: @genus,
                                                  object_taxon_name: @family,
                                                  type: TaxonNameRelationship::Typification::Family)
          # Handled by TaxonNameRelationship validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]
          expect(extra_type_relation.valid?).to be_false
        end
      end

      context 'original description' do
        specify 'original_combination_source' do
          expect(@protonym).to respond_to(:original_combination_source)
        end

        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form}.each do |rank|
          method = "original_combination_#{rank}_relationship" 
          specify method do
            expect(@protonym).to respond_to(method)
          end 
        end

        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form}.each do |rank|
          method = "original_combination_#{rank}" 
          specify method do
            expect(@protonym).to respond_to(method)
          end
        end
      end
    end
  end

  context 'usage' do
    before(:all) do
      @f = FactoryGirl.create(:relationship_family, name: 'Aidae')
      @g = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: @f)
      @o = FactoryGirl.create(:relationship_genus, name: 'Bus', parent: @f)
      @s = FactoryGirl.create(:relationship_species, name: 'aus', parent: @g)
    end

    specify 'assign an original description genus' do
      expect(@s.original_combination_genus = @o).to be_true
      expect(@s.save).to be_true
      expect(@s.original_combination_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_combination_genus_relationship.subject_taxon_name).to eq(@o)
      expect(@s.original_combination_genus_relationship.object_taxon_name).to eq(@s)
    end
    specify 'has at most one original description genus' do
      expect(@s.original_combination_relationships.count).to eq(0)
      # Example 1) recasting
      temp_relation = FactoryGirl.build(:taxon_name_relationship,
                                                        subject_taxon_name: @o,
                                                        object_taxon_name: @s,
                                                        type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      temp_relation.save
      # recast as the subclass
      first_original_genus_relation = temp_relation.becomes(temp_relation.type_class)
      expect(@s.original_combination_relationships.count).to eq(1)

      # Example 2) just use the right subclass to start
      first_original_subgenus_relation = FactoryGirl.build(:original_combination_relationship,
                                                           subject_taxon_name: @g,
                                                           object_taxon_name: @s,
                                                           type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      first_original_subgenus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
      extra_original_genus_relation = FactoryGirl.build(:taxon_name_relationship,
                                              subject_taxon_name: @g,
                                              object_taxon_name: @s,
                                              type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      expect(extra_original_genus_relation.valid?).to be_false
      extra_original_genus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
    end
    specify 'assign a type species to a genus' do
      expect(@g.type_species = @s).to be_true
      expect(@g.save).to be_true

      expect(@g.type_species_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_species_relationship.subject_taxon_name).to eq(@s)
      expect(@g.type_species_relationship.object_taxon_name).to eq(@g)
      expect(@g.type_taxon_name_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_taxon_name.name).to eq('aus')
      expect(@s.type_of_relationships.to_a).to eq(@s.taxon_name_relationships.to_a)
      expect(@s.type_of_relationships.first.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@s.type_of_relationships.first.object_taxon_name).to eq(@g)
    end
  end

  context 'validation' do
    before do
      protonym.valid?
    end
    specify 'name' do
      expect(protonym.errors.include?(:name)).to be_true
    end
  end

  context 'soft_validation' do
    before(:all) do
      @subspecies = FactoryGirl.create(:iczn_subspecies)
      @variety = FactoryGirl.create(:icn_variety)

      @kingdom = @subspecies.ancestor_at_rank('kingdom')
      @family = @subspecies.ancestor_at_rank('family')
      @subfamily = @subspecies.ancestor_at_rank('subfamily')
      @tribe = @subspecies.ancestor_at_rank('tribe')
      @genus = @subspecies.ancestor_at_rank('genus')
      @subgenus = @subspecies.ancestor_at_rank('subgenus')
      @species = @subspecies.ancestor_at_rank('species')
      @kingdom.soft_validate
      @family.soft_validate
      @subfamily.soft_validate
      @tribe.soft_validate
      @genus.soft_validate
      @subgenus.soft_validate
      @species.soft_validate

      @source = FactoryGirl.create(:valid_bibtex_source, year: 1940, author: 'Dmitriev')
    end

    context 'valid parent rank' do
      specify 'parent rank should be valid' do
        taxa = @subspecies.ancestors + [@subspecies] + @variety.ancestors + [@variety]
        taxa.each do |t|
          t.soft_validate
          expect(t.soft_validations.messages_on(:rank_class).empty?).to be_true
        end
      end
      specify 'invalid parent rank' do
        t = FactoryGirl.build(:iczn_subgenus, parent: @family)
        t.soft_validate
        expect(t.soft_validations.messages_on(:rank_class).empty?).to be_false
      end
    end

    context 'year and source do not match' do
      specify 'A taxon had not been described at the date of the reference' do
        p = FactoryGirl.build(:relationship_species, name: 'aus', year_of_publication: 2000, source: @source)
        p.soft_validate
        expect(p.soft_validations.messages_on(:source_id).empty?).to be_false
        p.year_of_publication = 1940
        p.soft_validate
        expect(p.soft_validations.messages_on(:source_id).empty?).to be_true
      end
      specify 'A combination is older than the taxon' do
      c = FactoryGirl.create(:species_combination, year_of_publication: 1850, source: @source)
      c.soft_validate
        expect(c.soft_validations.messages_on(:source_id).empty?).to be_false
        expect(c.soft_validations.messages_on(:year_of_publication).empty?).to be_false
    end
    end

    context 'missing_fields' do
      specify "source is missing" do
          expect(@species.soft_validations.messages_on(:source_id).empty?).to be_false
          expect(@species.soft_validations.messages_on(:verbatim_author).empty?).to be_true
          expect(@species.soft_validations.messages_on(:year_of_publication).empty?).to be_true
        end
      specify 'author and year are missing' do
          expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_false
          expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_false
        end
      specify 'fix author and year' do
          @source.update(year: 1758, author: 'Linnaeus')
          @source.save
          @kingdom.source = @source
          @kingdom.soft_validate
          expect(@kingdom.soft_validations.messages_on(:verbatim_author).count).to be > 0
          expect(@kingdom.soft_validations.messages_on(:year_of_publication).count).to be > 0
          @kingdom.fix_soft_validations
          @kingdom.soft_validate
          expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_true
          expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_true
          expect(@kingdom.verbatim_author).to eq('Linnaeus')
          expect(@kingdom.year_of_publication).to eq(1758)
        end
    end

    context 'coordinated taxa' do
      specify 'mismatching author in genus' do
        @genus.verbatim_author = 'Foo'
        @subgenus.original_combination_genus = @genus
        @genus.save
        @subgenus.save
        @genus.soft_validate
        @subgenus.soft_validate
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        expect(@subgenus.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        expect(@subgenus.soft_validations.messages_on(:base).empty?).to be_false
      end
      specify 'mismatching author, year and original genus in family' do
          @subfamily.verbatim_author = 'Foo'
          @tribe.verbatim_author = 'Aaa'
          @tribe.name = 'Typhlocybini'
          @tribe.year_of_publication = 2013
          @subfamily.type_genus = @genus
          @subfamily.save
          @tribe.save
          @subfamily.soft_validate
          expect(@subfamily.soft_validations.messages_on(:verbatim_author).empty?).to be_false
          expect(@subfamily.soft_validations.messages_on(:year_of_publication).empty?).to be_false
          expect(@subfamily.soft_validations.messages_on(:base).empty?).to be_false
        end
    end

    context 'missing relationships' do
      specify 'original genus' do
        expect(@subspecies.soft_validations.messages_on(:base).include?('Original genus is missing')).to be_true
      end
      specify 'type species or genus' do
        expect(@genus.soft_validations.messages_on(:base).include?('Type species is not selected')).to be_true
        expect(@family.soft_validations.messages_on(:base).include?('Type genus is not selected')).to be_true
      end
    end

    context 'problematic relationships' do
      specify 'inapropriate type genus' do
          @family.type_genus = @genus
          @family.soft_validate
          expect(@family.soft_validations.messages_on(:base).include?('Type genus should have the same initial letters as the family-group name')).to be_true
          @genus.name = 'Cus'
          @genus.save
          @family.save
          @family.soft_validate
          expect(@family.soft_validations.messages_on(:base).include?('Type genus should have the same initial letters as the family-group name')).to be_false
        end
      specify 'type genus in wrong subfamily' do
          other_subfamily = FactoryGirl.create(:iczn_subfamily, name: 'Cinae', parent: @family)
          other_subfamily.type_genus = @genus
          other_subfamily.save
          other_subfamily.soft_validate
          @genus.soft_validate
          expect(other_subfamily.soft_validations.messages_on(:base).include?('Type genus should have the same initial letters as the family-group name')).to be_false
        end
    end
  end
end
