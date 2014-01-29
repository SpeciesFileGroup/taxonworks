require 'spec_helper'

describe TaxonNameRelationship do

  context 'Taxon Name relationships' do
    before(:all) do
      TaxonName.delete_all
      TaxonNameRelationship.delete_all
      @taxon_name_relationship = FactoryGirl.build(:taxon_name_relationship)
      @taxon_name_relationship.valid?
      @species = FactoryGirl.create(:relationship_species)
      @genus = @species.ancestor_at_rank('genus')
      @family = @species.ancestor_at_rank('family')
      @kingdom = @species.ancestor_at_rank('kingdom')
    end

    after(:all) do
      TaxonName.delete_all
      TaxonNameRelationship.delete_all
    end
    context 'requires' do

      context 'associations' do
        specify 'subject (TaxonName)' do
          expect(@taxon_name_relationship).to respond_to (:subject_taxon_name)
        end
        specify 'object (TaxonName)' do
          expect(@taxon_name_relationship).to respond_to (:object_taxon_name)
        end
        specify 'type' do
          expect(@taxon_name_relationship).to respond_to (:type)
        end
        specify 'disjoint_taxon_name_relationships' do
          TAXON_NAME_RELATIONSHIPS.each do |r|
            r1 = r.disjoint_taxon_name_relationships.collect{|i| i.to_s}
            r1 = ['string'] + r1
            r1 = r1.collect{|i| i.class.to_s}.uniq
            expect(r1.first).to eq('String')
            expect(r1.count).to eq(1)
          end
        end
        specify 'disjoint_subject_classes' do
          TAXON_NAME_RELATIONSHIPS.each do |r|
            r1 = r.disjoint_subject_classes.collect{|i| i.to_s}
            r1 = ['string'] + r1
            r1 = r1.collect{|i| i.class.to_s}.uniq
            expect(r1.first).to eq('String')
            expect(r1.count).to eq(1)
          end
        end
        specify 'disjoint_object_classes' do
          TAXON_NAME_RELATIONSHIPS.each do |r|
            r1 = r.disjoint_object_classes.collect{|i| i.to_s}
            r1 = ['string'] + r1
            r1 = r1.collect{|i| i.class.to_s}.uniq
            expect(r1.first).to eq('String')
            expect(r1.count).to eq(1)
          end
        end
        specify 'valid_object_ranks' do
          TAXON_NAME_RELATIONSHIPS.each do |r|
            r1 = r.valid_object_ranks.collect{|i| i.to_s}
            r1 = ['string'] + r1
            r1 = r1.collect{|i| i.class.to_s}.uniq
            expect(r1.first).to eq('String')
            expect(r1.count).to eq(1)
          end
        end
        specify 'valid_subject_ranks' do
          TAXON_NAME_RELATIONSHIPS.each do |r|
            r1 = r.valid_subject_ranks.collect{|i| i.to_s}
            r1 = ['string'] + r1
            r1 = r1.collect{|i| i.class.to_s}.uniq
            expect(r1.first).to eq('String')
            expect(r1.count).to eq(1)
          end
        end
      end

      context 'validate' do
        specify 'subject_taxon_name_id' do
          expect(@taxon_name_relationship.errors.include?(:subject_taxon_name_id)).to be_true
        end
        specify 'object_taxon_name_id' do
          expect(@taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_true
        end
        specify 'type' do
          expect(@taxon_name_relationship.errors.include?(:type)).to be_true
        end

        specify 'object_taxon_name_id != subject_taxon_name_id' do
          @taxon_name_relationship.object_taxon_name = @genus
          @taxon_name_relationship.subject_taxon_name = @genus
          @taxon_name_relationship.valid?
          expect(@taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_true
        end

        context 'object and subject should share the same potentially_validating code' do
          specify 'same code' do
            r = FactoryGirl.build_stubbed(:type_species_relationship)
            r.valid?
            expect(r.errors.include?(:object_taxon_name_id)).to be_false
          end

          specify 'different code' do
            r = FactoryGirl.build_stubbed(:type_species_relationship, object_taxon_name: FactoryGirl.build(:icn_genus))
            expect(r.valid?).to be_false
            expect(r.errors.include?(:object_taxon_name_id)).to be_true
          end

          specify 'valid object rank' do
            r = FactoryGirl.build_stubbed(:type_species_relationship)
            expect(r.valid?).to be_true
            expect(r.errors.include?(:object_taxon_name_id)).to be_false
            expect(r.errors.include?(:subject_taxon_name_id)).to be_false
          end

          specify 'protonym should not have a combination relationships' do
            r = FactoryGirl.build_stubbed(:type_species_relationship, subject_taxon_name: @genus, object_taxon_name: @species, type: 'TaxonNameRelationship::Combination::Genus')
            expect(r.valid?).to be_false
            expect(r.errors.include?(:type)).to be_true
          end

          specify 'subject and object share nomenclatural rank group' do
            r = FactoryGirl.build_stubbed(:type_species_relationship, subject_taxon_name: @species, object_taxon_name: @genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
            expect(r.valid?).to be_false
            expect(r.errors.include?(:object_taxon_name_id)).to be_true
          end
        end

        context 'type' do
          specify 'invalidly_published when not a TaxonNameRelationship' do
            @taxon_name_relationship.type = "foo"
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:type)).to be_true
            @taxon_name_relationship.type = Specimen
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:type)).to be_true
          end

          specify 'validly_published when a TaxonNameRelationship' do
            @taxon_name_relationship.type = 'TaxonNameRelationship::Combination::Genus'
            @taxon_name_relationship.valid?
            expect(@taxon_name_relationship.errors.include?(:typification)).to be_false
          end
        end

        context 'relationships' do
          specify 'has only one synonym relationship' do
            s = FactoryGirl.create(:relationship_species, parent: @genus)
            r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
            expect(r1.valid?).to be_true
            expect(r1.errors.include?(:subject_taxon_name_id)).to be_false
            r2 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
            r2.valid?
            expect(r2.errors.include?(:subject_taxon_name_id)).to be_true
          end
          specify 'has only one type relationship' do
            s = FactoryGirl.create(:relationship_species, parent: @genus)
            r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @genus, type: 'TaxonNameRelationship::Typification::Genus')
            expect(r1.valid?).to be_true
            expect(r1.errors.include?(:object_taxon_name_id)).to be_false
            r2 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @genus, type: 'TaxonNameRelationship::Typification::Genus::Monotypy')
            r2.valid?
            expect(r2.errors.include?(:object_taxon_name_id)).to be_true
          end
        end
      end
    end

    context 'soft validation' do
      specify 'required relationship' do
        s = FactoryGirl.create(:relationship_species, parent: @genus)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
        r1.soft_validate(:validate_required_relationships)
        # original genus is required
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        s.original_genus = @genus
        expect(s.save).to be_true
        r1.soft_validate(:validate_required_relationships)
        expect(r1.soft_validations.messages_on(:type).empty?).to be_true
      end
      specify 'disjoint relationships' do
        g = FactoryGirl.create(:relationship_genus, parent: @family)
        s = FactoryGirl.create(:relationship_species, parent: g)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Validating::ConservedName')
        r1.soft_validate(:validate_disjoint_relationships)
        expect(r1.soft_validations.messages_on(:type).empty?).to be_true
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: @species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r1.soft_validate(:validate_disjoint_relationships)
        r2.soft_validate(:validate_disjoint_relationships)
        #conflicting with r2
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        #conflicting with r1
        expect(r2.soft_validations.messages_on(:type).count).to eq(1)
      end
      specify 'disjoint objects' do
        g = FactoryGirl.create(:relationship_genus, parent: @family)
        s = FactoryGirl.create(:relationship_species, parent: g)
        FactoryGirl.create(:taxon_name_classification, taxon_name: g, type: 'TaxonNameClassification::Iczn::Unavailable')
        r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: g, type: 'TaxonNameRelationship::Typification::Genus::OriginalDesignation')
        r1.soft_validate(:validate_disjoint_object)
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        expect(r1.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
      end
      specify 'disjoint subject' do
        g = FactoryGirl.create(:relationship_genus, parent: @family)
        s = FactoryGirl.create(:relationship_species, parent: g)
        FactoryGirl.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Unavailable')
        r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: g, type: 'TaxonNameRelationship::Typification::Genus::OriginalDesignation')
        r1.soft_validate(:validate_disjoint_subject)
        expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        expect(r1.soft_validations.messages_on(:subject_taxon_name_id).count).to eq(1)
      end

      context 'specific relationships' do
        before(:all) do
          @f1 = FactoryGirl.create(:relationship_family, parent: @kingdom, year_of_publication: 2000)
          @f2 = FactoryGirl.create(:relationship_family, parent: @kingdom, year_of_publication: 2001)
          @g1 = FactoryGirl.create(:relationship_genus, parent: @f1)
          @g2 = FactoryGirl.create(:relationship_genus, parent: @f2)
          @s1 =  FactoryGirl.create(:relationship_species, parent: @g1)
          @s2 =  FactoryGirl.create(:relationship_species, parent: @g2)
          @r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @g1, type: 'TaxonNameRelationship::Typification::Genus')
          @r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @s2, object_taxon_name: @g2, type: 'TaxonNameRelationship::Typification::Genus')
          @source = FactoryGirl.create(:valid_source_bibtex, year: 2000)
        end

        specify 'objective synonyms should have the same type' do
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @g1, object_taxon_name: @g2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym')
          r.soft_validate(:objective_synonym_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
        end

        specify 'objective synonyms should have the same type specimen' do
          type_material1 = FactoryGirl.create(:valid_type_material, protonym: @s1)
          type_material2 = FactoryGirl.create(:valid_type_material, protonym: @s2)
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
          r.soft_validate(:objective_synonym_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
          r.type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective'
          r.soft_validate(:objective_synonym_relationship)
          expect(r.soft_validations.messages_on(:type).empty?).to be_true
        end

        specify 'subjective synonyms should not have the same type' do
          @r2.subject_taxon_name = @s1
          expect(@r2.save).to be_true
          @g2.reload
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @g1, object_taxon_name: @g2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
        end

        specify 'subjective synonyms should have different type specimen' do
          type_material1 = FactoryGirl.create(:valid_type_material, protonym: @s1)
          type_material2 = FactoryGirl.create(:valid_type_material, biological_object_id: type_material1.biological_object_id, protonym: @s2)
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
          r.type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective'
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).empty?).to be_true
        end

        specify 'primary homonyms do not share the same original genus' do
          @s1.original_genus = @g1
          @s2.original_genus = @g2
          expect(@s1.save).to be_true
          expect(@s2.save).to be_true
          @s1.reload
          @s2.reload
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary')
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
        end

        specify 'secondary homonyms should be placed in the same genus' do
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary')
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
        end

        specify 'secondary homonyms should be changed to primary' do
          @s2.original_genus = @g1
          expect(@s2.save).to be_true
          @s2.reload
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s2, object_taxon_name: @s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary')
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
        end

        specify 'errors on secondary homonym before 1961' do
          @s2.original_genus = @g1
          expect(@s2.save).to be_true
          @s2.year_of_publication = 1970
          expect(@s2.save).to be_true
          @s2.reload
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s2, object_taxon_name: @s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961')
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:type).count).to eq(2)
          expect(r.soft_validations.messages_on(:source_id).count).to eq(1)
          r.source = @source
          r.soft_validate(:specific_relationship)
          expect(r.soft_validations.messages_on(:source_id).count).to eq(1)
        end

        specify 'type species by subsequent designation' do
          @r1.type = 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation'
          expect(@r1.save).to be_true
          @r1.reload
          @r1.soft_validate(:synonym_relationship)
          expect(@r1.soft_validations.messages_on(:source_id).count).to eq(1)
        end

        specify 'errors on family synony before 1961' do
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @f1, object_taxon_name: @f2, source: @source, type: 'TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961')
          r.soft_validate('specific_relationship')
          expect(r.soft_validations.messages_on(:type).count).to eq(1)
          expect(r.soft_validations.messages_on(:source_id).count).to eq(1)
        end

        specify 'synonym should have a source' do
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @f2, object_taxon_name: @f1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
          r.soft_validate('synonym_relationship')
          expect(r.soft_validations.messages_on(:source_id).count).to eq(1)
        end

        specify 'source should not be older than synonym' do
          r = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @f2, object_taxon_name: @f1, source: @source, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
          r.soft_validate('synonym_relationship')
          expect(r.soft_validations.messages_on(:source_id).count).to eq(1)
        end

        specify 'homonym and totally suppressed' do
          r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @g2, object_taxon_name: @g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total')
          r2 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: @g2, source: @source, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
          r2.soft_validate('validate_homonym_relationships')
          expect(r2.soft_validations.messages_on(:type).count).to eq(1)
        end
        specify 'homonym without nomen novum' do
          r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @g2, object_taxon_name: @g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
          r1.soft_validate('validate_homonym_relationships')
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
          r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: @g2, type: 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName')
          r1.soft_validate('validate_homonym_relationships')
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
          r1.fix_soft_validations
          r1.soft_validate('validate_homonym_relationships')
          expect(r1.soft_validations.messages_on(:type).empty?).to be_true
        end
      end

      context 'not specific relationships' do
        specify 'examples' do
          s1 = FactoryGirl.create(:relationship_species, parent: @genus)
          s2 = FactoryGirl.create(:relationship_species, parent: @genus)
          r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating')
          r2 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
          r3 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
          r1.soft_validate(:not_specific_relationship)
          r2.soft_validate(:not_specific_relationship)
          r3.soft_validate(:not_specific_relationship)
          # reason of being invalid?
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
          # primary or secondary homonym?
          expect(r2.soft_validations.messages_on(:type).count).to eq(1)
          # objective or subjective synonym?
          expect(r3.soft_validations.messages_on(:type).count).to eq(1)
        end
        specify 'fix not specific relationships from synonym to objective synonym' do
          g1 = FactoryGirl.create(:relationship_genus, parent: @family)
          g2 = FactoryGirl.create(:relationship_genus, parent: @family)
          s1 = FactoryGirl.create(:relationship_species, parent: g1)
          r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
          r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g1, type: 'TaxonNameRelationship::Typification::Genus')
          r3 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g2, type: 'TaxonNameRelationship::Typification::Genus')
          r1.soft_validate(:not_specific_relationship)
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
          r1.fix_soft_validations
          r1.soft_validate(:not_specific_relationship)
          expect(r1.soft_validations.messages_on(:type).empty?).to be_true
        end
        specify 'fix not specific relationships from homonym to primary homonym' do
          s1 = FactoryGirl.create(:relationship_species, parent: @genus)
          s2 = FactoryGirl.create(:relationship_species, parent: @genus)
          r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
          r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
          r3 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: @genus, object_taxon_name: s2, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
          r1.soft_validate(:not_specific_relationship)
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
          r1.fix_soft_validations
          r1.soft_validate(:not_specific_relationship)
          expect(r1.soft_validations.messages_on(:type).empty?).to be_true
        end
      end

      specify 'parent is a synonym' do
        g1 = FactoryGirl.create(:relationship_genus, parent: @family)
        g2 = FactoryGirl.create(:relationship_genus, parent: @family)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: @genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        r1.soft_validate(:synonym_linked_to_valid_name)
        r2.soft_validate(:synonym_linked_to_valid_name)
        expect(r1.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_true
        # parent is a synonym of another taxon
        expect(r2.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
        r2.fix_soft_validations
        r2.soft_validate(:synonym_linked_to_valid_name)
        # parent updated to valid name
        expect(r2.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_true
      end
      specify 'type genus should have the same first letter' do
        f1 = FactoryGirl.create(:relationship_family, parent: @kingdom)
        g1 = FactoryGirl.create(:relationship_genus, name: 'Bus', parent: f1)
        r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: f1, type: 'TaxonNameRelationship::Typification::Family')
        r1.soft_validate(:matching_type_genus)
        expect(r1.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
      end

      context 'priority' do
        before(:all) do
          @g1 = FactoryGirl.create('relationship_genus', parent: @family, year_of_publication: 2005)
          @s1 = FactoryGirl.create('relationship_species', parent: @g1, year_of_publication: 2000)
          @s2 = FactoryGirl.create('relationship_species', parent: @g1, year_of_publication: 2001)
        end
        specify 'FirstRevisorAction' do
          r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @s2, type: 'TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction')
          r1.soft_validate(:validate_priority)
          expect(r1.soft_validations.messages_on(:object_taxon_name_id).count).to eq(1)
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        end
        specify 'direct priority' do
          r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s2, object_taxon_name: @s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
          r1.soft_validate(:validate_priority)
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        end
        specify 'reverse priority' do
          r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @s1, object_taxon_name: @s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName')
          r1.soft_validate(:validate_priority)
          expect(r1.soft_validations.messages_on(:type).count).to eq(1)
        end
        specify 'reverse priority original genus' do
          r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: @g1, object_taxon_name: @s2, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
          r1.soft_validate(:validate_priority)
        expect(r1.soft_validations.messages_on(:subject_taxon_name_id).count).to eq(1)
        end
      end

    end
  end


end
