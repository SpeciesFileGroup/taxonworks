require 'rails_helper'
require 'database_cleaner/active_record'

describe 'DatasetRecord::DarwinCore::Taxon', type: :model do

  before :all do
    DatabaseCleaner.start
    FactoryBot.create(:root_taxon_name)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  context 'when importing a parent and child taxon from a text file' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/parent_child.tsv'), 'text/plain'),
        description: 'parent_child'
      ).tap { |i| i.stage }

      2.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:parent) { TaxonName.find_by(name: 'Formicidae') }
    let(:child) { TaxonName.find_by(name: 'Calyptites') }
    let(:results) {}

    it 'creates and imports two records' do
      expect(DatasetRecord.all.count).to eq(2)
      expect(DatasetRecord.all.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'creates a family protonym' do
      expect(parent).to be_an_is_protonym
    end
    it 'assigns the correct rank to the family protonym' do
      expect(parent.rank_string).to eq('NomenclaturalRank::Iczn::FamilyGroup::Family')
    end
    it 'creates a genus protonym' do
      expect(child).to be_an_is_protonym
    end

    it 'should have a parent child relationship' do
      expect(child.parent).to eq(parent)
    end

    it 'creates an original genus relationship' do
      genus = TaxonName.find_by(name: 'Calyptites')
      expect_original_combination(child, genus, 'genus')
    end

    context 'the saved DwC-A import metadata' do
      let(:import_attribute) { DataAttribute.find_by(attribute_subject_id: parent.id) }

      it 'should have the "DwC-A import metadata" import predicate' do
        expect(import_attribute.import_predicate).to eq('DwC-A import metadata')
      end

      it 'should have an attribute subject type of TaxonName' do
        expect(import_attribute.attribute_subject_type).to eq 'TaxonName'
      end

      it 'should have the correct row metadata' do
        pending 'need to convert from json string to ruby hash'
        expect(import_attribute.value['scientificName']).to eq 'Formicidae'
        expect(import_attribute.value['scientificNameAuthorship']).to eq 'Latreille, 1809'
        expect(import_attribute.value['taxonRank']).to eq 'genus'
      end

    end
  end

  context 'when importing a homonym with a replacement taxon' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/homonym.tsv'), 'text/plain'),
        description: 'homonym'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:senior_homonym) { TaxonName.find_by(name: 'barbatus', year_of_publication: 1863) }
    let(:junior_homonym) { TaxonName.find_by(name: 'barbatus', year_of_publication: 1926) }
    let(:replacement_name) { TaxonName.find_by(cached: 'Camponotus (Tanaemyrmex) barbosus') }

    it 'should create 5 imported records' do
      expect(DatasetRecord.all.count).to eq(5)
      expect(DatasetRecord.all.map { |row| row.status }).to all(eq('Imported'))
    end

    context 'the subgenus' do
      it 'should have three child protonym records' do
        expect(TaxonName.find_by(name: 'Tanaemyrmex').descendant_protonyms.length).to eq 3
      end
    end

    it 'junior homonym should be invalid' do
      expect(junior_homonym).to_not be_is_valid
    end

    it 'should have a homonym status' do
      expect(TaxonNameClassification.find_by(taxon_name_id: TaxonName.find_by(name: 'barbatus', year_of_publication: 1926)).type).to eq('TaxonNameClassification::Iczn::Available::Invalid::Homonym')
    end

    it 'should should have a replacement name relationship' do
      relationship = TaxonNameRelationship.find_by({ subject_taxon_name: junior_homonym, object_taxon_name: replacement_name })
      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym')
    end

    it 'should have 12 original combination relationships' do
      expect(TaxonNameRelationship::OriginalCombination.all.length).to eq 12
    end

    it 'should have Baroni Urbani as the author of the replacement species' do
      expect(TaxonName.find_by(name: 'barbosus').cached_author_year).to eq('Baroni Urbani, 1971')
    end

  end

  context 'when importing a subspecies synonym of a species' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/synonym.tsv'), 'text/plain'),
        description: 'synonym'
      ).tap { |i| i.stage }

      3.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:parent) { TaxonName.find_by(name: 'Apterostigma') }
    let(:valid) { TaxonName.find_by(cached: 'Apterostigma auriculatum') }
    let(:synonym) { TaxonName.find_by({ name: 'icta' }) }
    let(:synonym_parent) { TaxonName.find_by({ name: 'wasmannii' }) }

    it 'should create 4 records' do
      expect(DatasetRecord.all.count).to eq(4)
    end

    it 'should have a synonym relationship ' do
      relationship = TaxonNameRelationship.find_by({ subject_taxon_name_id: synonym.id, object_taxon_name_id: valid.id })
      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym')
    end

    it 'should have eight original combinations' do
      expect(TaxonNameRelationship::OriginalCombination.all.length).to eq 8
    end

    context 'the synonym TaxonName' do
      it 'should be cached invalid' do
        expect(synonym.cached_is_valid).to be false
      end

      it 'the synonym should have cached valid taxon id' do
        expect(synonym.cached_valid_taxon_name_id).to eq valid.id
      end

      it "the synonym's parent should be Apterostigma wasmannii" do
        expect(synonym.parent.id).to eq synonym_parent.id
      end
    end
  end

  context 'when importing homonyms that are moved to another genus' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/moved_homonym.tsv'), 'text/plain'),
        description: 'moved_homonym'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    it 'should create 9 imported records' do
      expect(DatasetRecord.all.count).to eq(9)
      expect(DatasetRecord.all.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have two taxon names equal to "Formica longipes"' do
      expect(TaxonName.where({ cached_original_combination: 'Formica longipes' }).length).to eq(2)
    end

    it 'should have 7 protonyms' do
      # Root, Formica, Anoplolepis, Pheidole, longipes, longipes, gracilipes
      expect(Protonym.all.length).to eq 7
    end

    it 'should not have combinations besides original combinations' do
      # Pheidole longipes, Anoplolepis longipes, Anoplolepis gracilipes
      expect(Combination.all.length).to eq 0
    end

    it 'should have 4 original species relationships' do    # Anoplolepis longipes, Anoplolepis gracilipes, Pheidole longipes
      expect(TaxonNameRelationship.where(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies').count).to eq 3
    end

    it 'should have 5 valid taxon names' do # "Root", "Formica", "Anoplolepis", "Pheidole", "Anoplolepis gracilipes", "Pheidole longipes"
      expect(TaxonName.that_is_valid.count).to eq 6
    end

    it 'Anoplolepis longipes should have homonym status' do
      expect(TaxonNameClassification.find_by(taxon_name_id: TaxonName.find_by(name: 'longipes', year_of_publication: 1851)).type).to eq('TaxonNameClassification::Iczn::Available::Invalid::Homonym')
    end

    it 'Anoplolepis longipes should be a homonym of Pheidole longipes', :skip do
    end

    it 'Formica longipes Jerdon, 1851 should have a replacement of Anoplolepis gracilipes' do
      longipes_jerdon = TaxonName.find_by(name: 'longipes', year_of_publication: 1851)
      relationship = TaxonNameRelationship.find_by({ subject_taxon_name: longipes_jerdon,
                                                     object_taxon_name: TaxonName.find_by(cached: 'Anoplolepis gracilipes') })
      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym')
    end

    it 'Pheidole longipes cached original combination should be Formica longipes' do
      expect(TaxonName.find_by(cached: 'Pheidole longipes').cached_original_combination).to eq 'Formica longipes'
    end

    it 'Anoplolepis longipes valid taxon should be Anoplolepis gracilipes' do
      expect(TaxonName.find_by(cached: 'Anoplolepis longipes').cached_valid_taxon_name_id).to eq TaxonName.find_by(cached: 'Anoplolepis gracilipes').id
    end

  end

  context 'when importing a combination that moved genera' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/combination.tsv'), 'text/plain'),
        description: 'combination'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:valid) { TaxonName.find_by({ cached: 'Oecophylla kraussei' }) }

    it 'all records should import without error' do
      expect(DatasetRecord.all.count).to eq(4)
      expect(DatasetRecord.all.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have four protonyms' do
      # Root, Camponotites, Oecophylla, kraussei
      expect(Protonym.all.length).to eq 4
    end

    it 'should not have a Combination separate from original combination' do
      expect(Combination.all.length).to eq 0
      # expect(TaxonName.find_by_cached('Camponotites kraussei')).to be_a Combination
    end

    it 'should have the proper author' do
      expect(TaxonName.find_by(cached: 'Oecophylla kraussei').cached_author_year).to eq '(Dlussky & Rasnitsyn, 1999)'
    end

    it 'searching for original combination should return current name' do
      expect(TaxonName.find_by(cached_original_combination: 'Camponotites kraussei').id).to eq(valid.id)
    end

    it 'searching for the protonym kraussei should return valid name' do
      expect(Protonym.find_by(name: 'kraussei')).to be_is_valid
    end

  end

  context 'when importing a subspecies' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/subspecies.tsv'), 'text/plain'),
        description: 'subspecies'
      ).tap { |i| i.stage }

      3.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:genus_id) { Protonym.find_by(rank_class: Ranks.lookup(:iczn, :genus)) }
    let(:species_id) { Protonym.find_by(rank_class: Ranks.lookup(:iczn, :species)) }
    let(:subspecies_id) { Protonym.find_by(rank_class: Ranks.lookup(:iczn, :subspecies)) }

    it 'should have three protonyms' do
      expect(Protonym.all.length).to eq 4
    end

    context 'the imported genus' do
      it 'should have an original genus relationship between to itself' do
        expect_original_combination(genus_id, genus_id, 'genus')
      end
    end

    context 'the imported species' do
      it 'should have an original species relationship to itself' do
        expect_original_combination(species_id, species_id, 'species')
      end
      it 'should have an original genus relationship between genus and species' do
        expect_original_combination(genus_id, species_id, 'genus')
      end
    end

    context 'the imported subspecies' do
      it 'should have an original subspecies relationship to itself' do
        expect_original_combination(subspecies_id, subspecies_id, 'subspecies')
      end

      it 'should have an original species relationship between species and subspecies' do
        expect_original_combination(species_id, subspecies_id, 'species')
      end

      it 'should have an original genus relationship between genus and subspecies' do
        expect_original_combination(genus_id, subspecies_id, 'genus')
      end
    end
  end

  context 'when importing a file with three names for one protonym' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/multiple_combination.tsv'), 'text/plain'),
        description: 'parent_child'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:combination) { TaxonName.find_by(cached: 'Tapinoma pusillum') }
    let(:valid) { TaxonName.find_by(name: 'Arnoldius pusillus') }

    it 'creates and imports six records' do
      verify_all_records_imported(6)
    end

    it 'should have one combination' do
      expect(Combination.all.length).to eq 1
      expect(TaxonName.find_by(cached: 'Bothriomyrmex pusillus')).to be_a Combination
    end

    it 'Tapinoma pusillum should be the original combination for the Bothriomyrmex pusillus' do

    end

    it 'should have a genus taxon name relationship' do
      expect(Combination.first.genus_taxon_name_relationship).to be_a(TaxonNameRelationship::Combination::Genus)
    end

  end

  context 'when importing a file with three names for one protonym' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/genus_synonyms.tsv'), 'text/plain'),
        description: 'parent_child'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:valid) { TaxonName.find_by(name: 'Acropyga') }

    it 'creates and imports six records' do
      verify_all_records_imported(6)
    end

    it 'the valid genus should have three synonyms' do
      expect(TaxonNameRelationship.where_object_is_taxon_name(valid).where(type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym').count).to eq 3
    end

    it 'all should have the same valid id' do
      expect(TaxonName.where(cached_valid_taxon_name_id: valid.id).count).to eq 6
    end

  end

  context 'when importing a file with an original combination subspecies and protonym species' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/oc_as_subspecies.tsv'), 'text/plain'),
        description: 'subspecies oc and species protonym'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    # should be 5 protonyms (Root, Aphaenogaster, Atta, curiosa, gemella)
    it 'should have 5 protonyms' do
      expect(Protonym.all.length).to eq 5
    end

    it 'creates and imports 6 records' do
      verify_all_records_imported(6)
    end

    # cached oc of curiosa should be Aphaenogaster gemella curiosa
    it 'cached OC of "Aphaenogaster curiosa" should be "Aphaenogaster gemella curiosa"' do
      expect(Protonym.find_by(name: 'curiosa').cached_original_combination).to eq 'Aphaenogaster gemella curiosa'
    end

    # there should be no Combinations, only Original Combinations
    it 'should have no Combinations' do
      expect(Combination.count).to eq 0
    end

  end

  context 'when importing subspecies with OC that is a combination' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/oc_is_combination.tsv'), 'text/plain'),
        description: 'oc is combination'
      ).tap { |i| i.stage }

      7.times { |_|
        import_dataset.import(5000, 100)
      }
    end

    after :all do
      DatabaseCleaner.clean
    end

    # Root, Leptothorax, Temnothorax, flavispinus, nigritus, amilcaris
    it 'should have 6 protonyms' do
      expect(Protonym.all.length).to eq 6
    end

    it 'imports 9 records' do
      verify_all_records_imported(9)
    end

    # Leptothorax flavispinus (André, 1883)
    it 'should have 1 combination' do
      expect(Combination.count).to eq 1
      expect(Combination.find_by_cached("Leptothorax flavispinus")).to_not be_nil
    end

    it 'cached OC of Temnothorax flavispinus amilcaris should be Leptothorax flavispinus amilcaris' do
      expect_original_combination(Protonym.find_by(name: "Leptothorax"), Protonym.find_by(name: "amilcaris"), "genus")
      expect_original_combination(Protonym.find_by(name: "flavispinus"), Protonym.find_by(name: "amilcaris"), "species")
    end

    # should be Leptothorax nigrita flavispinus, but because of import process we don't properly handle gender properly
    # As a result, we end up using nigritus from Temnothorax nigritus instead.
    it 'cached OC of Temnothorax flavispinus should be Leptothorax nigrita flavispinus' do
      expect_original_combination(Protonym.find_by(name: "Leptothorax"), Protonym.find_by(name: "flavispinus"), "genus")
      expect_original_combination(Protonym.find_by(name: "nigritus"), Protonym.find_by(name: "flavispinus"), "species")

    end

  end

  context 'when importing a genus classified as incertae sedis' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/incertae_sedis/genus_incertae_sedis_in_family.tsv'), 'text/plain'),
        description: 'genus incertae sedis in family'
      ).tap { |i| i.stage }

      2.times { |_|
        import_dataset.import(5000, 100)
      }
    end
    after :all do
      DatabaseCleaner.clean
    end

    # Root, Formicidae, Hypochira
    it 'should have 3 protonyms' do
      expect(Protonym.all.length).to eq 3
    end

    it 'imports 2 records' do
      verify_all_records_imported(2)
    end

    let(:family) { TaxonName.find_by(name: 'Formicidae') }
    let(:genus) { TaxonName.find_by(name: 'Hypochira') }

    it 'genus should have UncertainPlacement relationship with family' do
      expect(TaxonNameRelationship.find_by(subject_taxon_name: genus, object_taxon_name: family).type_name).to eq('TaxonNameRelationship::Iczn::Validating::UncertainPlacement')
    end
  end

  context 'when importing a genus and species that are incertae sedis in family' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/incertae_sedis/incertae_sedis_in_family.tsv'), 'text/plain'),
        description: 'incertae sedis in family'
      ).tap { |i| i.stage }

      3.times { |_|
        import_dataset.import(5000, 100)
      }
    end
    after :all do
      DatabaseCleaner.clean
    end

    # Root, Formicidae, Condylodon, audouini
    it 'should have 3 protonyms' do
      expect(Protonym.all.length).to eq 3
    end

    it 'imports 3 records' do
      verify_all_records_imported(3)
    end

    let(:genus) { TaxonName.find_by(name: 'Condylodon') }
    let(:species) { TaxonName.find_by(name: 'audouini') }
    let(:family) { TaxonName.find_by(name: 'Formicidae') }

    it 'genus should have UncertainPlacement relationship with family' do
      expect(TaxonNameRelationship.find_by(subject_taxon_name: genus, object_taxon_name: family).type_name).to eq('TaxonNameRelationship::Iczn::Validating::UncertainPlacement')
    end

    it 'species should have UncertainPlacement relationship with family' do
      expect(TaxonNameRelationship.find_by(subject_taxon_name: species, object_taxon_name: family).type_name).to eq('TaxonNameRelationship::Iczn::Validating::UncertainPlacement')
    end
  end

  context 'when importing a species classified as incertae sedis in genus' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/incertae_sedis/incertae_sedis_in_genus.tsv'), 'text/plain'),
        description: 'incertae sedis in genus'
      ).tap { |i| i.stage }

      2.times { |_|
        import_dataset.import(5000, 100)
      }
    end
    after :all do
      DatabaseCleaner.clean
    end

    # Root, Formica, fuscescens
    it 'should have 3 protonyms' do
      expect(Protonym.all.length).to eq 3
    end

    it 'imports 2 records' do
      verify_all_records_imported(2)
    end

    let(:genus) { TaxonName.find_by(name: 'Formica') }
    let(:species) { TaxonName.find_by(name: 'fuscescens') }

    it 'genus should not have UncertainPlacement' do
      expect(genus.iczn_uncertain_placement_relationship).to be_falsey
    end

    it 'species should have UncertainPlacement relationship with genus' do
      expect(TaxonNameRelationship.find_by(subject_taxon_name: species, object_taxon_name: genus).type_name).to eq('TaxonNameRelationship::Iczn::Validating::UncertainPlacement')
    end
  end

  context 'when importing a moved species classified as incertae sedis in genus' do
    before :all do
      DatabaseCleaner.start
      import_dataset = ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/incertae_sedis/incertae_sedis_moved_genus.tsv'), 'text/plain'),
        description: 'incertae sedis in genus'
      ).tap { |i| i.stage }

      4.times { |_|
        import_dataset.import(5000, 100)
      }
    end
    after :all do
      DatabaseCleaner.clean
    end

    # Root, Formicidae, Formica, Cephalotes, fuscescens
    it 'should have 5 protonyms' do
      expect(Protonym.all.length).to eq 5
    end

    it 'imports 5 records' do
      verify_all_records_imported(5)
    end

    let(:current_genus) { TaxonName.find_by(name: 'Cephalotes') }
    let(:old_genus) {TaxonName.find_by(name: 'Formica')}
    let(:species) { TaxonName.find_by(name: 'fuscescens') }

    it 'genus should not have UncertainPlacement' do
      expect(old_genus.iczn_uncertain_placement_relationship).to be_falsey
      expect(current_genus.iczn_uncertain_placement_relationship).to be_falsey
    end

    it 'species should have UncertainPlacement relationship with genus' do
      expect(TaxonNameRelationship.find_by(subject_taxon_name: species, object_taxon_name: current_genus).type_name).to eq('TaxonNameRelationship::Iczn::Validating::UncertainPlacement')
    end

    it 'should have an original combination relationship with old genus' do
      expect_original_combination(old_genus, species, 'genus')
    end
  end

  # TODO test missing parent
  #
  # TODO test protonym is unavailable --- set classification on unsaved TaxonName
  #
  # TODO test importing multiple times
end

# Helper method to expect an OriginalCombination relationship with less code duplication
# @param [Integer, Protonym] subject_taxon_name
# @param [Integer, Protonym] object_taxon_name
# @param [String] rank The (short) rank to expect in the relationship
def expect_original_combination(subject_taxon_name, object_taxon_name, rank)
  expect(TaxonNameRelationship.find_by({ subject_taxon_name: subject_taxon_name, object_taxon_name: object_taxon_name }).type_name).to eq('TaxonNameRelationship::OriginalCombination::Original' + rank.capitalize)
end

def verify_all_records_imported(num_records)
  expect(DatasetRecord.all.count).to eq(num_records)
  expect(DatasetRecord.all.map { |row| row.status }).to all(eq('Imported'))
end
