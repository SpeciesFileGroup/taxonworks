require 'rails_helper'

describe TaxonNameRelationship, type: :model, group: [:nomenclature] do

  let(:taxon_name_relationship) { TaxonNameRelationship.new }

  let!(:species) { FactoryBot.create(:relationship_species) } 
  let(:genus) { species.ancestor_at_rank('genus') } 
  let(:family) { species.ancestor_at_rank('family') } 
  let(:kingdom) { species.ancestor_at_rank('kingdom') } 
  
  after(:all) {
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  }

  context 'required attributes' do
    specify 'subject (TaxonName)' do
      expect(taxon_name_relationship.subject_taxon_name = Protonym.new).to be_truthy
    end

    specify 'object (TaxonName)' do
      expect(taxon_name_relationship.object_taxon_name = Protonym.new).to be_truthy
    end

    specify 'type' do
      expect(taxon_name_relationship).to respond_to (:type)
    end

    specify 'respond to .assignmet_method' do
      TaxonNameRelationship.descendants.each do |klass|
        a  = ''
        if klass.respond_to?(:assignment_method)
          unless klass.respond_to?(:inverse_assignment_method)
            a += klass.to_s + ', '
          end
        end
        expect(a).to eq('')
      end
    end

    specify 'missing and duplicate NOMEN_URI' do
      nomen_uris = []
      TaxonNameRelationship.descendants.each do |klass|
        if klass.name =~ /::(Icn|Iczn)::/
          uri = klass.nomen_uri
          expect(uri.empty?).to be_falsey, "NOMEN_URI for #{klass.name} is empty!"
          expect(nomen_uris.include?(uri)).to be(false), "#{uri} from #{klass.name} is duplicated!"
          expect(uri).to match(/http:\/\/purl.obolibrary.org\/obo\/NOMEN/), "#{uri} from #{klass.name} is invalid!"
          nomen_uris.push uri
        end
      end
    end
  end

  context 'associations' do
    specify 'disjoint_taxon_name_relationships' do
      TAXON_NAME_RELATIONSHIPS.each do |r|
        r1 = r.disjoint_taxon_name_relationships.collect { |i| i.to_s }
        r1 = ['string'] + r1
        r1 = r1.collect { |i| i.class.to_s }.uniq
        expect(r1.first).to eq('String')
        expect(r1.size).to eq(1)
      end
    end

    specify 'disjoint_subject_classes' do
      TAXON_NAME_RELATIONSHIPS.each do |r|
        r1 = r.disjoint_subject_classes.collect { |i| i.to_s }
        r1 = ['string'] + r1
        r1 = r1.collect { |i| i.class.to_s }.uniq
        expect(r1.first).to eq('String')
        expect(r1.size).to eq(1)
      end
    end

    specify 'disjoint_object_classes' do
      TAXON_NAME_RELATIONSHIPS.each do |r|
        r1 = r.disjoint_object_classes.collect { |i| i.to_s }
        r1 = ['string'] + r1
        r1 = r1.collect { |i| i.class.to_s }.uniq
        expect(r1.first).to eq('String')
        expect(r1.size).to eq(1)
      end
    end

    specify 'valid_object_ranks' do
      TAXON_NAME_RELATIONSHIPS.each do |r|
        r1 = r.valid_object_ranks.collect { |i| i.to_s }
        r1 = ['string'] + r1
        r1 = r1.collect { |i| i.class.to_s }.uniq
        expect(r1.first).to eq('String')
        expect(r1.size).to eq(1)
      end
    end

    specify 'valid_subject_ranks' do
      TAXON_NAME_RELATIONSHIPS.each do |r|
        r1 = r.valid_subject_ranks.collect { |i| i.to_s }
        r1 = ['string'] + r1
        r1 = r1.collect { |i| i.class.to_s }.uniq
        expect(r1.first).to eq('String')
        expect(r1.size).to eq(1)
      end
    end
  end

  context 'validation' do
    context 'required attributes' do
      before(:each) {
        taxon_name_relationship.valid?
      }
      specify 'subject_taxon_name' do
        expect(taxon_name_relationship.errors.include?(:subject_taxon_name)).to be_truthy
      end

      specify 'object_taxon_name' do
        expect(taxon_name_relationship.errors.include?(:object_taxon_name)).to be_truthy
      end

      specify 'type' do
        expect(taxon_name_relationship.errors.include?(:type)).to be_truthy
      end
    end

    specify 'object_taxon_name != subject_taxon_name' do
      taxon_name_relationship.object_taxon_name  = species
      taxon_name_relationship.subject_taxon_name = species
      taxon_name_relationship.valid?
      expect(taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_truthy
    end

    specify 'subject_taxon_name != Protonym' do
      taxon_name_relationship.type               = 'TaxonNameRelationship::Combination::Genus'
      c                                          = FactoryBot.build(:combination)
      taxon_name_relationship.object_taxon_name  = genus
      taxon_name_relationship.subject_taxon_name = c
      taxon_name_relationship.valid?
      expect(taxon_name_relationship.errors.include?(:subject_taxon_name_id)).to be_truthy
      expect(taxon_name_relationship.errors.include?(:object_taxon_name_id)).to be_truthy
    end


    context 'object and subject should share the same potentially_validating code' do
      specify 'same code' do
        r = FactoryBot.build_stubbed(:type_species_relationship)
        r.valid?
        expect(r.errors.include?(:object_taxon_name_id)).to be_falsey
      end

      specify 'different code' do
        r = FactoryBot.build_stubbed(:type_species_relationship, object_taxon_name: FactoryBot.build(:icn_genus))
        expect(r.valid?).to be_falsey
        expect(r.errors.include?(:object_taxon_name_id)).to be_truthy
      end

      specify 'valid object rank' do
        r = FactoryBot.build_stubbed(:type_species_relationship)
        expect(r.valid?).to be_truthy
        expect(r.errors.include?(:object_taxon_name_id)).to be_falsey
        expect(r.errors.include?(:subject_taxon_name_id)).to be_falsey
      end

      specify 'protonym should not have a combination relationships' do
        r = FactoryBot.build_stubbed(:type_species_relationship, subject_taxon_name: genus, object_taxon_name: species, type: 'TaxonNameRelationship::Combination::Genus')
        expect(r.valid?).to be_falsey
        expect(r.errors.include?(:type)).to be_truthy
      end

      specify 'subject and object share nomenclatural rank group' do
        r = FactoryBot.build_stubbed(:type_species_relationship, subject_taxon_name: species, object_taxon_name: genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        expect(r.valid?).to be_falsey
        expect(r.errors.include?(:object_taxon_name_id)).to be_truthy
      end
    end

    context 'type' do
      specify 'is invalid when not a valid TaxonNameRelationship' do # "invalidly_published when not a TaxonNameRelationship" ?!
        taxon_name_relationship.type = 'foo'
        taxon_name_relationship.valid?
        expect(taxon_name_relationship.errors.include?(:type)).to be_truthy
        taxon_name_relationship.type = 'Specimen'
        taxon_name_relationship.valid?
        expect(taxon_name_relationship.errors.include?(:type)).to be_truthy
      end

      specify 'is valid when a defined TaxonNameRelationship' do
        taxon_name_relationship.type = 'TaxonNameRelationship::Combination::Genus'
        taxon_name_relationship.valid?
        expect(taxon_name_relationship.errors.include?(:typification)).to be_falsey
      end
    end

    context 'relationships' do
      specify 'has only one synonym relationship' do
        s  = FactoryBot.create(:relationship_species, parent: genus)
        r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
        expect(r1.valid?).to be_truthy
        expect(r1.errors.include?(:subject_taxon_name_id)).to be_falsey
        r2 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
        r2.valid?
        expect(r2.errors.include?(:subject_taxon_name_id)).to be_falsey
      end

      specify 'has only one type relationship' do
        s  = FactoryBot.create(:relationship_species, parent: genus)
        r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: genus, type: 'TaxonNameRelationship::Typification::Genus')
        expect(r1.valid?).to be_truthy
        expect(r1.errors.include?(:object_taxon_name_id)).to be_falsey
        r2 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: genus, type: 'TaxonNameRelationship::Typification::Genus::Original')
        r2.valid?
        expect(r2.errors.include?(:object_taxon_name_id)).to be_truthy
      end

      specify 'has only one original genus' do
        g  = FactoryBot.create(:relationship_genus, parent: family)
        s  = FactoryBot.create(:relationship_species, parent: g)
        r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
        expect(r1.valid?).to be_truthy
        expect(r1.errors.include?(:object_taxon_name_id)).to be_falsey
        r2 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
        r2.valid?
        expect(r2.errors.include?(:object_taxon_name_id)).to be_truthy
      end
    end
  end

  context 'after save' do

    context 'cached values are set' do
      let(:g1) { FactoryBot.create(:relationship_genus, name: 'Aus', parent: family) }
      let(:g2) { FactoryBot.create(:relationship_genus, name: 'Bus', parent: family) }
      let(:s1) { FactoryBot.create(:relationship_species, name: 'aus', parent: g1) }
      let(:s2) { FactoryBot.create(:relationship_species, name: 'bus', parent: g2) }

      specify 'for cached' do
        expect(s1.cached).to eq('Aus aus')
      end

      specify 'for cached_html' do
        expect(s1.cached_html).to eq('<i>Aus aus</i>')
      end

      specify 'for cached_misspelling' do
        expect(s1.cached_misspelling).to be_falsey
      end

      # TODO: this can be moved out to the new original_combination specs
      specify 'for cached_original_combination' do
        # Use non FactoryBot to get callbacks
        s1.update(original_genus: g2)
        expect(s1.cached_original_combination).to eq('Bus aus')
      end

      specify 'for cached_primary_homony' do
        s1.original_genus = g2
        s1.save!
        expect(s1.cached_primary_homonym).to eq('Bus aus')
      end

      specify 'for cached_classified_as' do
        r2 = FactoryBot.build(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: family, type: 'TaxonNameRelationship::SourceClassifiedAs')
        r2.save!
        expect(s1.cached_classified_as).to eq(' (as Erythroneuridae)')
      end

      specify 'for cached_author' do
        s1.original_genus = g1
        s1.save!
        expect(s1.cached_author_year).to eq('McAtee, 1900')
        s1.original_genus = g2
        s1.save!
        expect(s1.cached_author_year).to eq('(McAtee, 1900)')
      end

      # TODO: notice that alone they pass, we need a seperate method for setting cached_classified_as, i.e. decouple it from original combination cache setting
      specify 'for cached_classified_as with original genus present' do
        s1.update(original_genus: g2)
        r2 = TaxonNameRelationship::SourceClassifiedAs.create!(subject_taxon_name: s1, object_taxon_name: family, type: 'TaxonNameRelationship::SourceClassifiedAs')
        expect(s1.cached_classified_as).to eq(' (as Erythroneuridae)')
      end

      specify 'for cached_valid_taxon_name_id' do
        r1 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: g2, object_taxon_name: g1)
        g2.reload
        expect(g2.cached_valid_taxon_name_id).to eq(g1.id)
        r1.destroy!
        g2.reload
        expect(g2.cached_valid_taxon_name_id).to eq(g2.id)
      end

      specify 'create misspelling relationship' do
        r3 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2,
                               type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling')
        expect(s1.cached_misspelling).to be_truthy
        expect(s1.cached).to eq('Aus aus [sic]')
        expect(s1.cached_html).to eq('<i>Aus aus</i> [sic]')
      end

      specify 'fixing synonym linked to another synonym' do
        r3 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2,
                              type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling')
        r3.soft_validate(only_sets: :synonym_linked_to_valid_name)
        expect(r3.soft_validations.messages_on(:subject_taxon_name_id).size).to eq(1)
        r3.fix_soft_validations
        r3.save!
        expect(s1.cached_misspelling).to be_truthy
           expect(s1.cached).to eq('Bus aus [sic]')
        expect(s1.cached_html).to eq('<i>Bus aus</i> [sic]')
      end
    end

    specify 'destroy relationship' do
      g1 = FactoryBot.create(:relationship_genus, name: 'Aus', parent: family)
      s1 = FactoryBot.create(:relationship_species, name: 'aus', parent: g1)
      r1 = FactoryBot.build(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      r2 = FactoryBot.build(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      r3 = FactoryBot.build(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies')

      r1.save!
      r2.save!
      r3.save!
      s1.save!
      expect(s1.cached_original_combination).to eq('Aus (Aus) aus')
      r2.destroy
      expect(s1.cached_original_combination).to eq('Aus aus')
    end
  end

  context 'scope' do
    specify 'order_by_oldest_source_first' do
      g1 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: family)
      g2 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: family)
      g3 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: family)
      s1 = FactoryBot.create(:valid_source_bibtex, title: 'article 1', year: 2010)
      s2 = FactoryBot.create(:valid_source_bibtex, title: 'article 2')
      r1 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: g1, object_taxon_name: g2, source: s2)
      r2 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: g1, object_taxon_name: g3, source: s1)

      expect(TaxonNameRelationship.order_by_oldest_source_first.to_a).to eq([r2, r1])
    end
  end

  context 'usage' do
    specify 'can be created through assignment by reference to named through relationship' do
      g                = FactoryBot.create(:relationship_genus)
      s                = FactoryBot.create(:relationship_species, parent: g)
      s.original_genus = g
      expect(s.save).to be_truthy
      s.reload
      expect(s.all_taxon_name_relationships.count).to be > 0
    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'is_data'
  end

end
