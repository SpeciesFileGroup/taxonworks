require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  before(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    TaxonNameHierarchy.delete_all
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    Citation.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:protonym) { Protonym.new }

  #TODO citeproc gem doesn't currently support lastname without firstname
  let(:source) { FactoryBot.create(:valid_source_bibtex, year: 1940, author: 'Dmitriev, D.')   }

  context 'soft_validation' do
    before(:each) do
      @subspecies = FactoryBot.create(:iczn_subspecies)
      @kingdom = @subspecies.ancestor_at_rank('kingdom')
      @family = @subspecies.ancestor_at_rank('family')
      @subfamily = @subspecies.ancestor_at_rank('subfamily')
      @tribe = @subspecies.ancestor_at_rank('tribe')
      @subtribe = @subspecies.ancestor_at_rank('subtribe')
      @genus = @subspecies.ancestor_at_rank('genus')
      @subgenus = @subspecies.ancestor_at_rank('subgenus')
      @species = @subspecies.ancestor_at_rank('species')
      @subtribe.source = @tribe.source # update_column(:source_id, @tribe.source.id)
      @subtribe.save

      # @subgenus.update_column(:source_id, @genus.source.id)
    
      @subgenus.source = @genus.source # update_column(:source_id, @genus.source.id)
      @subgenus.save
    end

    specify 'sanity check that project_id is set correctly in factories' do
      expect(@subspecies.project_id).to eq(1)
    end

    specify 'run all soft validations without error' do
      expect(protonym.soft_validate()).to be_truthy
    end

    context 'valid parent rank' do
      before {
        @variety = FactoryBot.create(:icn_variety)
      }

      specify 'parent rank should be valid' do
        taxa = @subspecies.ancestors + [@subspecies] + @variety.ancestors + [@variety]
        taxa.each do |t|
          t.soft_validate(only_sets: :validate_parent_rank)
          expect(t.soft_validations.messages_on(:rank_class).empty?).to be_truthy
        end
      end

      specify 'invalid parent rank' do
        t = FactoryBot.build(:iczn_subgenus, parent: @family)
        t.soft_validate(only_sets: :validate_parent_rank)
        expect(t.soft_validations.messages_on(:rank_class).empty?).to be_falsey
      end
    end

    context 'year and source do not match' do
      specify 'A taxon had not been described at the date of the reference' do
        p = FactoryBot.build(:relationship_species, name: 'aus', year_of_publication: 1940, source: source, parent: @genus)
        p.soft_validate(only_sets: :dates)
        expect(p.soft_validations.messages_on(:base).empty?).to be_truthy
        p.year_of_publication = 2000
        p.soft_validate(only_sets: :dates)
        expect(p.soft_validations.messages_on(:base).empty?).to be_falsey
      end
    end

    context 'missing_fields' do
      specify 'source author, year are missing' do
        @species.etymology = 'Test'
        @species.soft_validate(only_sets: :missing_fields)
        expect(@species.soft_validations.messages_on(:base).include?('Original citation pages are not recorded')).to be_truthy
        @species.origin_citation.pages = 1 if !@species.source.nil?
        @species.soft_validate(only_sets: :missing_fields)
        expect(@species.soft_validations.messages_on(:base).include?('Original citation pages are not recorded')).to be_falsey
        expect(@species.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
        expect(@species.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
      end
      specify 'page is out or range' do
        @genus.source.pages = '1-10, i-v'
        @genus.origin_citation.pages = '11'
        @genus.soft_validate(only_sets: :missing_fields)
        expect(@genus.soft_validations.messages_on(:base).include?('Original citation could be out of the source page range')).to be_truthy
        @genus.origin_citation.pages = '1'
        @genus.soft_validate(only_sets: :missing_fields)
        expect(@genus.soft_validations.messages_on(:base).include?('Original citation could be out of the source page range')).to be_falsey
        @genus.origin_citation.pages = '10'
        @genus.soft_validate(only_sets: :missing_fields)
        expect(@genus.soft_validations.messages_on(:base).include?('Original citation could be out of the source page range')).to be_falsey
        @genus.origin_citation.pages = '5'
        @genus.soft_validate(only_sets: :missing_fields)
        expect(@genus.soft_validations.messages_on(:base).include?('Original citation could be out of the source page range')).to be_falsey
      end
      specify 'etymology is missing' do
        @species.soft_validate(only_sets: :missing_fields)
        expect(@species.soft_validations.messages_on(:etymology).empty?).to be_falsey
        @species.etymology = 'Test'
        @species.soft_validate(only_sets: :missing_fields)
        expect(@species.soft_validations.messages_on(:etymology).empty?).to be_truthy
      end
      
      specify 'author and year are missing' do
        @kingdom.soft_validate(only_sets: :missing_fields)
        expect(@kingdom.soft_validations.messages_on(:verbatim_author).empty?).to be_falsey
        expect(@kingdom.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
        expect(@kingdom.soft_validations.messages_on(:etymology).empty?).to be_truthy
      end

      specify 'missing role' do
        @species.soft_validate(only_sets: :missing_roles)
        expect(@species.soft_validations.messages_on(:base).empty?).to be_falsey
        person= FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald')
        @species.taxon_name_authors << person
        @species.soft_validate(only_sets: :missing_roles)
        expect(@species.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'year is not required' do
        @genus.verbatim_author = @genus.source.authority_name
        @genus.year_of_publication = @genus.source.year
        @genus.save
        @genus.soft_validate(only_sets: :year_is_not_required)
        
        expect(@genus.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey

        @genus.fix_soft_validations

        @genus.soft_validate(only_sets: :year_is_not_required)
        expect(@genus.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
      end
      
      specify 'author is not required' do
        @genus.verbatim_author = 'Green'
        person= FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald')
        @genus.taxon_name_authors << person
        @genus.save
        @genus.soft_validate(only_sets: :author_is_not_required)
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_falsey
        @genus.fix_soft_validations
        @genus.soft_validate(only_sets: :author_is_not_required)
        expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
      end
      specify 'unneded fields' do
        g = FactoryBot.build(:iczn_genus, verbatim_author: 'Green', year_of_publication: '1995', parent: @genus.parent, source: @genus.source)
        person = FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald')
        g.taxon_name_authors << person
        g.save
        r3 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: @genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling')
        g.soft_validate(only_sets: :roles_are_not_required)
        expect(g.soft_validations.messages_on(:verbatim_author).empty?).to be_falsey
        expect(g.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
        expect(g.soft_validations.messages_on(:base).empty?).to be_falsey
        g.fix_soft_validations
        g.reload
        g.soft_validate(only_sets: :roles_are_not_required)
        expect(g.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
        expect(g.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
        expect(g.soft_validations.messages_on(:base).empty?).to be_truthy
      end
    end

    context 'coordinated taxa' do
      context 'mismatching author in genus' do
        before do 
          @sgen = FactoryBot.create(:iczn_subgenus, verbatim_author: nil, year_of_publication: nil, parent: @genus, source: @genus.source)
          @sgen.original_genus = @genus
          @sgen.save!
          @genus.reload
          @genus.soft_validate(only_sets: :validate_coordinated_names)
          @sgen.soft_validate(only_sets: :validate_coordinated_names)
        end

        specify 'genus and subgenus have different author' do
          expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_falsey
        end

        specify 'genus and subgenus have different year (error on verbatim_author)' do
          expect(@sgen.soft_validations.messages_on(:verbatim_author).empty?).to be_falsey
        end

        specify 'genus and subgenus have different year (error on year_of_publication)' do
          expect(@sgen.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
        end

        context 'when soft validation fixed' do
          before do
            @sgen.fix_soft_validations
            @genus.soft_validate(only_sets: :validate_coordinated_names)
            @sgen.soft_validate(only_sets: :validate_coordinated_names)
          end

          specify 'there are no verbatim_author validations on genus' do
            expect(@genus.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
          end

          specify 'there are no verbatim_author validations on subgenus' do
            expect(@sgen.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
          end

          specify 'there are no year_of_publication validations on subgenus' do
            expect(@sgen.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
          end
        end
      end

      specify 'mismatching author, year and type genus in family' do
        tribe = FactoryBot.create(:iczn_tribe, name: 'Typhlocybini', verbatim_author: nil, year_of_publication: nil, parent: @subfamily)
        genus = FactoryBot.create(:relationship_genus, verbatim_author: 'Dmitriev', name: 'Typhlocyba', year_of_publication: 2013, parent: tribe)
        tribe.source = nil
        @subfamily.type_genus = genus
        expect(@subfamily.save).to be_truthy
        @subfamily.soft_validate(only_sets: :validate_coordinated_names)
        tribe.soft_validate(only_sets: :validate_coordinated_names)
        #author in tribe and subfamily are different
        expect(tribe.soft_validations.messages_on(:verbatim_author).empty?).to be_falsey
        #year in tribe and subfamily are different
        expect(tribe.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
        #type in tribe and subfamily are different
        expect(tribe.soft_validations.messages_on(:base).empty?).to be_falsey

        tribe.fix_soft_validations
        tribe.soft_validate(only_sets: :validate_coordinated_names)
        expect(tribe.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
        expect(tribe.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
        expect(tribe.soft_validations.messages_on(:base).empty?).to be_truthy

        @subfamily.type_genus = nil
        expect(@subfamily.save).to be_truthy
      end

      specify 'mismatching author and year in incorrect_original_spelling' do
        s1 = FactoryBot.create(:relationship_species, name: 'aus', verbatim_author: 'Dmitriev', year_of_publication: 2000, parent: @genus)
        s2 = FactoryBot.create(:relationship_species, name: 'bus', verbatim_author: nil, year_of_publication: nil, parent: @genus)
        r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling')
        s2.soft_validate(only_sets: :validate_coordinated_names)
        #author in species and incorrect original spelling are different
        expect(s2.soft_validations.messages_on(:verbatim_author).size).to eq(1)
        #year in speciec and incorrect original spelling are different
        expect(s2.soft_validations.messages_on(:year_of_publication).size).to eq(1)
        s2.fix_soft_validations
        s2.soft_validate(only_sets: :validate_coordinated_names)
        expect(s2.soft_validations.messages_on(:verbatim_author).empty?).to be_truthy
        expect(s2.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
      end

      context 'mismatching type specimens' do
        before do
          @ssp1 = FactoryBot.create(:iczn_subspecies, name: 'vitis', parent: @species)
          type_material = FactoryBot.create(:valid_type_material, protonym: @ssp1)
          @species.soft_validate(only_sets: :validate_coordinated_names)
          @ssp1.soft_validate(only_sets: :validate_coordinated_names)
        end

        specify 'adds soft validation warnings' do
          expect(@species.soft_validations.messages_on(:base)).to include('The type specimen does not match with the type specimen of the coordinate subspecies')
          expect(@ssp1.soft_validations.messages_on(:base)).to include('The type specimen does not match with the type specimen of the coordinate species')
        end

        specify 'is fixable' do
          @ssp1.source = nil
          @ssp1.fix_soft_validations
          @species.fix_soft_validations
          @species.soft_validate(only_sets: :validate_coordinated_names)
          @ssp1.soft_validate(only_sets: :validate_coordinated_names)
          expect(@species.soft_validations.messages_on(:base).empty?).to be_truthy
          expect(@ssp1.soft_validations.messages_on(:base).empty?).to be_truthy
        end
      end
    end

    context 'missing relationships' do
      specify 'type genus and nominotypical subfamily' do
        #missing nominotypical subfamily
        @subfamily.soft_validate(only_sets: :single_sub_taxon)
        expect(@subfamily.soft_validations.messages_on(:base).size).to eq(1)
        #missign type genus
        @subfamily.soft_validate(only_sets: :missing_relationships)
        expect(@subfamily.soft_validations.messages_on(:base).size).to eq(1)
        g = FactoryBot.create(:iczn_genus, name: 'Typhlocyba', parent: @subfamily)
        r = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: @subfamily, type: 'TaxonNameRelationship::Typification::Family' )
        person = FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald')
        @subfamily.taxon_name_authors << person
        @subfamily.soft_validate
        expect(@subfamily.soft_validations.messages_on(:base).count).to eq(3)
        @subfamily.fix_soft_validations
        @subfamily.reload
        expect(@subfamily.valid?).to be_truthy
        @subfamily.origin_citation.pages = 1 if !@subfamily.source.nil?
        @subfamily.save
        @subfamily.soft_validate
        expect(@subfamily.soft_validations.messages_on(:base).count).to eq(0)
      end

      specify 'only one subtribe in a tribe' do
        @subtribe.soft_validate(only_sets: :single_sub_taxon)
        expect(@subtribe.soft_validations.messages_on(:base).empty?).to be_falsey
        other_subtribe = FactoryBot.create(:iczn_subtribe, name: 'Aina', parent: @tribe)
        expect(other_subtribe.valid?).to be_truthy
        @subtribe.reload
        @subtribe.type_genus = @genus
        @tribe.type_genus = @genus
        @subtribe.soft_validate(only_sets: :single_sub_taxon)
        expect(@subtribe.soft_validations.messages_on(:base).empty?).to be_truthy
      end
      specify 'type species' do
        @genus.soft_validate(only_sets: :missing_relationships)
        expect(@genus.soft_validations.messages_on(:base)).to include('Missing relationship: Type species is not selected')
      end
      specify 'type genus' do
        @family.soft_validate(only_sets: :missing_relationships)
        expect(@family.soft_validations.messages_on(:base)).to include('Missing relationship: Type genus is not selected')
      end
      specify 'type specimen is not selected' do
        @species.soft_validate(only_sets: :primary_types)
        expect(@species.soft_validations.messages_on(:base).size).to eq(1)
      end
      specify 'more than one type is selected' do
        t1 = FactoryBot.create(:valid_type_material, protonym: @species, type_type: 'syntype')
        t2 = FactoryBot.create(:valid_type_material, protonym: @species, type_type: 'holotype')
        @species.soft_validate(only_sets: :primary_types)
        expect(@species.soft_validations.messages_on(:base).size).to eq(3)
        expect(@species.soft_validations.messages_on(:base)).to include('More than one of primary types are selected. Uncheck the specimens which are not primary types for this taxon')
        expect(@species.soft_validations.messages_on(:base)).to include('Primary type repository is not set')
        expect(@species.soft_validations.messages_on(:base)).to include('Syntype repository is not set')
      end
    end

    context 'missing classifications' do
      specify 'gender of genus is not selected' do
        @genus.soft_validate(only_sets: :missing_classifications)
        expect(@genus.soft_validations.messages_on(:base).size).to eq(1)
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
        @genus.soft_validate(only_sets: :missing_classifications)
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'part of speech of species is not selected' do
        @species.soft_validate(only_sets: :missing_classifications)
        expect(@species.soft_validations.messages_on(:base).size).to eq(1)
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition')
        @species.soft_validate(only_sets: :missing_classifications)
        expect(@species.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'possible gender' do
        g = FactoryBot.create(:relationship_genus, name: 'Cyclops', parent: @family)
        g.soft_validate(only_sets: :missing_classifications)
        expect(g.soft_validations.messages_on(:base).first =~ /masculine/).to be_truthy
      end

      specify 'missing alternative spellings for species participle' do
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Participle')
        @species.soft_validate(only_sets: :species_gender_agreement)
        expect(@species.soft_validations.messages_on(:masculine_name).size).to eq(0)
        expect(@species.soft_validations.messages_on(:feminine_name).size).to eq(0)
        expect(@species.soft_validations.messages_on(:neuter_name).size).to eq(0)
        @species.masculine_name = nil
        @species.feminine_name = nil
        @species.neuter_name = nil
        @species.soft_validate(only_sets: :species_gender_agreement)
        expect(@species.soft_validations.messages_on(:masculine_name).size).to eq(1)
        expect(@species.soft_validations.messages_on(:feminine_name).size).to eq(1)
        expect(@species.soft_validations.messages_on(:neuter_name).size).to eq(1)
        c1.destroy
      end

      specify 'missmatching alternative spellings for species participle' do
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Participle')
        @species.masculine_name = 'foo'
        @species.feminine_name = 'foo'
        @species.neuter_name = 'foo'
        @species.soft_validate(only_sets: :species_gender_agreement)
        expect(@species.soft_validations.messages_on(:base)).to include('Species name does not match with either of three alternative forms')
        @species.masculine_name = @species.name
        @species.soft_validate(only_sets: :species_gender_agreement)
        expect(@species.soft_validations.messages_on(:base).empty?).to be_truthy
        c1.destroy
      end

      specify 'unnecessary alternative spellings for species noun' do
        s = FactoryBot.create(:relationship_species, parent: @genus, masculine_name: 'foo', feminine_name: 'foo', neuter_name: 'foo')
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase')
        s.soft_validate(only_sets: :species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).size).to eq(1)
        expect(s.soft_validations.messages_on(:feminine_name).size).to eq(1)
        expect(s.soft_validations.messages_on(:neuter_name).size).to eq(1)
      end

      specify 'unproper noun names (endings incorrect)' do
        s = FactoryBot.create(:relationship_species, parent: @genus, masculine_name: 'vita', feminine_name: 'vitus', neuter_name: 'vitis')
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
        s.soft_validate(only_sets: :species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).size).to eq(1)
        expect(s.soft_validations.messages_on(:feminine_name).size).to eq(1)
        expect(s.soft_validations.messages_on(:neuter_name).size).to eq(1)
      end

      specify 'proper noun names' do
        s = FactoryBot.create(:relationship_species, parent: @genus, masculine_name: 'niger', feminine_name: 'nigra', neuter_name: 'nigrum')
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
        s.soft_validate(only_sets: :species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).empty?).to be_truthy
        expect(s.soft_validations.messages_on(:feminine_name).empty?).to be_truthy
        expect(s.soft_validations.messages_on(:neuter_name).empty?).to be_truthy
      end

      specify 'species matches genus' do
        s = FactoryBot.create(:relationship_species, parent: @genus, name: 'niger')
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
        c2 = FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
        s.soft_validate(only_sets: :species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).size).to eq(0)
        s.feminine_name = nil
        s.masculine_name = nil
        s.neuter_name = nil
        s.soft_validate(only_sets: :species_gender_agreement)
        expect(s.soft_validations.messages_on(:masculine_name).size).to eq(1)
        c1.destroy
      end
    end

    context 'problematic relationships' do
      specify 'missing type genus genus' do
        gen = FactoryBot.create(:iczn_genus, name: 'Cus', parent: @family)
        @family.soft_validate(only_sets: :missing_relationships)
        @family.type_genus = gen
        expect(@family.save).to be_truthy
        @family.soft_validate(only_sets: :missing_relationships)
        expect(@family.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'type genus in wrong subfamily' do
        other_subfamily = FactoryBot.create(:iczn_subfamily, name: 'Cinae', parent: @family)
        gen = FactoryBot.create(:iczn_genus, name: 'Cus', parent: other_subfamily)
        gen_syn = FactoryBot.create(:iczn_genus, name: 'Dus', parent: other_subfamily)
        r = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: other_subfamily, type: 'TaxonNameRelationship::Typification::Family' )
        r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: gen_syn, object_taxon_name: gen, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym' )
        expect(r.save).to be_truthy
        other_subfamily.reload
        @genus.reload
        other_subfamily.soft_validate(only_sets: :type_placement)
        @genus.soft_validate(only_sets: :type_placement)
        #type genus of subfamily is not included in this subfamily
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_falsey
        #genus is a type for subfamily, but is not included there
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_falsey

        r.subject_taxon_name = gen # valid genus is a type genus
        expect(r.save).to be_truthy
        other_subfamily.reload
        other_subfamily.soft_validate(only_sets: :type_placement)
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_truthy

        r.subject_taxon_name = gen_syn # synonym is a type genus
        expect(r.save).to be_truthy
        other_subfamily.reload
        other_subfamily.soft_validate(only_sets: :type_placement)
        expect(other_subfamily.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'mismatching' do
        @genus.type_species_by_original_designation_or_monotypy = @species
        @subgenus.type_species_by_original_monotypy = @species
        expect(@genus.save).to be_truthy
        expect(@subgenus.save).to be_truthy
        @genus.reload
        @subgenus.reload
        @genus.soft_validate(only_sets: :validate_coordinated_names)
        #The type species does not match with the type species of the coordinate subgenus
        expect(@genus.soft_validations.messages_on(:base).size).to eq(1)
        @genus.fix_soft_validations
        @genus.soft_validate(only_sets: :validate_coordinated_names)
        expect(@genus.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'incertae sedis' do
        species = FactoryBot.create(:relationship_species, parent: @family)
        expect(species.valid?).to be_truthy
        species.soft_validate(only_sets: :validate_parent_rank)
        expect(species.soft_validations.messages_on(:rank_class).size).to eq(1)
        species.iczn_uncertain_placement = @family
        expect(species.save).to be_truthy
        species.soft_validate(only_sets: :validate_parent_rank)
        expect(species.soft_validations.messages_on(:rank_class).empty?).to be_truthy
        species.parent = @genus
        expect(species.valid?).to be_falsey
      end

      specify 'parent priority' do
        subgenus = FactoryBot.create(:iczn_subgenus, year_of_publication: 1758, source: nil, parent: @genus)
        subgenus.soft_validate(only_sets: :parent_priority)
        expect(subgenus.soft_validations.messages_on(:base).size).to eq(1)
        subgenus.year_of_publication = 2000
        subgenus.soft_validate(only_sets: :parent_priority)
        expect(subgenus.soft_validations.messages_on(:base).empty?).to be_truthy
      end
    end

    context 'single sub taxon in the nominal' do
      specify 'single nominotypical taxon' do
        @subgenus.soft_validate(only_sets: :single_sub_taxon)
        #single subgenus in the nominal genus
        expect(@subgenus.soft_validations.messages_on(:base).size).to eq(1)
      end
      specify 'single non nominotypical taxon' do
        @subgenus.name = 'Cus'
        @subgenus.save
        @subgenus.soft_validate(only_sets: :single_sub_taxon)
        expect(@subgenus.soft_validations.messages_on(:base).size).to eq(1)
        @subgenus.fix_soft_validations
        @subgenus.reload
        @subgenus.soft_validate(only_sets: :single_sub_taxon)
        expect(@subgenus.soft_validations.messages_on(:base).size).to eq(0)
      end
      specify 'single non nominotypical taxon and it is a synonym' do
        @subgenus.name = 'Cus'
        @subgenus.save
        TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: @subgenus, object_taxon_name: @genus)
        @subgenus.reload
        @subgenus.soft_validate(only_sets: :single_sub_taxon)
        expect(@subgenus.soft_validations.messages_on(:base).size).to eq(0)
      end
    end


    context 'missing synonym relationship' do

      specify 'same type species' do
        msg = 'Missing relationship: genus <i>Aus</i> should be a synonym of <i>Bus</i> Say, 1850 since they share the same type'
        g1 = FactoryBot.create(:relationship_genus, name: 'Aus', parent: @family)
        g2 = FactoryBot.create(:relationship_genus, name: 'Bus', parent: @family)
        s1 = FactoryBot.create(:relationship_species, name: 'cus', parent: g1)
        g1.type_species = s1
        g2.type_species = s1
        expect(g1.save).to be_truthy
        expect(g2.save).to be_truthy
        g1.soft_validate(only_sets: :homotypic_synonyms)
        expect(g1.soft_validations.messages_on(:base)).to include(msg)
      
        #  g1.iczn_set_as_unnecessary_replaced_name = g2
        #  if it has relatinship, then it shouldn't get the type relationship
         TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName.create(subject_taxon_name: g1, object_taxon_name: g2) 

        #  at this point g1 is INVALID
         g1.reload
        expect(g1.save).to be_truthy
        g1.soft_validate(only_sets: :homotypic_synonyms)
        expect(g1.soft_validations.messages_on(:base)).to_not include(msg)
      end
      
      specify 'same type specimen' do
        s1 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryBot.create(:relationship_species, name: 'cus', parent: @genus)
        t1 = FactoryBot.create(:valid_type_material, protonym: s1, type_type: 'holotype')
        t2 = FactoryBot.create(:valid_type_material, protonym: s2, type_type: 'neotype', collection_object_id: t1.collection_object_id)
        expect(s1.save).to be_truthy
        expect(s2.save).to be_truthy
        s1.soft_validate(only_sets: :homotypic_synonyms)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1)

        s1.iczn_set_as_unjustified_emendation_of = s2
        # TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation.create(subject_taxon_name: s1, object_taxon_name: s2) 
       
        expect(s1.save).to be_truthy
        s1.soft_validate(only_sets: :homotypic_synonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'primary homonym' do
        s1 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        s1.original_genus = @genus
        s2.original_genus = @genus
        expect(s1.save).to be_truthy
        expect(s2.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1)
        FactoryBot.create(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable', taxon_name: s1)
        expect(s1.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'primary homonym with alternative spelling' do
        s1 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryBot.create(:relationship_species, name: 'ba', parent: @genus)
        s1.original_genus = @genus
        s2.original_genus = @genus
        expect(s1.save).to be_truthy
        expect(s2.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1)
        FactoryBot.create(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable', taxon_name: s1)
        expect(s1.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
      end
      
      specify 'secondary homonym' do
        s1 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        expect(s1.save).to be_truthy
        expect(s2.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1)
        s1.iczn_set_as_homonym_of = s2
        expect(s1.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
      end
      specify 'secondary homonym with alternative spelling' do
        s1 = FactoryBot.create(:relationship_species, name: 'bus', parent: @genus)
        s2 = FactoryBot.create(:relationship_species, name: 'ba', parent: @genus)
        expect(s1.save).to be_truthy
        expect(s2.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1)
        FactoryBot.create(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable', taxon_name: s1)
        expect(s1.save).to be_truthy
        s1.soft_validate(only_sets: :potential_homonyms)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'genus homonym' do
        g1 = FactoryBot.create(:relationship_genus, name: 'Bbbus', parent: @family, year_of_publication: 1900)
        g2 = FactoryBot.create(:relationship_genus, name: 'Cccus', parent: @family)
        g3 = FactoryBot.create(:iczn_subgenus, name: 'Bbbus', parent: g2, year_of_publication: 1850)
        expect(g1.save).to be_truthy
        expect(g2.save).to be_truthy
        expect(g3.save).to be_truthy
        g1.soft_validate(only_sets: :potential_homonyms)
        g2.soft_validate(only_sets: :potential_homonyms)
        g3.soft_validate(only_sets: :potential_homonyms)
        expect(g1.soft_validations.messages_on(:base).size).to eq(1)
        expect(g2.soft_validations.messages_on(:base).empty?).to be_truthy
        expect(g3.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'family homonym alternative spelling' do
        f1 = FactoryBot.create(:relationship_family, name: 'Bbbidae', parent: @kingdom, year_of_publication: 1900)
        f2 = FactoryBot.create(:relationship_family, name: 'Cccidae', parent: @kingdom)
        f3 = FactoryBot.create(:iczn_subfamily, name: 'Bbbinae', parent: f2, year_of_publication: 1800)
        expect(f1.save).to be_truthy
        expect(f2.save).to be_truthy
        expect(f3.save).to be_truthy
        f1.soft_validate(only_sets: :potential_homonyms)
        f2.soft_validate(only_sets: :potential_homonyms)
        f3.soft_validate(only_sets: :potential_homonyms)
        expect(f1.soft_validations.messages_on(:base).size).to eq(1)
        expect(f2.soft_validations.messages_on(:base).empty?).to be_truthy
        expect(f3.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'type genus is a homonym' do
        f1 = FactoryBot.create(:relationship_family, name: 'Bbbidae', parent: @kingdom)
        f2 = FactoryBot.create(:relationship_family, name: 'Dddidae', parent: @kingdom)
        g1 = FactoryBot.create(:relationship_genus, name: 'Bbb', parent: f1)
        g2 = FactoryBot.create(:relationship_genus, name: 'Bbb', parent: @kingdom)
        f1.type_genus = g1
        f1.save!
        f1.reload
        f1.soft_validate(only_sets: :family_is_invalid)
        expect(f1.soft_validations.messages_on(:base).empty?).to be_truthy
        g1.iczn_set_as_homonym_of = g2
        f1.reload
        f1.soft_validate(only_sets: :family_is_invalid)
        expect(f1.soft_validations.messages_on(:base).empty?).to be_falsey
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: f1, type: 'TaxonNameClassification::Iczn::Available::Invalid::HomonymyOfTypeGenus')
        f1.reload
        f1.soft_validate(only_sets: :family_is_invalid)
        expect(f1.soft_validations.messages_on(:base).include?('Missing relationship: The name is invalid, but a substitute name is not selected')).to be_truthy
        f1.iczn_set_as_synonym_of = f2
        f1.reload
        f1.soft_validate(only_sets: :family_is_invalid)
        expect(f1.soft_validations.messages_on(:base).empty?).to be_truthy
      end

      specify 'type genus is a homonym 2' do
        f1 = FactoryBot.create(:relationship_family, name: 'Bbbidae', parent: @kingdom)
        g1 = FactoryBot.create(:relationship_genus, name: 'Bbb', parent: f1)
        f1.type_genus = g1
        f1.save!
        c1 = FactoryBot.create(:taxon_name_classification, taxon_name: g1, type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym')
        f1.reload
        f1.soft_validate(only_sets: :family_is_invalid)
        expect(f1.soft_validations.messages_on(:base).empty?).to be_falsey
      end

      specify 'homonym without replacement name' do
        g1 = FactoryBot.create(:relationship_genus, name: 'Bbbus', parent: @family, year_of_publication: 1900)
        g2 = FactoryBot.create(:relationship_genus, name: 'Cccus', parent: @family)
        g3 = FactoryBot.create(:iczn_subgenus, name: 'Bbbus', parent: g2, year_of_publication: 1850)
        g3.iczn_set_as_homonym_of = g1
        expect(g3.save).to be_truthy
        g3.soft_validate(only_sets: :missing_relationships)
        expect(g3.soft_validations.messages_on(:base).include?('Missing relationship: The name is a homonym, but a substitute name is not selected')).to be_truthy
        g3.iczn_set_as_synonym_of = g2
        expect(g3.save).to be_truthy
        g3.soft_validate(only_sets: :missing_relationships)
        expect(g3.soft_validations.messages_on(:base).include?('Missing relationship: The name is a homonym, but a substitute name is not selected')).to be_falsey
      end

      specify 'missing original combination relationships to self' do
        g = FactoryBot.create(:relationship_genus)
        s1 = FactoryBot.create(:relationship_species, parent: g)
        s2 = FactoryBot.create(:relationship_species, parent: g)
        s1.soft_validate(only_sets: :original_combination_relationships)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
        TaxonNameRelationship.create(subject_taxon_name: g, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
        s1.reload
        s1.soft_validate(only_sets: :original_combination_relationships)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1) # relationship to self is not selected
        r = TaxonNameRelationship.create(subject_taxon_name: s1, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies')
        s1.reload
        s1.soft_validate(only_sets: :original_combination_relationships)
        expect(s1.soft_validations.messages_on(:base).empty?).to be_truthy
        TaxonNameRelationship.create(subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety')
        s1.reload
        s1.soft_validate(only_sets: :original_combination_relationships)
        expect(s1.soft_validations.messages_on(:base).size).to eq(1) # relationship is not selected at the lowest nomenclatural rank
      end
    end

    context 'fossils' do
      specify 'extinct genus with extant species' do
        g = FactoryBot.create(:relationship_genus)
        s = FactoryBot.create(:relationship_species, parent: g)
        FactoryBot.create(:taxon_name_classification, taxon_name: g, type: 'TaxonNameClassification::Iczn::Fossil')
        g.reload
        g.soft_validate(only_sets: :extant_children)
        expect(g.soft_validations.messages_on(:base).size).to eq(1)
        FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Fossil')
        g.reload
        g.soft_validate(only_sets: :extant_children)
        expect(g.soft_validations.messages_on(:base).empty?).to be_truthy
      end
    end
  end
end
