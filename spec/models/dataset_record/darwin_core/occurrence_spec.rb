require 'rails_helper'

describe 'DatasetRecord::DarwinCore::Occurrence', type: :model do

  context 'when importing a single occurrence in a text file' do
    let(:import_dataset) {
      ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/dwca_occurrences.txt'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    }

    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:results) { import_dataset.import(5000, 100) }

    it 'creates a new record' do
      expect(results.length).to eq(1)
      expect(results.first.status).to eq('Imported')
    end

    xit 'creates a collection object' do
    end

    it 'creates a genus protonym' do
      expect(TaxonName.find_by(name: 'Orotettix')).to be_an_is_protonym
    end
    it 'creates a species protonym' do
      expect(TaxonName.find_by(name: 'andeanus')).to be_an_is_protonym
    end

    it 'creates a taxon name combination' do
      expect(TaxonName.find_by(cached: 'Orotettix andeanus').parent).to eq(TaxonName.find_by(name: 'Orotettix'))
    end

    it 'creates an occurrenceID value' do
      Identifier::Local::Import::Dwc.find_by_identifier('0d66a0ee-7594-597b-9aa1-ac763591548b')
    end

    xit "creates a 'namespaced' identifier" do
    end

    xit 'creates a taxonDetermination' do
    end

  end
end
