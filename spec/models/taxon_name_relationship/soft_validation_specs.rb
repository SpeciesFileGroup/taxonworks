require 'rails_helper'

describe TaxonNameRelationship, type: :model, group: [:nomenclature, :soft_validation] do

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

  specify 'required relationship' do
    s  = FactoryBot.create(:relationship_species, parent: genus)
    r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
    r1.soft_validate(only_sets: :validate_required_relationships)
    # original genus is required
    expect(r1.soft_validations.messages_on(:type).size).to eq(1)
    s.original_genus = genus
    expect(s.save).to be_truthy
    s.reload
    expect(s.all_taxon_name_relationships.count).to be > 0
    r1.soft_validate(only_sets: :validate_required_relationships)
    expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
  end

  specify 'disjoint relationships' do
    g  = FactoryBot.create(:relationship_genus, parent: family)
    s  = FactoryBot.create(:relationship_species, parent: g)
    r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Validating::ConservedName')
    r1.soft_validate(only_sets: :validate_disjoint_relationships)
    expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
    r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
    r1.soft_validate(only_sets: :validate_disjoint_relationships)
    r2.soft_validate(only_sets: :validate_disjoint_relationships)
    #conflicting with r2
    expect(r1.soft_validations.messages_on(:type).size).to eq(1)
    #conflicting with r1
    expect(r2.soft_validations.messages_on(:type).size).to eq(1)
  end

  specify 'disjoint objects' do
    g = FactoryBot.create(:relationship_genus, parent: family)
    s = FactoryBot.create(:relationship_species, parent: g)
    FactoryBot.create(:taxon_name_classification, taxon_name: g, type: 'TaxonNameClassification::Iczn::Unavailable')

    r1 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: g, type: 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation')
    r1.soft_validate(only_sets: :validate_disjoint_object)

    expect(r1.soft_validations.messages_on(:type).size).to eq(1)

    expect(r1.soft_validations.messages_on(:object_taxon_name_id).size).to eq(1)
  end

  specify 'disjoint subject' do
    g = FactoryBot.create(:relationship_genus, parent: family)
    s = FactoryBot.create(:relationship_species, parent: g)
    FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Unavailable')
    r1 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: g, type: 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation')
    r1.soft_validate(only_sets: :validate_disjoint_subject)
    expect(r1.soft_validations.messages_on(:type).size).to eq(1)
    expect(r1.soft_validations.messages_on(:subject_taxon_name_id).size).to eq(1)
  end

  context 'specific relationships' do
    let!(:f1) {FactoryBot.create(:relationship_family, parent: kingdom, year_of_publication: 2000) }
    let!(:f2) {FactoryBot.create(:relationship_family, parent: kingdom, year_of_publication: 2001) }

    let!(:g1) {FactoryBot.create(:relationship_genus, parent: f1) }
    let!(:g2) {FactoryBot.create(:relationship_genus, parent: f2) }

    let!(:s1) {FactoryBot.create(:relationship_species, parent: g1)}
    let!(:s2) {FactoryBot.create(:relationship_species, parent: g2)}

    let!(:r1) {FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g1, type: 'TaxonNameRelationship::Typification::Genus')}
    let!(:r2) {FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: g2, type: 'TaxonNameRelationship::Typification::Genus') }

    let(:source) {FactoryBot.create(:valid_source_bibtex, year: 2000)}

    specify 'objective synonyms should have the same type' do
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: g2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym')
      r.soft_validate(only_sets: :objective_synonym_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'objective synonyms should have the same type specimen' do
      type_material1 = FactoryBot.create(:valid_type_material, protonym: s1)
      type_material2 = FactoryBot.create(:valid_type_material, protonym: s2)
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      r.soft_validate(only_sets: :objective_synonym_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'objective synonyms should have the same type specimen 2' do
      type_material1 = FactoryBot.create(:valid_type_material, protonym: s1)
      type_material2 = FactoryBot.create(:valid_type_material, protonym: s2)
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
      r.soft_validate(only_sets: :objective_synonym_relationship)
      expect(r.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'subjective synonyms should not have the same type' do
      r2.subject_taxon_name = s1
      expect(r2.save).to be_truthy
      g2.reload
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: g2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'subjective synonyms should have different type specimen' do
      type_material1 = FactoryBot.create(:valid_type_material, protonym: s1)
      type_material2 = FactoryBot.create(:valid_type_material, collection_object_id: type_material1.collection_object_id, protonym: s2)
      r  = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'objective synonyms have same type specimen' do
      type_material1 = FactoryBot.create(:valid_type_material, protonym: s1)
      type_material2 = FactoryBot.create(:valid_type_material, collection_object_id: type_material1.collection_object_id, protonym: s2)
      r  = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'primary homonyms do not share the same original genus' do
      s1.original_genus = g1
      s2.original_genus = g2
      expect(s1.save).to be_truthy
      expect(s2.save).to be_truthy
      s1.reload
      s2.reload
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'generic homonyms should be similar' do
      g = FactoryBot.create(:relationship_genus, name: 'Xus', parent: f1)
      r = TaxonNameRelationship::Iczn::Invalidating::Homonym.create!(subject_taxon_name: g, object_taxon_name: g2)
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'primary homonyms should be similar' do
      sp = FactoryBot.create(:relationship_species, name: 'xus', parent: g2)
      sp.original_genus = g1
      s2.original_genus = g1
      expect(sp.save).to be_truthy
      expect(s2.save).to be_truthy
      sp.reload
      s2.reload
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: sp, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'secondary homonyms should be similar' do
      sp = FactoryBot.create(:relationship_species, name: 'xus', parent: g2)
      sp.original_genus  = g1
      s2.original_genus = g2
      expect(sp.save).to be_truthy
      expect(s2.save).to be_truthy
      sp.reload
      s2.reload
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: sp, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'secondary homonyms should be placed in the same genus' do
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'secondary homonyms should be changed to primary' do
      s2.original_genus = g1
      expect(s2.save).to be_truthy
      s2.reload
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'errors on secondary homonym before 1961' do
      s2.original_genus = g1
      expect(s2.save).to be_truthy
      s2.year_of_publication = 1970
      expect(s2.save).to be_truthy
      s2.reload
      r = FactoryBot.build_stubbed(
        :taxon_name_relationship,
        subject_taxon_name: s2,
        object_taxon_name:  s1,
        type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961'
      )

      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
      expect(r.soft_validations.messages_on(:base).size).to eq(1)
      r.source = source
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:base).size).to eq(1)
    end

    specify 'type species by subsequent designation' do
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation')
      r.soft_validate(only_sets: :synonym_relationship)
      expect(r.soft_validations.messages_on(:base).size).to eq(1)
    end

    specify 'errors on family synonym before 1961' do
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: f1, object_taxon_name: f2, source: source, type: 'TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961')
      r.soft_validate(only_sets: :specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
      expect(r.soft_validations.messages_on(:base).size).to eq(1)
    end

    specify 'synonym should have a source' do
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: f2, object_taxon_name: f1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      r.soft_validate(only_sets: :synonym_relationship)
      expect(r.soft_validations.messages_on(:base).size).to eq(1)
    end

    specify 'source should not be older than synonym' do
      r = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: f2, object_taxon_name: f1, source: source, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      r.soft_validate(only_sets: :synonym_relationship)
      expect(r.soft_validations.messages_on(:base).size).to eq(1)
    end

    specify 'homonym and totally suppressed' do
      r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total')
      r2 = TaxonNameRelationship::Iczn::Invalidating::Homonym.new(subject_taxon_name: genus, object_taxon_name: g2, source: source)
      r2.soft_validate(only_sets: :validate_homonym_relationships)
      expect(r2.soft_validations.messages_on(:type)).to include('Taxon should not be treated as homonym, since the related taxon is totally suppressed')
    end

    specify 'homonym without nomen novum' do
      r1 = TaxonNameRelationship::Iczn::Invalidating::Homonym.create(subject_taxon_name: g2, object_taxon_name: g1)
      r1.soft_validate(only_sets: :validate_homonym_relationships)

      expect(r1.soft_validations.messages_on(:type).size).to eq(1)

      r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: g2, type: 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName')
      r1.soft_validate(only_sets: :validate_homonym_relationships)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      r1.fix_soft_validations
      r1.soft_validate(only_sets: :validate_homonym_relationships)
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'subsequent type designation after 1930' do
      gen1 = FactoryBot.create(:relationship_genus, name: 'Aus')
      r3 = TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation.create(subject_taxon_name: species, object_taxon_name: gen1)
      expect(r3.save).to be_truthy
      r3.soft_validate(only_sets: :described_after_1930)
      expect(r3.soft_validations.messages_on(:type).empty?).to be_truthy
      r3.object_taxon_name.year_of_publication = 1950
      expect(r3.save).to be_truthy
      r3.soft_validate(only_sets: :described_after_1930)
      expect(r3.soft_validations.messages_on(:type).size).to eq(1)
    end

    context 'secondary homonyms missing combination' do
      let(:message) { 'No combination available showing <i>Aus vitis</i> McAtee, 1900 and <i>Bus vitis</i> McAtee, 1900 placed in the same genus' }
      let(:f) { FactoryBot.create(:relationship_family) }
      let(:g1) { FactoryBot.create(:relationship_genus, name: 'Aus', parent: f) }
      let(:g2) { FactoryBot.create(:relationship_genus, name: 'Bus', parent: f) }
      let(:s1) { FactoryBot.create(:relationship_species, parent: g1) }
      let(:s2) { FactoryBot.create(:relationship_species, parent: g2) }
      let(:r1) { FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961') }

      specify 'generic placements are correct' do
        expect(s1.all_generic_placements).to eq([s1.ancestor_at_rank('genus').name])
      end

      specify 'specify_relationship validation adds message' do
        r1.soft_validate(only_sets: :specific_relationship)
        expect(r1.soft_validations.messages_on(:base)).to include(message)
      end

      specify 'with validating combination validates' do
        c = Combination.new(genus: g2, species: s1)
        expect(c.save!).to be_truthy
        s1.reload
        species.save
        r1.soft_validate(only_sets: :specific_relationship)
        expect(r1.soft_validations.messages_on(:base)).to_not include(message)
      end
    end
  end

  context 'not specific relationships' do
    specify 'examples' do
      s1 = FactoryBot.create(:relationship_species, parent: genus)
      s2 = FactoryBot.create(:relationship_species, parent: genus)
      r1 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating')
      r2 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
      r3 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      r1.soft_validate(only_sets: :not_specific_relationship)
      r2.soft_validate(only_sets: :not_specific_relationship)
      r3.soft_validate(only_sets: :not_specific_relationship)
      # reason of being invalid?
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      # primary or secondary homonym?
      expect(r2.soft_validations.messages_on(:type).size).to eq(1)
      # objective or subjective synonym?
      expect(r3.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'fix not specific relationships from synonym to objective synonym' do
      g1 = FactoryBot.create(:relationship_genus, parent: family)
      g2 = FactoryBot.create(:relationship_genus, parent: family)
      s1 = FactoryBot.create(:relationship_species, parent: g1)
      r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g1, type: 'TaxonNameRelationship::Typification::Genus')
      r3 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: g2, type: 'TaxonNameRelationship::Typification::Genus')
      r1.soft_validate(only_sets: :not_specific_relationship)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      
      r1.fix_soft_validations
      r1 = TaxonNameRelationship.find(r1.id)
      r1.soft_validate(only_sets: :not_specific_relationship)

      # @proceps Nowhere in the fix does the relationship type chagne?
      expect(r1.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'same type specimen fix to objective synonym' do
      s1             = FactoryBot.create(:relationship_species, parent: genus)
      s2             = FactoryBot.create(:relationship_species, parent: genus)
      type_material1 = FactoryBot.create(:valid_type_material, protonym: s1)
      type_material2 = FactoryBot.create(:valid_type_material, collection_object_id: type_material1.collection_object_id, protonym: s2)
      r              = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      r.soft_validate(only_sets: :not_specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
      r.fix_soft_validations
      r = TaxonNameRelationship.find(r.id)
      r.soft_validate(only_sets: :not_specific_relationship)
      expect(r.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      expect(r.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'subjective synonyms should have different type specimen' do
      s1             = FactoryBot.create(:relationship_species, parent: genus)
      s2             = FactoryBot.create(:relationship_species, parent: genus)
      type_material1 = FactoryBot.create(:valid_type_material, protonym: s1)
      type_material2 = FactoryBot.create(:valid_type_material, protonym: s2)
      r              = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      r.soft_validate(only_sets: :not_specific_relationship)
      expect(r.soft_validations.messages_on(:type).size).to eq(1)
      r.fix_soft_validations
      r = TaxonNameRelationship.find(r.id)
      r.soft_validate(only_sets: :not_specific_relationship)
      expect(r.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
      expect(r.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'fix not specific relationships from homonym to primary homonym' do
      s1 = FactoryBot.create(:relationship_species, parent: genus)
      s2 = FactoryBot.create(:relationship_species, parent: genus)
      r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: s1, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym')
      r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: s1, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      r3 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: s2, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      s1.reload
      s2.reload
      r1.soft_validate(only_sets: :not_specific_relationship)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      r1.fix_soft_validations
      r1 = TaxonNameRelationship.find(r1.id)
      r1.soft_validate(only_sets: :not_specific_relationship)
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
    end
  end

  #    specify 'parent is a synonym' do #### We allow synonyms of synonyms in a new model. This test is not needed any more.
  #      g1 = FactoryBot.create(:relationship_genus, parent: family)
  #      g2 = FactoryBot.create(:relationship_genus, parent: family)
  #      r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
  #      r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
  #      r1.soft_validate(only_sets: :synonym_linked_to_valid_name)
  #      r2.soft_validate(only_sets: :synonym_linked_to_valid_name)
  #      expect(r1.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_truthy
  #      # parent is a synonym of another taxon
  #      expect(r2.soft_validations.messages_on(:object_taxon_name_id).size).to eq(1)
  #      r2.fix_soft_validations
  #      r2.soft_validate(only_sets: :synonym_linked_to_valid_name)
  #      # parent updated to valid name
  #      expect(r2.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_truthy
  #    end

  specify 'synonym should have same parent' do
    f  = FactoryBot.create(:relationship_family, parent: kingdom)
    g1 = FactoryBot.create(:relationship_genus, parent: f)
    g2 = FactoryBot.create(:relationship_genus, parent: family)
    r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g2, object_taxon_name: g1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
    r1.soft_validate(only_sets: :synonym_linked_to_valid_name)
    expect(r1.soft_validations.messages_on(:subject_taxon_name_id).size).to eq(1)
    r1.fix_soft_validations
    r1.soft_validate(only_sets: :synonym_linked_to_valid_name)
    expect(r1.soft_validations.messages_on(:subject_taxon_name_id).empty?).to be_truthy
    expect(g2.parent_id).to eq(f.id)
  end

  specify 'type genus should have the same first letter' do
    f1 = FactoryBot.create(:relationship_family, parent: kingdom)
    g1 = FactoryBot.create(:relationship_genus, name: 'Bus', parent: f1)
    r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g1, object_taxon_name: f1, type: 'TaxonNameRelationship::Typification::Family')
    r1.soft_validate(only_sets: :matching_type_genus)
    expect(r1.soft_validations.messages_on(:object_taxon_name_id).size).to eq(1)
  end

  context 'priority' do
    let(:g1_all) { FactoryBot.create(:relationship_genus, parent: family, year_of_publication: 2005) }
    let(:s1_all) { FactoryBot.create(:relationship_species, parent: g1_all, year_of_publication: 2000) }
    let(:s2_all) { FactoryBot.create(:relationship_species, parent: g1_all, year_of_publication: 2001) }

    specify 'FirstRevisorAction' do
      r1 = TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction.new(subject_taxon_name: s1_all, object_taxon_name: s2_all)
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:object_taxon_name_id).size).to eq(1)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'direct priority' do
      r1 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s1_all, object_taxon_name: s2_all, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      c1 = FactoryBot.create(:taxon_name_classification, taxon_name: s1_all, type: 'TaxonNameClassification::Iczn::Unavailable')
      s1_all.reload
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
      c1.delete
      s1_all.reload
    end

    specify 'reverse priority' do
      r1 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: s2_all, object_taxon_name: s1_all, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'reverse priority original genus' do
      r1 = FactoryBot.build_stubbed(:taxon_name_relationship, subject_taxon_name: g1_all, object_taxon_name: s2_all, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
    end

    specify 'synonym and homonym or conserved' do
      r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1_all, object_taxon_name: s2_all, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1_all, object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
      r2.type = 'TaxonNameRelationship::Iczn::Validating::ConservedName'
      expect(r2.save).to be_truthy
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'synonym and homonym or conserved' do
      g1 = FactoryBot.create(:icn_genus)
      s1 = FactoryBot.create(:icn_species, parent: g1, year_of_publication: 2000)
      s2 = FactoryBot.create(:icn_species, parent: g1, year_of_publication: 2001)
      s3 = FactoryBot.create(:icn_species, parent: g1, year_of_publication: 1999)
      r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s2, type: 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).size).to eq(1)
      r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: s3, type: 'TaxonNameRelationship::Icn::Accepting::SanctionedName')
      r1.soft_validate(only_sets: :validate_priority)
      expect(r1.soft_validations.messages_on(:type).empty?).to be_truthy
    end

    specify 'synonym should be linked to subspecies in subject' do
      ssp = FactoryBot.create(:iczn_subspecies, source: nil, parent: s1_all, name: s1_all.name)
      r1  = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s1_all, object_taxon_name: s2_all, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      r1.soft_validate(only_sets: :coordinated_taxa)
      expect(r1.soft_validations.messages_on(:subject_taxon_name_id).size).to eq(1)
      expect(r1.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_truthy
      r1.fix_soft_validations
      r1.soft_validate(only_sets: :coordinated_taxa)
      expect(r1.soft_validations.messages_on(:subject_taxon_name_id).empty?).to be_truthy
      expect(r1.subject_taxon_name_id).to eq(ssp.id)
    end

    specify 'synonym should be linked to subspecies in object' do
      ssp = FactoryBot.create(:iczn_subspecies, source: nil, parent: s1_all, name: s1_all.name)
      r1  = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: s2_all, object_taxon_name: s1_all, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective')
      r1.soft_validate(only_sets: :coordinated_taxa)
      expect(r1.soft_validations.messages_on(:object_taxon_name_id).size).to eq(1)
      expect(r1.soft_validations.messages_on(:subject_taxon_name_id).empty?).to be_truthy
      r1.fix_soft_validations
      r1.soft_validate(only_sets: :coordinated_taxa)
      expect(r1.soft_validations.messages_on(:object_taxon_name_id).empty?).to be_truthy
      expect(r1.object_taxon_name_id).to eq(ssp.id)
    end
  end


end
