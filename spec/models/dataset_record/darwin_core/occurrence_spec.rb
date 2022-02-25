require 'rails_helper'

describe 'DatasetRecord::DarwinCore::Occurrence', type: :model do
  before :all do
    DatabaseCleaner.start
    @root = FactoryBot.create(:root_taxon_name)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  context 'when importing a single occurrence in a text file' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/dwca_occurrences.txt'), 'text/plain'),
        description: 'Testing'
      ).tap { |i| i.stage }
    end

    after :all do
      DatabaseCleaner.clean
    end

    let!(:results) { @import_dataset.import(5000, 100) }

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

  context 'when importing an occurrence that is missing an intermediate protonym' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/intermediate_protonym.tsv'), 'text/plain'),
        description: 'Missing Ancestor Protonym',
        metadata: {'import_settings' => {'restrict_to_existing_nomenclature' => true}}
      ).tap { |i| i.stage }
      @import_dataset.metadata['import_settings']['restrict_to_existing_nomenclature'] = true
      @import_dataset.save!


      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Ponerinae", rank_class: Ranks.lookup(:iczn, :subfamily))
      tribe = Protonym.create(parent: subfamily, name: "Ponerini", rank_class: Ranks.lookup(:iczn, :tribe))
      genus = Protonym.create(parent: tribe, name: "Bothroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      species = Protonym.create(parent: genus, name: "cambouei", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

    end


    let!(:results) { @import_dataset.import(5000, 100) }


    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.first.status).to eq('Imported')
    end

    it 'does not create any new protonyms' do
      expect(TaxonName.where(name: 'Bothroponera').count).to eq(1)
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

end
