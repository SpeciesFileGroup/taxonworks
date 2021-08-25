require 'rails_helper'

describe 'DatasetRecord::DarwinCore::Taxon', type: :model do

  context 'when importing a parent and child taxon from a text file' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Checklist.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/checklists/parent_child.tsv'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:root) { FactoryBot.create(:root_taxon_name) }
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

    xit 'creates an original genus relationship' do
      genus = TaxonName.find_by(name: 'Calyptites')
      expect(TaxonNameRelationship.find_by({subject_taxon_name: genus, object_taxon_name: genus}).type_name).to eq('TaxonNameRelationship::OriginalCombination::OriginalGenus')
    end

    xit 'saves DwC-A import metadata as a data attribute' do
    end

  end
end
