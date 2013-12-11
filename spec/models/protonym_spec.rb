require 'spec_helper'

describe Protonym do
  let(:protonym) { Protonym.new }
  before(:all) do
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
    @order = FactoryGirl.create(:iczn_order)
  end

  after(:all) do
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
  end

  context 'associations' do
    before(:all) do
      @family = FactoryGirl.create(:relationship_family, name: 'Aidae', parent: @order)
      @genus = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: @family)
      @protonym = FactoryGirl.create(:relationship_species, name: 'aus', parent: @genus)
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
        expect(@protonym).to respond_to(:original_combination_genus)
        expect(@protonym).to respond_to(:original_combination_subgenus)
        expect(@protonym).to respond_to(:original_combination_section)
        expect(@protonym).to respond_to(:original_combination_subsection)
        expect(@protonym).to respond_to(:original_combination_series)
        expect(@protonym).to respond_to(:original_combination_subseries)
        expect(@protonym).to respond_to(:original_combination_species)
        expect(@protonym).to respond_to(:original_combination_subspecies)
        expect(@protonym).to respond_to(:original_combination_variety)
        expect(@protonym).to respond_to(:original_combination_subvariety)
        expect(@protonym).to respond_to(:original_combination_form)
        expect(@protonym).to respond_to(:source_classified_as)
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
      @f = FactoryGirl.create(:relationship_family, name: 'Aidae', parent: @order)
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
      # Recast as the subclass
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
        p = FactoryGirl.build(:relationship_species, name: 'aus', year_of_publication: 1940, source: @source)
        p.soft_validate
        expect(p.soft_validations.messages_on(:source_id).empty?).to be_true
        p.year_of_publication = 2000
        p.soft_validate
        expect(p.soft_validations.messages_on(:source_id).empty?).to be_false
      end
      specify 'A combination is older than the taxon' do
        c = FactoryGirl.create(:species_combination, year_of_publication: 1850, source: @source)
        c.soft_validate
        expect(c.soft_validations.messages_on(:source_id).empty?).to be_false
        expect(c.soft_validations.messages_on(:year_of_publication).empty?).to be_false
        c.year_of_publication = 1940
        expect(c.save).to be_true
        c.soft_validate
        expect(c.soft_validations.messages_on(:source_id).empty?).to be_true
      end
    end

    context 'missing_fields' do
      specify "source author, year are missing" do
          expect(@species.soft_validations.messages_on(:source_id).empty?).to be_false
          expect(@species.soft_validations.messages_on(:verbatim_author).empty?).to be_true
          expect(@species.soft_validations.messages_on(:year_of_publication).empty?).to be_true
        end
      specify 'author and year are missing' do
        expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_false
      end
      specify 'fix author and year from the source' do
          @source.update(year: 1758, author: 'Linnaeus')
          @source.save
          @kingdom.source = @source
          @kingdom.soft_validate
          expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_false
          expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_false
          @kingdom.fix_soft_validations  # get author and year from the source
          @kingdom.soft_validate
          expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_true
          expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_true
          expect(@kingdom.verbatim_author).to eq('Linnaeus')
          expect(@kingdom.year_of_publication).to eq(1758)
        end
    end

    context 'coordinated taxa' do
      specify 'mismatching author in genus' do
        sgen = FactoryGirl.create(:iczn_subgenus, verbatim_author: 'Dmitriev', year_of_publication: 1999, parent: @genus)
        @genus.reload
        sgen.original_combination_genus = @genus
        sgen.type_species = @genus.type_species
        expect(sgen.save).to be_true
        @genus.soft_validate
        sgen.soft_validate
        #genus and subgenus have different author
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        expect(sgen.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        #genus and subgenus have different year
        expect(sgen.soft_validations.messages_on(:year_of_publication).empty?).to be_false
        #genus and subgenus have different original Genus
        expect(sgen.soft_validations.messages_on(:base).count).to be(2)

        sgen.fix_soft_validations

        sgen.verbatim_author = @genus.verbatim_author
        sgen.year_of_publication = @genus.year_of_publication
        sgen.original_combination_genus = nil
        expect(sgen.save).to be_true
        @genus.soft_validate
        sgen.soft_validate
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(sgen.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(sgen.soft_validations.messages_on(:year_of_publication).empty?).to be_true
        expect(sgen.soft_validations.messages_on(:base).count).to be(1)
      end
      specify 'mismatching author, year and type genus in family' do
          tribe = FactoryGirl.create(:iczn_tribe, name: 'Typhlocybini', verbatim_author: nil, year_of_publication: nil, parent: @family)
          genus = FactoryGirl.create(:iczn_genus, verbatim_author: 'Dmitriev', name: 'Typhlocyba', year_of_publication: 2013, parent: tribe)
          @subfamily.soft_validate
          tribe.soft_validate
          #author in tribe and subfamily are different
          expect(tribe.soft_validations.messages_on(:verbatim_author).empty?).to be_false
          #year in tribe and subfamily are different
          expect(tribe.soft_validations.messages_on(:year_of_publication).empty?).to be_false
          #type in tribe and subfamily are different
          expect(tribe.soft_validations.messages_on(:base).empty?).to be_false
          tribe.type_genus = genus
          tribe.verbatim_author = 'Dmitriev'
          tribe.year_of_publication = 2003
          expect(tribe.save).to be_true
          tribe.soft_validate
          expect(tribe.soft_validations.messages_on(:verbatim_author).empty?).to be_true
          expect(tribe.soft_validations.messages_on(:year_of_publication).empty?).to be_true
          expect(tribe.soft_validations.messages_on(:base).empty?).to be_true
        end
    end

    context 'missing relationships' do
      specify 'original genus' do
        #missing original genus
        expect(@subfamily.soft_validations.messages_on(:base).empty?).to be_false
        g = FactoryGirl.create(:iczn_genus, name: 'Typhlocyba')
        @subfamily.type_genus = g
        expect(@subfamily.save).to be_true
        @subfamily.soft_validate
        expect(@subfamily.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'type species or genus' do
        expect(@genus.soft_validations.messages_on(:base).include?('Type species is not selected')).to be_true
        expect(@family.soft_validations.messages_on(:base).include?('Type genus is not selected')).to be_true
      end
    end

    context 'problematic relationships' do
      specify 'inapropriate type genus' do
        gen = FactoryGirl.create(:iczn_genus, name: 'Aus', parent: @family)
        @family.type_genus = gen
        @family.soft_validate
        #family and type genus start in different first leter
        expect(@family.soft_validations.messages_on(:base).empty?).to be_false
        gen.name = 'Cus'
        expect(gen.save).to be_true
        expect(@family.save).to be_true
        @family.soft_validate
        expect(@family.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'type genus in wrong subfamily' do
        other_subfamily = FactoryGirl.create(:iczn_subfamily, name: 'Cinae', parent: @family)
        gen = FactoryGirl.create(:iczn_genus, name: 'Cus', parent: other_subfamily)
        gen.type_species = @species
        other_subfamily.type_genus = @genus
        expect(other_subfamily.save).to be_true
        other_subfamily.soft_validate
        @genus.soft_validate
        #type genus of subfamily is not included in this subfamily
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_false
        #genus is a type for subfamily, but is not included there
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_false
        other_subfamily.type_genus = gen
        expect(other_subfamily.save).to be_true
        expect(gen.save).to be_true
        other_subfamily.reload
        other_subfamily.soft_validate
        gen.soft_validate
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_true
      end
    end
  end

  specify 'restrict combination relationships to Combination' 

  context 'scopes' do
    before(:all) {
      TaxonName.delete_all 
      @species = FactoryGirl.create(:iczn_species)
      @s =  Protonym.where(name: 'vitis').first
      @g =  Protonym.where(name: 'Erythroneura', rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus').first
    }
    after(:all) {
      TaxonName.delete_all
    }
    before(:each) {
      TaxonNameRelationship.delete_all
    }

    specify 'named' do
      expect(Protonym.named('vitis')).to have(1).things
    end

    specify 'with_name_in_array' do
      expect(Protonym.with_name_in_array(['vitis'])).to have(1).things
      expect(Protonym.with_name_in_array(['vitis', 'Erythroneura' ])).to have(3).things # genus 2x
    end

    specify 'with_rank_class' do
      expect(Protonym.with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus')).to have(1).things
    end  

    specify 'with_base_of_rank_class' do
      expect(Protonym.with_base_of_rank_class('NomenclaturalRank::Iczn')).to have(11).things
      expect(Protonym.with_base_of_rank_class('FamilyGroup')).to have(0).things
    end

    specify 'with_rank_class_including' do
      expect(Protonym.with_rank_class_including('Iczn')).to have(11).things
      expect(Protonym.with_rank_class_including('GenusGroup')).to have(2).things
      expect(Protonym.with_rank_class_including('FamilyGroup')).to have(4).things # When we rename Higher this will work
    end

    specify 'descendants_of' do
      expect(Protonym.descendants_of(Protonym.named('vitis').first)).to have(0).things 
      expect( Protonym.descendants_of(Protonym.named('Erythroneura').with_rank_class_including('GenusGroup::Genus').first) ).to have(2).things 
    end

    specify 'ancestors_of' do
      expect(Protonym.ancestors_of(Protonym.named('vitis').first)).to have(11).things 
      expect(Protonym.ancestors_of(Protonym.named('Cicadellidae').first) ).to have(5).things 
      expect(Protonym.ancestors_of(Protonym.named('Cicadellidae').first).named('Arthropoda')).to have(1).things 
    end

    context 'relationships' do
      before(:each) do
        @s.original_combination_genus = @g   # @g 'TaxonNameRelationship::OriginalCombination::OriginalGenus' @s
        @s.save
        @s.reload
      end

      after(:all) do
        TaxonNameRelationships.delete_all
      end

      # Has *a* relationship
      specify 'with_taxon_name_relationships_as_subject' do
        expect(@g.all_taxon_name_relationships).to have(1).things
        expect(Protonym.named('Erythroneura').with_taxon_name_relationships_as_subject).to have(1).things
      end
      specify 'with_taxon_name_relationships_as_object' do
        expect(Protonym.named('vitis').with_taxon_name_relationships_as_object).to have(1).things
        expect(Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').with_taxon_name_relationships_as_object).to have(0).things
      end
      specify 'with_taxon_name_relationships' do 
        expect(Protonym.with_taxon_name_relationships).to have(2).things
        expect(Protonym.named('vitis').with_taxon_name_relationships).to have(1).things
        expect(Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').with_taxon_name_relationships).to have(1).things
        expect(Protonym.named('Erythroneurini').with_taxon_name_relationships).to have(0).things
      end

      # Specific relationship exists
      specify 'as_subject_with_taxon_name_relationship' do
        expect(Protonym.as_subject_with_taxon_name_relationship('TaxonNameRelationship::OriginalCombination::OriginalGenus')).to have(1).things
        expect(Protonym.as_subject_with_taxon_name_relationship('blorf')).to have(0).things
      end
      specify 'as_subject_with_taxon_name_relationship_base' do
        expect(Protonym.as_subject_with_taxon_name_relationship_base('TaxonNameRelationship::OriginalCombination')).to have(1).things
        expect(Protonym.as_subject_with_taxon_name_relationship_base('blorf')).to have(0).things
      end
      specify 'as_subject_with_taxon_name_relationship_containing' do
        expect(Protonym.as_subject_with_taxon_name_relationship_containing('OriginalCombination')).to have(1).things
        expect(Protonym.as_subject_with_taxon_name_relationship_containing('blorf')).to have(0).things
      end
      specify 'as_object_with_taxon_name_relationship' do
        expect(Protonym.as_object_with_taxon_name_relationship('TaxonNameRelationship::OriginalCombination::OriginalGenus')).to have(1).things
        expect(Protonym.as_object_with_taxon_name_relationship('blorf')).to have(0).things
      end
      specify 'as_object_with_taxon_name_relationship_base' do
        expect(Protonym.as_object_with_taxon_name_relationship_base('TaxonNameRelationship::OriginalCombination')).to have(1).things
        expect(Protonym.as_object_with_taxon_name_relationship_base('blorf')).to have(0).things
      end
      specify 'as_object_with_taxon_name_relationship_containing' do
        expect(Protonym.as_object_with_taxon_name_relationship_containing('OriginalCombination')).to have(1).things
        expect(Protonym.as_object_with_taxon_name_relationship_containing('blorf')).to have(0).things
      end
      specify 'with_taxon_name_relationship' do
        expect(Protonym.with_taxon_name_relationship('TaxonNameRelationship::OriginalCombination::OriginalGenus')).to have(2).things
      end

      # Any relationship doesn't exists
      specify 'without_subject_taxon_name_relationships' do
        expect(Protonym.named('vitis').without_subject_taxon_name_relationships).to have(1).things
        expect( Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').without_subject_taxon_name_relationships).to have(0).things
      end
      specify 'without_object_taxon_name_relationships' do
        expect(Protonym.named('vitis').without_object_taxon_name_relationships).to have(0).things
        expect( Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').without_object_taxon_name_relationships).to have(1).things
      end
      specify 'without_taxon_name_relationships' do 
        expect(Protonym.without_taxon_name_relationships).to have(Protonym.all.count - 2).things
        expect(Protonym.without_taxon_name_relationships.named('vitis')).to have(0).things
        expect(Protonym.named('Erythroneura').with_rank_class('NomenclaturalRank::Iczn::GenusGroup::Genus').without_taxon_name_relationships).to have(0).things
        expect(Protonym.named('Erythroneurini').without_taxon_name_relationships).to have(1).things
      end

      specify 'as_subject_without_taxon_name_relationship_base' do
        expect(Protonym.as_subject_without_taxon_name_relationship_base('TaxonNameRelationship')).to have(Protonym.all.count - 1).things
      end

    end

    context 'classifications' do
      before(:all) do
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClass::Iczn::Available, taxon_name: @s)
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClass::Iczn::Available::Valid, taxon_name: @g )
      end

      after(:all) do
        TaxonNameClassification.delete_all
      end

      specify 'with_taxon_name_classifications' do
        expect(Protonym.with_taxon_name_classifications).to have(2).things
      end
      specify 'without_taxon_name_classifications' do
        expect(Protonym.without_taxon_name_classifications).to have(Protonym.all.count - 2).things
      end

      specify 'without_taxon_name_classification' do
        expect(Protonym.without_taxon_name_classification('TaxonNameClass::Iczn::Available')).to have(Protonym.count - 1).things
        expect(Protonym.without_taxon_name_classification('TaxonNameClass::Iczn::Available::Valid')).to have(Protonym.count - 1).things
      end
 
      specify 'with_taxon_name_classification_base' do
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClass::Iczn') ).to have(2).things
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClass::Iczn::Available') ).to have(2).things
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClass::Iczn::Available::Valid') ).to have(1).things
      end
      specify 'with_taxon_name_classification_containing' do
        expect(Protonym.with_taxon_name_classification_containing('Iczn') ).to have(2).things
        expect(Protonym.with_taxon_name_classification_containing('Valid') ).to have(1).things
      end
    end
  end


end
