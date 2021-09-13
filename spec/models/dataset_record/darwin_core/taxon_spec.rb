require 'rails_helper'

describe 'DatasetRecord::DarwinCore::Taxon', type: :model do

  let!(:root) { FactoryBot.create(:root_taxon_name) }

  context 'when importing a parent and child taxon from a text file' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/parent_child.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:results) { import_dataset.import(5000, 100).concat(import_dataset.import(5000, 100)) }

    let(:parent) { TaxonName.find(results[0].metadata.dig('imported_objects', 'taxon_name', 'id')) }
    let(:child) { TaxonName.find(results[1].metadata.dig('imported_objects', 'taxon_name', 'id')) }

    it 'creates and imports two records' do
      expect(results.length).to eq(2)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'creates a family protonym' do
      expect(TaxonName.find_by(name: 'Formicidae')).to be_an_is_protonym
    end
    it 'assigns the correct rank to the family protonym' do
      expect(TaxonName.find_by(name: 'Formicidae').rank_string).to eq('NomenclaturalRank::Iczn::FamilyGroup::Family')
    end
    it 'creates a genus protonym' do
      expect(TaxonName.find_by(name: 'Calyptites')).to be_an_is_protonym
    end

    it 'should have a parent child relationship' do
      expect(TaxonName.find_by(cached: 'Calyptites').parent).to eq(TaxonName.find_by(name: 'Formicidae'))
    end

    it 'creates an original genus relationship' do
      genus = TaxonName.find_by(name: 'Calyptites')
      expect_original_combination(genus, genus, 'genus')
    end

    context 'the saved DwC-A import metadata' do
      let(:import_attribute) { DataAttribute.find_by_attribute_subject_id(parent.id) }

      it 'should have the "DwC-A import metadata" import predicate' do
        expect(import_attribute.import_predicate).to eq('DwC-A import metadata')
      end

      it 'should have an attribute subject type of TaxonName' do
        expect(import_attribute.attribute_subject_type).to eq 'TaxonName'
      end

      it 'should have the correct row metadata' do
        pending "need to convert from json string to ruby hash"
        expect(import_attribute.value['scientificName']).to eq 'Formicidae'
        expect(import_attribute.value['scientificNameAuthorship']).to eq 'Latreille, 1809'
        expect(import_attribute.value['taxonRank']).to eq 'genus'
      end

    end
  end

  context 'when importing a homonym with a replacement taxon' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/homonym.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:results) {
      results = []
      4.times { |_|
        results.concat import_dataset.import(5000, 100)
      }
      results
    }


    let(:senior_homonym) { TaxonName.find_by(name: 'barbatus', year_of_publication: 1863) }
    let(:junior_homonym) { TaxonName.find_by(name: 'barbatus', year_of_publication: 1926) }
    let(:replacement_name) { TaxonName.find_by_cached('Camponotus (Tanaemyrmex) barbosus') }

    it 'should create 5 imported records' do
      expect(results.length).to eq(5)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    context 'the subgenus' do
      it 'should have three child protonym records' do
        expect(TaxonName.find_by_name("Tanaemyrmex").descendant_protonyms.length).to eq 3
      end
    end

    it 'junior homonym should be invalid' do
      expect(junior_homonym).to_not be_is_valid
    end

    it 'should have a homonym relationship' do
      pending "need to switch to checking for relationship"
      relationship = TaxonNameRelationship.find_by({subject_taxon_name: junior_homonym, object_taxon_name: senior_homonym})
      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Homonym')

      # expect(TaxonNameClassification.find_by_taxon_name_id(TaxonName.find_by(name: 'barbatus', year_of_publication: 1926)).rank).to eq('TaxonNameClassification::Iczn::Available::Invalid::Homonym')
    end

    it 'should should have a replacement name relationship' do
      relationship = TaxonNameRelationship.find_by({subject_taxon_name: junior_homonym, object_taxon_name: replacement_name})
      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym')
    end

    it 'should have 9 original combination relationships' do
      expect(TaxonNameRelationship::OriginalCombination.all.length).to eq 9
    end

    it 'should have Baroni Urbani as the author of the replacement species' do
      expect(TaxonName.find_by_name("barbosus").cached_author_year).to eq('Baroni Urbani, 1971')
    end

  end

  context 'when importing a subspecies synonym of a species' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/synonym.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let(:parent_id) { results[0].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:valid_id) { results[1].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:synonym_parent_id) { results[2].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:synonym_id) { results[3].metadata.dig('imported_objects', 'taxon_name', 'id') }

    let!(:results) {
      results = []
      3.times { |_|
        results.concat import_dataset.import(5000, 100)
      }
      results
    }


    it 'should create 4 records' do
      expect(results.length).to eq(4)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have a synonym relationship ' do
      relationship = TaxonNameRelationship.find_by(subject_taxon_name_id: synonym_id, object_taxon_name_id: valid_id)

      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym')
    end

    it 'should have four original combinations' do
      expect(TaxonNameRelationship::OriginalCombination.all.length).to eq 8
    end

    context 'the synonym TaxonName' do
      let(:synonym) {TaxonName.find_by({ id: synonym_id })}

      it 'should be cached invalid' do
        expect(synonym.cached_is_valid).to be false
      end

      it 'the synonym should have cached valid taxon id' do
        expect(synonym.cached_valid_taxon_name_id).to eq valid_id
      end

      it "the synonym's parent should be Apterostigma wasmannii" do
        expect(synonym.parent.id).to eq synonym_parent_id
      end
    end

  end

  context 'when importing homonyms that are moved to another genus' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/moved_homonym.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:results) { import_dataset.import(5000, 100).concat(import_dataset.import(5000, 100)) }

    it 'should have two taxon names equal to "Formica longipes"' do
      expect(TaxonName.where({ cached_original_combination: 'Formica longipes' }).length).to eq(2)
    end

    it 'should have 7 protonyms' do # Root, Formica, Anoplolepis, Pheidole, longipes, longipes, gracilipes
      expect(Protonym.all.length).to eq 7
    end

    it 'should have 3 combinations' do  # Pheidole longipes, Anoplolepis longipes, Anoplolepis gracilipes
      expect(Combination.all.length).to eq 3
    end

    it 'should have 5 valid taxon names' do
      pending
    end

    it 'Pheidole longipes author name should be the same as Formica longipes but in parentheses' do

      parent_author_year = TaxonName.find_by({cached: 'Pheidole longipes'}).parent.cached_author_year
      pheidole_author_year = TaxonName.find_by({cached: 'Pheidole longipes'}).cached_author_year

      expect('(' + parent_author_year + ')').to eq(pheidole_author_year)
    end

    it 'Anoplolepis longipes should be a homonym of Pheidole longipes' do
      pending
    end

    it 'Formica longipes Jerdon, 1851 should have a replacement of Anoplolepis gracilipes' do
      pending
    end

    it 'Pheidole longipes cached original combination should be Formica longipes' do
      pending
    end

    it 'Anoplolepis longipes valid taxon should be Anoplolepis gracilipes' do
      pending
    end

  end

  context 'when importing a combination that moved genera' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/combination.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let(:combination_parent_id) { results[0].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:current_parent_id) { results[1].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:valid_id) { results[2].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:combination_id) { results[3].metadata.dig('imported_objects', 'taxon_name', 'id') }

    let!(:results) {
      results = []
      4.times { |_|
        results.concat import_dataset.import(5000, 100)
      }
      results
    }

    it 'should have four protonyms' do  # Root, Camponotites, Oecophylla, kraussei
      expect(Protonym.all.length).to eq 4
    end

    it 'should have one Combination' do
      expect(Combination.all.length).to eq 1
      expect(TaxonName.find_by_cached('Camponotites kraussei')).to be_a Combination
    end

    it 'should have a genus taxon name relationship' do
      expect(Combination.first.genus_taxon_name_relationship).to be_a(TaxonNameRelationship::Combination::Genus)
    end

    it 'should have the proper author' do
      expect(TaxonName.find_by_cached('Oecophylla kraussei').cached_author_year).to eq '(Dlussky & Rasnitsyn, 1999)'
    end

    it 'searching for original combination should return current name' do
      expect(TaxonName.find_by_cached_original_combination('Camponotites kraussei').id).to eq(valid_id)
    end

    it 'searching for the protonym kraussei should return valid name' do
      expect(Protonym.find_by_name('kraussei')).to be_is_valid
    end

  end

  context 'when importing a subspecies' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/subspecies.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:results) {
      results = []
      3.times { |_|
        results.concat import_dataset.import(5000, 100)
      }
      results
    }

    let(:genus_id) { results[0].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:species_id) { results[1].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:subspecies_id) { results[2].metadata.dig('imported_objects', 'taxon_name', 'id') }

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
end


# Helper method to expect an OriginalCombination relationship with less code duplication
# @param [Integer, Protonym] subject_taxon_name
# @param [Integer, Protonym] object_taxon_name
# @param [String] rank The (short) rank to expect in the relationship
def expect_original_combination(subject_taxon_name, object_taxon_name, rank)
  expect(TaxonNameRelationship.find_by({ subject_taxon_name: subject_taxon_name, object_taxon_name: object_taxon_name }).type_name).to eq('TaxonNameRelationship::OriginalCombination::Original' + rank.capitalize)
end
