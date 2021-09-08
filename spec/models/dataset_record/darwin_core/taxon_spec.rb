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
      expect(TaxonNameRelationship.find_by({ subject_taxon_name: genus, object_taxon_name: genus }).type_name).to eq('TaxonNameRelationship::OriginalCombination::OriginalGenus')
    end

    it 'saves DwC-A import metadata as a data attribute' do
      pending
    end

  end

  context 'when importing a homonym with a replacement taxon' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/homonym.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:results) { import_dataset.import(5000, 100).concat(import_dataset.import(5000, 100)).concat(import_dataset.import(5000, 100)) }

    it 'should create 4 imported records' do
      expect(results.length).to eq(4)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have three child records' do
      expect(TaxonName.find_by_name("Tanaemyrmex").descendant_protonyms.length).to eq 3
    end

    it 'should have a homonym relationship' do
      expect(TaxonNameClassification.find_by_taxon_name_id(TaxonName.find_by(name: 'barbatus', year_of_publication: 1926)).type).to eq('TaxonNameClassification::Iczn::Available::Invalid::Homonym')
    end

    it 'should should have a replacement name relationship' do
      pending "if we can derive this data from DwC spec"
    end

    it 'should have 4 original combination relationships' do
      expect(TaxonNameRelationship::OriginalCombination.all.length).to eq 4
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

    let!(:results) { import_dataset.import(5000, 100).concat(import_dataset.import(5000, 100)).concat(import_dataset.import(5000, 100)) }

    it 'should create 4 records' do
      expect(results.length).to eq(4)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have a synonym relationship ' do
      relationship = TaxonNameRelationship.find_by(subject_taxon_name_id: synonym_id, object_taxon_name_id: valid_id)

      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym')
    end

    it 'should have four original combinations' do
      expect(TaxonNameRelationship::OriginalCombination.all.length).to eq 4
    end

    it 'the synonym should be cached invalid' do
      expect(TaxonName.find_by({ id: synonym_id }).cached_is_valid).to eq(false)
    end

    it 'the synonym should have cached valid taxon id' do
      expect(TaxonName.find_by({ id: synonym_id }).cached_valid_taxon_name_id).to eq(valid_id)
    end

    it "the synonym's parent should be Apterostigma wasmannii" do
      expect(TaxonName.find_by({ id: synonym_id }).parent.id).to eq(synonym_parent_id)
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
    let(:combination_id) { results[2].metadata.dig('imported_objects', 'taxon_name', 'id') }
    let(:valid_id) { results[3].metadata.dig('imported_objects', 'taxon_name', 'id') }

    let!(:results) {
      results = []
      4.times do |_|
        results.concat import_dataset.import(5000, 100)
      results
    end
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

  end

end
