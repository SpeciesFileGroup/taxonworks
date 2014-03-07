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
    Source.delete_all
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
        expect(@protonym).to respond_to(:original_genus)
        expect(@protonym).to respond_to(:original_subgenus)
        expect(@protonym).to respond_to(:original_section)
        expect(@protonym).to respond_to(:original_subsection)
        expect(@protonym).to respond_to(:original_series)
        expect(@protonym).to respond_to(:original_subseries)
        expect(@protonym).to respond_to(:original_species)
        expect(@protonym).to respond_to(:original_subspecies)
        expect(@protonym).to respond_to(:original_variety)
        expect(@protonym).to respond_to(:original_subvariety)
        expect(@protonym).to respond_to(:original_form)
        expect(@protonym).to respond_to(:source_classified_as)
      end
      specify 'type_of_relationships' do
        expect(@protonym.type_of_relationships.collect{|i| i.id}).to eq([@species_type_of_genus.id])
      end
      specify 'type_of_taxon_names' do
        expect(@protonym.type_of_taxon_names).to eq([@genus])
      end
      specify 'type species' do
        expect(@genus.type_species). to eq(@protonym)
      end
      specify 'type species relationship' do
        expect(@genus.type_species_relationship.id). to eq(@species_type_of_genus.id)
      end
      specify 'type of genus' do
        expect(@protonym.type_of_genus.first). to eq(@genus)
      end
      specify 'type of genus relationship' do
        expect(@protonym.type_of_genus_relationships.first.id). to eq(@species_type_of_genus.id)
      end
    end

    context 'has_one' do
      TaxonNameRelationship.descendants.each do |d|
        if d.respond_to?(:assignment_method) && (not d.name.to_s =~ /TaxonNameRelationship::Combination/)
          if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn)/
            relationship = "#{d.assignment_method}_relationship".to_sym
            relationships = "#{d.inverse_assignment_method}_relationships".to_sym
          elsif d.name.to_s =~ /TaxonNameRelationship::(OriginalCombination|Typification|SourceClassifiedAs)/
            relationship = "#{d.inverse_assignment_method}_relationship".to_sym
            relationships = "#{d.assignment_method}_relationships".to_sym
          end

          specify relationship do
            expect(@protonym).to respond_to(relationship)
          end
          specify relationships do
            expect(@protonym).to respond_to(relationships)
          end
          specify d.assignment_method.to_s do
            expect(@protonym).to respond_to(d.assignment_method.to_sym)
          end
          specify d.inverse_assignment_method.to_s do
            expect(@protonym).to respond_to(d.inverse_assignment_method.to_sym)
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
          extra_type_relation = FactoryGirl.build_stubbed(:taxon_name_relationship,
                                                  subject_taxon_name: @genus,
                                                  object_taxon_name: @family,
                                                  type: 'TaxonNameRelationship::Typification::Family')
          # Handled by TaxonNameRelationship validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]
          expect(extra_type_relation.valid?).to be_false
        end
      end

      context 'latinized' do
        specify 'has at most one latinization' do
          c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
          c2 = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Ajective')
          expect(c2.valid?).to be_false
        end
      end

      context 'original description' do
        specify 'original_combination_source' do
          expect(@protonym).to respond_to(:original_combination_source)
        end

        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form}.each do |rank|
          method = "original_#{rank}_relationship"
          specify method do
            expect(@protonym).to respond_to(method)
          end 
        end

        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form}.each do |rank|
          method = "original_#{rank}"
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
      expect(@s.original_genus = @o).to be_true
      expect(@s.save).to be_true
      expect(@s.original_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_genus_relationship.subject_taxon_name).to eq(@o)
      expect(@s.original_genus_relationship.object_taxon_name).to eq(@s)
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
      first_original_subgenus_relation = FactoryGirl.build(:taxon_name_relationship_original_combination,
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
    specify 'synonym has at most one valid name' do
      genus = FactoryGirl.create(:relationship_genus, name: 'Cus', parent: @f)
      genus.iczn_set_as_subjective_synonym_of = @g
      expect(genus.save).to be_true
      genus.iczn_set_as_synonym_of = @o
      expect(genus.save).to be_true
      expect(genus.taxon_name_relationships.count).to be(1)
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
      @subtribe = @subspecies.ancestor_at_rank('subtribe')
      @genus = @subspecies.ancestor_at_rank('genus')
      @subgenus = @subspecies.ancestor_at_rank('subgenus')
      @species = @subspecies.ancestor_at_rank('species')
      @subtribe.source = @tribe.source
      @subtribe.save
      @subgenus.source = @genus.source
      @subgenus.save

      #TODO citeproc gem doesn't currently support lastname without firstname
      @source = FactoryGirl.create(:valid_source_bibtex, year: 1940, author: 'Dmitriev, D.')
    end

    context 'validat project_id' do
      specify 'project_id = 1' do
        expect(@subspecies.project_id).to eq(1)
      end
    end

    context 'valid parent rank' do
      specify 'parent rank should be valid' do
        taxa = @subspecies.ancestors + [@subspecies] + @variety.ancestors + [@variety]
        taxa.each do |t|
          t.soft_validate(:validate_parent_rank)
          expect(t.soft_validations.messages_on(:rank_class).empty?).to be_true
        end
      end
      specify 'invalid parent rank' do
        t = FactoryGirl.build(:iczn_subgenus, parent: @family)
        t.soft_validate(:validate_parent_rank)
        expect(t.soft_validations.messages_on(:rank_class).empty?).to be_false
      end
    end

    context 'year and source do not match' do
      specify 'A taxon had not been described at the date of the reference' do
        p = FactoryGirl.build(:relationship_species, name: 'aus', year_of_publication: 1940, source: @source, parent: @genus)
        p.soft_validate(:source_older_then_description)
        expect(p.soft_validations.messages_on(:source_id).empty?).to be_true
        p.year_of_publication = 2000
        p.soft_validate(:source_older_then_description)
        expect(p.soft_validations.messages_on(:source_id).empty?).to be_false
      end
    end

    context 'missing_fields' do
      specify "source author, year are missing" do
        @species.soft_validate(:missing_fields)
        expect(@species.soft_validations.messages_on(:source_id).empty?).to be_true
        expect(@species.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(@species.soft_validations.messages_on(:year_of_publication).empty?).to be_true
      end
      specify 'author and year are missing' do
        @kingdom.soft_validate(:missing_fields)
        expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_false
      end
      specify 'fix author and year from the source' do
        #TODO citeproc gem doesn't currently support lastname without firstname
        @source.update(year: 1758, author: 'Linnaeus, C.')
        @source.save
        @kingdom.source = @source
        @kingdom.soft_validate(:missing_fields)
        expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_false
        @kingdom.fix_soft_validations  # get author and year from the source
        @kingdom.soft_validate(:missing_fields)
        expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_true
        expect(@kingdom.verbatim_author).to eq('Linnaeus, C.')
        expect(@kingdom.year_of_publication).to eq(1758)
      end
    end

    context 'coordinated taxa' do
      specify 'mismatching author in genus' do
        sgen = FactoryGirl.create(:iczn_subgenus, verbatim_author: nil, year_of_publication: nil, parent: @genus, source: @genus.source)
        sgen.original_genus = @genus
        expect(sgen.save).to be_true
        @genus.reload
        @genus.soft_validate(:validate_coordinated_names)
        sgen.soft_validate(:validate_coordinated_names)
        #genus and subgenus have different author
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        #genus and subgenus have different year
        expect(sgen.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        #genus and subgenus have different year
        expect(sgen.soft_validations.messages_on(:year_of_publication).empty?).to be_false

        sgen.fix_soft_validations

        @genus.soft_validate(:validate_coordinated_names)
        sgen.soft_validate(:validate_coordinated_names)
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(sgen.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(sgen.soft_validations.messages_on(:year_of_publication).empty?).to be_true
      end
      specify 'mismatching author, year and type genus in family' do
        tribe = FactoryGirl.create(:iczn_tribe, name: 'Typhlocybini', verbatim_author: nil, year_of_publication: nil, parent: @subfamily)
        genus = FactoryGirl.create(:relationship_genus, verbatim_author: 'Dmitriev', name: 'Typhlocyba', year_of_publication: 2013, parent: tribe)
        @subfamily.type_genus = genus
        expect(@subfamily.save).to be_true
        @subfamily.soft_validate(:validate_coordinated_names)
        tribe.soft_validate(:validate_coordinated_names)
        #author in tribe and subfamily are different
        expect(tribe.soft_validations.messages_on(:verbatim_author).empty?).to be_false
        #year in tribe and subfamily are different
        expect(tribe.soft_validations.messages_on(:year_of_publication).empty?).to be_false
        #type in tribe and subfamily are different
        expect(tribe.soft_validations.messages_on(:base).empty?).to be_false

        tribe.fix_soft_validations

        tribe.soft_validate(:validate_coordinated_names)
        expect(tribe.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(tribe.soft_validations.messages_on(:year_of_publication).empty?).to be_true
        expect(tribe.soft_validations.messages_on(:base).empty?).to be_true
        @subfamily.type_genus = nil
        expect(@subfamily.save).to be_true
      end
      specify 'mismatching author and year in incorrect_original_spelling' do
        s1 = FactoryGirl.create(:relationship_species, name: 'aus', verbatim_author: 'Dmitriev', year_of_publication: 2000, parent: @genus)
        s2 = FactoryGirl.create(:relationship_species, name: 'bus', verbatim_author: nil, year_of_publication: nil, parent: @genus)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling')
        s2.soft_validate(:validate_coordinated_names)
        #author in speciec and incorrect original spelling are different
        expect(s2.soft_validations.messages_on(:verbatim_author).count).to eq(1)
        #year in speciec and incorrect original spelling are different
        expect(s2.soft_validations.messages_on(:year_of_publication).count).to eq(1)
        s2.fix_soft_validations
        s2.soft_validate(:validate_coordinated_names)
        expect(s2.soft_validations.messages_on(:verbatim_author).empty?).to be_true
        expect(s2.soft_validations.messages_on(:year_of_publication).empty?).to be_true
      end
      specify 'mismatching type specimens' do
        ssp = FactoryGirl.create(:iczn_subspecies, name: 'vitis', parent: @species)
        type_material = FactoryGirl.create(:valid_type_material, protonym: ssp)
        @species.soft_validate(:validate_coordinated_names)
        ssp.soft_validate(:validate_coordinated_names)
        expect(@species.soft_validations.messages_on(:base).count).to eq(1)
        expect(ssp.soft_validations.messages_on(:base).count).to eq(1)
        @species.fix_soft_validations
        @species.soft_validate(:validate_coordinated_names)
        ssp.soft_validate(:validate_coordinated_names)
        expect(@species.soft_validations.messages_on(:base).empty?).to be_true
        expect(ssp.soft_validations.messages_on(:base).empty?).to be_true
      end
    end

    context 'missing relationships' do
      specify 'type genus and nominotypical subfamily' do
        #missing nominotypical subfamily
        @subfamily.soft_validate(:single_sub_taxon)
        expect(@subfamily.soft_validations.messages_on(:base).count).to eq(1)
        #missign type genus
        @subfamily.soft_validate(:missing_relationships)
        expect(@subfamily.soft_validations.messages_on(:base).count).to eq(1)
        g = FactoryGirl.create(:iczn_genus, name: 'Typhlocyba', parent: @subfamily)
        r = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: @subfamily, type: 'TaxonNameRelationship::Typification::Family' )
        @subfamily.soft_validate
        expect(@subfamily.soft_validations.messages_on(:base).empty?).to be_false
        @subfamily.fix_soft_validations
        @subfamily.reload
        expect(@subfamily.valid?).to be_true
        @subfamily.soft_validate
        expect(@subfamily.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'only one subtribe in a tribe' do
        @subtribe.soft_validate(:single_sub_taxon)
        expect(@subtribe.soft_validations.messages_on(:base).empty?).to be_false
        other_subtribe = FactoryGirl.create(:iczn_subtribe, name: 'Aina', parent: @tribe)
        expect(other_subtribe.valid?).to be_true
        @subtribe.reload
        @subtribe.type_genus = @genus
        @tribe.type_genus = @genus
        @subtribe.soft_validate(:single_sub_taxon)
        expect(@subtribe.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'type species or genus' do
        @genus.soft_validate(:missing_relationships)
        @family.soft_validate(:missing_relationships)
        # type species is not selected
        expect(@genus.soft_validations.messages_on(:base).count).to eq(1)
        # type genus is not selected
        expect(@family.soft_validations.messages_on(:base).count).to eq(1)
      end
      specify 'type specimen is not selected' do
        @species.soft_validate(:primary_types)
        expect(@species.soft_validations.messages_on(:base).count).to eq(1)
      end
      specify 'more than one type is selected' do
        t1 = FactoryGirl.create(:valid_type_material, protonym: @species, type_type: 'neotype')
        t2 = FactoryGirl.create(:valid_type_material, protonym: @species, type_type: 'holotype')
        @species.soft_validate(:primary_types)
        expect(@species.soft_validations.messages_on(:base).count).to eq(1)
      end
    end
    context 'missing classifications' do
      specify 'gender of genus is not selected' do
        @genus.soft_validate(:missing_classifications)
        expect(@genus.soft_validations.messages_on(:base).count).to eq(1)
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
        @genus.soft_validate(:missing_classifications)
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'part of speech of species is not selected' do
        @species.soft_validate(:missing_classifications)
        expect(@species.soft_validations.messages_on(:base).count).to eq(1)
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition')
        @species.soft_validate(:missing_classifications)
        expect(@species.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'possible gender' do
        g = FactoryGirl.create(:relationship_genus, name: 'Cyclops', parent: @family)
        g.soft_validate(:missing_classifications)
        expect(g.soft_validations.messages_on(:base).first =~ /masculine/).to be_true
      end
      specify 'missing alternative spellings for species participle' do
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Participle')
        @species.soft_validate(:species_gender_agreement)
        expect(@species.soft_validations.messages_on(:masculine_name).count).to eq(1)
        expect(@species.soft_validations.messages_on(:feminine_name).count).to eq(1)
        expect(@species.soft_validations.messages_on(:neuter_name).count).to eq(1)
        c1.destroy
      end
      specify 'unnecessary alternative spellings for species noun' do
        s = FactoryGirl.create(:relationship_species, parent: @genus, masculine_name: 'foo', feminine_name: 'foo', neuter_name: 'foo')
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase')
        s.soft_validate(:species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).count).to eq(1)
        expect(s.soft_validations.messages_on(:feminine_name).count).to eq(1)
        expect(s.soft_validations.messages_on(:neuter_name).count).to eq(1)
      end
      specify 'unproper noun names' do
        s = FactoryGirl.create(:relationship_species, parent: @genus, masculine_name: 'vita', feminine_name: 'vitus', neuter_name: 'viter')
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
        s.soft_validate(:species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).count).to eq(1)
        expect(s.soft_validations.messages_on(:feminine_name).count).to eq(1)
        expect(s.soft_validations.messages_on(:neuter_name).count).to eq(1)
      end
      specify 'proper noun names' do
        s = FactoryGirl.create(:relationship_species, parent: @genus, masculine_name: 'niger', feminine_name: 'nigra', neuter_name: 'nigrum')
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
        s.soft_validate(:species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).empty?).to be_true
        expect(s.soft_validations.messages_on(:feminine_name).empty?).to be_true
        expect(s.soft_validations.messages_on(:neuter_name).empty?).to be_true
      end
      specify 'species matches genus' do
        s = FactoryGirl.create(:relationship_species, parent: @genus, name: 'niger')
        c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
        c2 = FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
        s.soft_validate(:species_gender_agreement)
        expect(s.soft_validations.messages_on(:name).count).to eq(1)
        c1.destroy
      end
    end

    context 'problematic relationships' do
      specify 'missing type genus genus' do
        gen = FactoryGirl.create(:iczn_genus, name: 'Cus', parent: @family)
        @family.soft_validate(:missing_relationships)
        @family.type_genus = gen
        expect(@family.save).to be_true
        @family.soft_validate(:missing_relationships)
        expect(@family.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'type genus in wrong subfamily' do
        other_subfamily = FactoryGirl.create(:iczn_subfamily, name: 'Cinae', parent: @family)
        gen = FactoryGirl.create(:iczn_genus, name: 'Cus', parent: other_subfamily)
        gen_syn = FactoryGirl.create(:iczn_genus, name: 'Dus', parent: other_subfamily)
        r = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: other_subfamily, type: 'TaxonNameRelationship::Typification::Family' )
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: gen_syn, object_taxon_name: gen, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym' )
        expect(r.save).to be_true
        other_subfamily.reload
        @genus.reload
        other_subfamily.soft_validate(:type_placement)
        @genus.soft_validate(:type_placement)
        #type genus of subfamily is not included in this subfamily
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_false
        #genus is a type for subfamily, but is not included there
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_false

        r.subject_taxon_name = gen # valid genus is a type genus
        expect(r.save).to be_true
        other_subfamily.reload
        other_subfamily.soft_validate(:type_placement)
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_true

        r.subject_taxon_name = gen_syn # synonym is a type genus
        expect(r.save).to be_true
        other_subfamily.reload
        other_subfamily.soft_validate(:type_placement)
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'mismatching' do
        @genus.type_species_by_monotypy = @species
        @subgenus.type_species_by_original_monotypy = @species
        expect(@genus.save).to be_true
        expect(@subgenus.save).to be_true
        @genus.reload
        @subgenus.reload
        @genus.soft_validate(:validate_coordinated_names)
        #The type species does not match with the type species of the coordinated subgenus
        expect(@genus.soft_validations.messages_on(:base).count).to eq(1)
        @genus.fix_soft_validations
        @genus.soft_validate(:validate_coordinated_names)
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'incertae sedis' do
        species = FactoryGirl.create(:relationship_species, parent: @family)
        expect(species.valid?).to be_true
        species.soft_validate(:validate_parent_rank)
        expect(species.soft_validations.messages_on(:rank_class).count).to eq(1)
        species.iczn_uncertain_placement = @family
        expect(species.save).to be_true
        species.soft_validate(:validate_parent_rank)
        expect(species.soft_validations.messages_on(:rank_class).empty?).to be_true
        species.parent = @genus
        expect(species.valid?).to be_false
      end
      specify 'parent priority' do
        subgenus = FactoryGirl.create(:iczn_subgenus, year_of_publication: 1758, source: nil, parent: @genus)
        subgenus.soft_validate(:parent_priority)
        expect(subgenus.soft_validations.messages_on(:base).count).to eq(1)
        subgenus.year_of_publication = 2000
        subgenus.soft_validate(:parent_priority)
        expect(subgenus.soft_validations.messages_on(:base).empty?).to be_true
      end
    end

    context 'single sub taxon in the nominal' do
      specify 'single nominotypical taxon' do
        @subgenus.soft_validate(:single_sub_taxon)
        #single subgenus in the nominal genus
        expect(@subgenus.soft_validations.messages_on(:base).count).to eq(1)
      end
    end

    context 'missing synonym relationship' do
      specify 'same type species' do
        g1 = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: @family)
        g2 = FactoryGirl.create(:relationship_genus, name: 'Bus', parent: @family)
        s1 = FactoryGirl.create(:relationship_species, name: 'cus', parent: g1)
        g1.type_species = s1
        g2.type_species = s1
        expect(g1.save).to be_true
        expect(g2.save).to be_true
        g1.soft_validate(:homotypic_synonyms)
        expect(g1.soft_validations.messages_on(:base).count).to eq(1)
        g1.iczn_set_as_unnecessary_replaced_name = g2
        expect(g1.save).to be_true
        g1.soft_validate(:homotypic_synonyms)
        expect(g1.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'same type specimen' do
        s1 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryGirl.create(:relationship_species, name: 'cus', parent: @genus)
        t1 = FactoryGirl.create(:valid_type_material, protonym: s1, type_type: 'holotype')
        t2 = FactoryGirl.create(:valid_type_material, protonym: s2, type_type: 'neotype', biological_object_id: t1.biological_object_id)
        expect(s1.save).to be_true
        expect(s2.save).to be_true
        s1.soft_validate(:homotypic_synonyms)
        expect(s1.soft_validations.messages_on(:base).count).to eq(1)
        s1.iczn_set_as_unjustified_emendation_of = s2
        expect(s1.save).to be_true
        s1.soft_validate(:homotypic_synonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'primary homonym' do
        s1 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        s1.original_genus = @genus
        s2.original_genus = @genus
        expect(s1.save).to be_true
        expect(s2.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).count).to eq(1)
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClassification::Iczn::Unavailable, taxon_name: s1)
        expect(s1.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'primary homonym with alternative spelling' do
        s1 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryGirl.create(:relationship_species, name: 'ba', parent: @genus)
        s1.original_genus = @genus
        s2.original_genus = @genus
        expect(s1.save).to be_true
        expect(s2.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).count).to eq(1)
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClassification::Iczn::Unavailable, taxon_name: s1)
        expect(s1.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'secondary homonym' do
        s1 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        expect(s1.save).to be_true
        expect(s2.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).count).to eq(1)
        s1.iczn_set_as_homonym_of = s2
        expect(s1.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'secondary homonym with alternative spelling' do
        s1 = FactoryGirl.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryGirl.create(:relationship_species, name: 'ba', parent: @genus)
        expect(s1.save).to be_true
        expect(s2.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).count).to eq(1)
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClassification::Iczn::Unavailable, taxon_name: s1)
        expect(s1.save).to be_true
        s1.soft_validate(:potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'genus homonym' do
        g1 = FactoryGirl.create(:relationship_genus, name: 'Bbbus', parent: @family, year_of_publication: 1900)
        g2 = FactoryGirl.create(:relationship_genus, name: 'Cccus', parent: @family)
        g3 = FactoryGirl.create(:iczn_subgenus, name: 'Bbbus', parent: g2, year_of_publication: 1850)
        expect(g1.save).to be_true
        expect(g2.save).to be_true
        expect(g3.save).to be_true
        g1.soft_validate(:potential_homonyms)
        g2.soft_validate(:potential_homonyms)
        g3.soft_validate(:potential_homonyms)
        expect(g1.soft_validations.messages_on(:base).count).to eq(1)
        expect(g2.soft_validations.messages_on(:base).empty?).to be_true
        expect(g3.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'family homonym alternative spelling' do
        f1 = FactoryGirl.create(:relationship_family, name: 'Bbbidae', parent: @kingdom, year_of_publication: 1900)
        f2 = FactoryGirl.create(:relationship_family, name: 'Cccidae', parent: @kingdom)
        f3 = FactoryGirl.create(:iczn_subfamily, name: 'Bbbinae', parent: f2, year_of_publication: 1800)
        expect(f1.save).to be_true
        expect(f2.save).to be_true
        expect(f3.save).to be_true
        f1.soft_validate(:potential_homonyms)
        f2.soft_validate(:potential_homonyms)
        f3.soft_validate(:potential_homonyms)
        expect(f1.soft_validations.messages_on(:base).count).to eq(1)
        expect(f2.soft_validations.messages_on(:base).empty?).to be_true
        expect(f3.soft_validations.messages_on(:base).empty?).to be_true
      end
      specify 'homonym without replacement name' do
        g1 = FactoryGirl.create(:relationship_genus, name: 'Bbbus', parent: @family, year_of_publication: 1900)
        g2 = FactoryGirl.create(:relationship_genus, name: 'Cccus', parent: @family)
        g3 = FactoryGirl.create(:iczn_subgenus, name: 'Bbbus', parent: g2, year_of_publication: 1850)
        g3.type_species = @species
        g3.iczn_set_as_homonym_of = g1
        expect(g3.save).to be_true
        g3.soft_validate(:missing_relationships)
        expect(g3.soft_validations.messages_on(:base).count).to eq(1)
        g3.iczn_set_as_synonym_of = g2
        expect(g3.save).to be_true
        g3.soft_validate(:missing_relationships)
        expect(g3.soft_validations.messages_on(:base).empty?).to be_true
      end
    end
    context 'fossils' do
      pending 'validate that the extant species does not have extinct parent'
    end
  end

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
        @s.original_genus = @g   # @g 'TaxonNameRelationship::OriginalCombination::OriginalGenus' @s
        @s.save
        @s.reload
      end

      after(:all) do
        TaxonNameRelationship.delete_all
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
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClassification::Iczn::Available, taxon_name: @s)
        FactoryGirl.create(:taxon_name_classification, type_class: TaxonNameClassification::Iczn::Available::Valid, taxon_name: @g )
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
        expect(Protonym.without_taxon_name_classification('TaxonNameClassification::Iczn::Available')).to have(Protonym.count - 1).things
        expect(Protonym.without_taxon_name_classification('TaxonNameClassification::Iczn::Available::Valid')).to have(Protonym.count - 1).things
      end
 
      specify 'with_taxon_name_classification_base' do
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClassification::Iczn') ).to have(2).things
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClassification::Iczn::Available') ).to have(2).things
        expect(Protonym.with_taxon_name_classification_base('TaxonNameClassification::Iczn::Available::Valid') ).to have(1).things
      end
      specify 'with_taxon_name_classification_containing' do
        expect(Protonym.with_taxon_name_classification_containing('Iczn') ).to have(2).things
        expect(Protonym.with_taxon_name_classification_containing('Valid') ).to have(1).things
      end
    end
  end


end
