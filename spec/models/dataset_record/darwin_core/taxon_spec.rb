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
      expect(results.map { |row| row.status}).to all(eq('Imported'))
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
      expect(TaxonNameRelationship.find_by({subject_taxon_name: genus, object_taxon_name: genus}).type_name).to eq('TaxonNameRelationship::OriginalCombination::OriginalGenus')
    end

    it 'saves DwC-A import metadata as a data attribute' do
    end

  end

  context 'when importing a homonym with a replacement taxon' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/homonym.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:results) { import_dataset.import(5000, 100).concat(import_dataset.import(5000, 100)) }

    it 'should create 4 imported records' do
      expect(results.length).to eq(4)
      expect(results.map { |row| row.status}).to all(eq('Imported'))
    end

    it 'should have three child records' do
      # pass
    end

    it 'should have a homonym relationship' do
      #
    end

    it 'should should have a replacement name relationship' do
      # pass
    end

    it 'should have 3 original combinations' do   # or does the subgenus also count?
      # pass
    end

  end

  context 'when importing a subspecies synonym of a species' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/synonym.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let(:parent_id) {results[0].metadata.dig('imported_objects', 'taxon_name', 'id')}
    let(:valid_id) {results[1].metadata.dig('imported_objects', 'taxon_name', 'id')}
    let(:synonym_parent_id) {results[2].metadata.dig('imported_objects', 'taxon_name', 'id')}
    let(:synonym_id) {results[3].metadata.dig('imported_objects', 'taxon_name', 'id')}

    let!(:results) { import_dataset.import(5000, 100).concat(import_dataset.import(5000, 100)) }

    it 'should create 3 records' do
      expect(results.length).to eq(3)
      expect(results.map { |row| row.status}).to all(eq('Imported'))
    end

    it 'should have a synonym relationship ' do
      relationship = TaxonNameRelationship.find_by(subject_taxon_name_id: synonym_id, object_taxon_name_id: valid_id)

      expect(relationship.type_name).to eq('TaxonNameRelationship::Iczn::Invalidating::Synonym')
    end

    it 'should have four original combinations' do
      # pass
    end

    it 'synonym should be cached invalid' do
      expect(TaxonName.find_by({id: synonym_id}).cached_is_valid).to eq(false)
    end

    it 'synonym should have cached valid taxon id' do
      expect(TaxonName.find_by({id: synonym_id}).cached_valid_taxon_name_id).to eq(valid_id)
    end

    it "synonym's parent should be Apterostigma wasmannii" do

    end

  end
end
