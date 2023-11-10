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
        import_settings: { 'restrict_to_existing_nomenclature' => true}
      ).tap { |i| i.stage }

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

  context 'when import an occurrence with a type material' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/type_material.tsv'), 'text/plain'),
        description: 'Type Material',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }

      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Ponerinae", rank_class: Ranks.lookup(:iczn, :subfamily))
      tribe = Protonym.create(parent: subfamily, name: "Ponerini", rank_class: Ranks.lookup(:iczn, :tribe))
      genus = Protonym.create(parent: tribe, name: "Bothroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      Protonym.create(parent: genus, name: "cambouei", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      g_pachycondyla = Protonym.create(parent: tribe, name: "Pachycondyla", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_euponera = Protonym.create(parent: tribe, name: "Euponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      s_agnivo = Protonym.create(parent: g_euponera, name: "agnivo", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      # Create original combination relationship
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_pachycondyla, object_taxon_name: s_agnivo)

      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }

    it "should import both records without failing" do
      expect(results.length).to eq(2)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'does not create any new protonyms' do
      expect(TaxonName.where(name: 'Bothroponera').count).to eq(1)
      expect(TaxonName.where(name: 'Euponera').count).to eq(1)
      expect(TaxonName.where(name: 'agnivo').count).to eq(1)
      expect(TaxonName.where(name: 'cambouei').count).to eq(1)
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 2
    end

    after :all do
      DatabaseCleaner.clean
    end


  end

  context 'when import an occurrence with a type material matching a synonym of the current taxon name' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_original_misspelling.tsv'), 'text/plain'),
        description: 'Type Material Synonym',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }

      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Myrmicinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_aphaenogaster = Protonym.create(parent: subfamily, name: "Aphaenogaster", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_ceratopheidole = Protonym.create(parent: subfamily, name: "Ceratopheidole", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      s_depressa = Protonym.create(parent: g_aphaenogaster, name: "depressa", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_perganderi = Protonym.create(parent: g_aphaenogaster, name: "perganderi", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_pergandei = Protonym.create(parent: g_aphaenogaster, name: "pergandei", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)


      # Create original combination relationship for misspelling and correct spelling
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_ceratopheidole, object_taxon_name: s_perganderi)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_perganderi, object_taxon_name: s_perganderi)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_ceratopheidole, object_taxon_name: s_pergandei)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_pergandei, object_taxon_name: s_pergandei)

      # Create misspelling relationship with correct spelling
      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling.create!(subject_taxon_name: s_perganderi, object_taxon_name: s_pergandei)

      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }
    let!(:s_pergandei) { TaxonName.find_by_name("pergandei") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end

    it 'should have the correct spelling in the type material' do
      expect(TypeMaterial.first.protonym).to eq s_pergandei
    end

    after :all do
      DatabaseCleaner.clean
    end
  end


  context 'when importing an occurrence with a type material matching a misspelling of an obsolete combination of the current taxon name' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_combination_misspelling.tsv'), 'text/plain'),
        description: 'Type Material Obsolete Combination Misspelling',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }

      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Ectatomminae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_heteroponera = Protonym.create(parent: subfamily, name: "Heteroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_ectatomma = Protonym.create(parent: subfamily, name: "Ectatomma", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      s_brounii = Protonym.create(parent: g_heteroponera, name: "brounii", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_brownii = Protonym.create(parent: g_heteroponera, name: "brownii", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      # Create original combination relationship for misspelling and correct spelling
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_ectatomma, object_taxon_name: s_brownii)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_brownii, object_taxon_name: s_brownii)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_ectatomma, object_taxon_name: s_brounii)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_brounii, object_taxon_name: s_brounii)

      # Create misspelling relationship with correct spelling
      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling.create!(subject_taxon_name: s_brownii, object_taxon_name: s_brounii)

      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }
    let!(:s_brounii) { TaxonName.find_by_name("brounii") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end

    it 'should have the correct spelling in the type material' do
      expect(TypeMaterial.first.protonym).to eq s_brounii
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

  context 'when importing an occurrence with a type material matching a misspelling of a synonym of the current taxon name' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_synonym_misspelling.tsv'), 'text/plain'),
        description: 'Type Material Synonym Misspelling',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }

      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Dorylinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_liponera = Protonym.create(parent: subfamily, name: "Liponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_cerapachys = Protonym.create(parent: subfamily, name: "Cerapachys", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)

      s_mayri = Protonym.create(parent: g_liponera, name: "mayri", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_brachynoda = Protonym.create(parent: g_liponera, name: "brachynoda", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(:taxon_name_id =>  s_brachynoda.id)
      s_brachynoda.send(:set_cached)

      s_brachinoda = Protonym.create(parent: g_liponera, name: "brachinoda", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      # Create original combination relationship for misspelling and correct spelling
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_cerapachys, object_taxon_name: s_mayri)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mayri, object_taxon_name: s_mayri)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_cerapachys, object_taxon_name: s_brachynoda)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mayri, object_taxon_name: s_brachynoda)
      TaxonNameRelationship::OriginalCombination::OriginalSubspecies.create!(subject_taxon_name: s_brachynoda, object_taxon_name: s_brachynoda)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_cerapachys, object_taxon_name: s_brachinoda)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mayri, object_taxon_name: s_brachinoda)
      TaxonNameRelationship::OriginalCombination::OriginalSubspecies.create!(subject_taxon_name: s_brachinoda, object_taxon_name: s_brachinoda)

      # Create misspelling relationship with correct spelling
      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling.create!(subject_taxon_name: s_brachinoda, object_taxon_name: s_brachynoda)

      # Add synonym relationship
      TaxonNameRelationship::Iczn::Invalidating::Usage::Synonym.create!(subject_taxon_name: s_brachynoda, object_taxon_name: s_mayri)

      @imported = @import_dataset.import(5000, 100)

    end

    let!(:results) { @imported }
    let!(:s_brachynoda) { TaxonName.find_by_name("brachynoda") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end

    it 'should have the correct spelling in the type material' do
      expect(TypeMaterial.first.protonym).to eq s_brachynoda
    end

    after :all do
      DatabaseCleaner.clean
    end
  end


  context 'when importing an occurrence with a type material matching a subsequent combination of the current taxon name' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_subsequent_combination.tsv'), 'text/plain'),
        description: 'Type Material Subsequent Combination',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }

      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Dorylinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_liponera = Protonym.create(parent: subfamily, name: "Liponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_cerapachys = Protonym.create(parent: subfamily, name: "Cerapachys", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)

      s_mayri = Protonym.create(parent: g_liponera, name: "mayri", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_brachynoda = Protonym.create(parent: g_liponera, name: "brachynoda", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(:taxon_name_id =>  s_brachynoda.id)
      s_brachynoda.send(:set_cached)

      # Create original combination relationship for misspelling and correct spelling
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_cerapachys, object_taxon_name: s_mayri)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mayri, object_taxon_name: s_mayri)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_cerapachys, object_taxon_name: s_brachynoda)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mayri, object_taxon_name: s_brachynoda)
      TaxonNameRelationship::OriginalCombination::OriginalSubspecies.create!(subject_taxon_name: s_brachynoda, object_taxon_name: s_brachynoda)


      # Add synonym relationship
      TaxonNameRelationship::Iczn::Invalidating::Usage::Synonym.create!(subject_taxon_name: s_brachynoda, object_taxon_name: s_mayri)

      # Add subsequent combination
      Combination.create(genus: g_liponera, species: s_mayri, subspecies: s_brachynoda)

      @imported = @import_dataset.import(5000, 100)

    end

    let!(:results) { @imported }
    let!(:s_brachynoda) { TaxonName.find_by_name("brachynoda") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end

    it 'should have the correct spelling in the type material' do
      expect(TypeMaterial.first.protonym).to eq s_brachynoda
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

  context 'when importing an occurrence with a type material without subgenus' do
    # This test is for when the original combination has a subgenus, but none is provided in the typeStatus field

    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_wildcard_subgenus.tsv'), 'text/plain'),
        description: 'Type Material Wildcard Subgenus',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }

      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Ectatomminae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_heteroponera = Protonym.create(parent: subfamily, name: "Heteroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_ectatomma = Protonym.create(parent: subfamily, name: "Ectatomma", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_acanthoponera = Protonym.create(parent: g_ectatomma, name: "Acanthoponera", rank_class: Ranks.lookup(:iczn, :subgenus), also_create_otu: true)
      s_brounii = Protonym.create(parent: g_heteroponera, name: "brounii", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_ectatomma, object_taxon_name: s_brounii)
      TaxonNameRelationship::OriginalCombination::OriginalSubgenus.create!(subject_taxon_name: g_acanthoponera, object_taxon_name: s_brounii)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_brounii, object_taxon_name: s_brounii)

      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }
    let!(:s_brounii) { TaxonName.find_by_name("brounii") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end

    it 'should have the correct spelling in the type material' do
      expect(TypeMaterial.first.protonym).to eq s_brounii
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

  context 'when importing an occurrence with a type material that is an unresolved homonym' do
    # When the name is an unresolved homonym, but scientificNameAuthorship can differentiate the homonyms
    # and the typeStatus is an exact match for scientificName, it should be possible to create the typeMaterial

    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_unresolved_homonym.tsv'), 'text/plain'),
        description: 'Type Material Homonym',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }


      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Formicinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_camponotus = Protonym.create(parent: subfamily, name: "Camponotus", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_dendromyrmex = Protonym.create(parent: g_camponotus, name: "Dendromyrmex", rank_class: Ranks.lookup(:iczn, :subgenus), also_create_otu: true)
      g_karavaievia = Protonym.create(parent: g_camponotus, name: "Karavaievia", rank_class: Ranks.lookup(:iczn, :subgenus), also_create_otu: true)

      s_nigripes_dumpert = Protonym.create(parent: g_karavaievia, name: "nigripes", rank_class: Ranks.lookup(:iczn, :species),
                                           verbatim_author: "Dumpert", year_of_publication: 1995, also_create_otu: true)

      s_nidulans = Protonym.create(parent: g_camponotus, name: "nidulans", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_nigripes_wheeler = Protonym.create(parent: g_dendromyrmex, name: "nigripes", rank_class: Ranks.lookup(:iczn, :species),
                                           verbatim_author: "Wheeler", year_of_publication: 1916, also_create_otu: true)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_dendromyrmex, object_taxon_name: s_nigripes_wheeler)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_nidulans, object_taxon_name: s_nigripes_wheeler)
      TaxonNameRelationship::OriginalCombination::OriginalSubspecies.create!(subject_taxon_name: s_nigripes_wheeler, object_taxon_name: s_nigripes_wheeler)

      TaxonNameRelationship::Iczn::Invalidating::Usage::Synonym.create!(subject_taxon_name: s_nigripes_wheeler, object_taxon_name: s_nidulans)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_camponotus, object_taxon_name: s_nigripes_dumpert)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_nigripes_dumpert, object_taxon_name: s_nigripes_dumpert)

      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }
    let!(:s_nigripes_wheeler) { TaxonName.find_by(name: "nigripes", cached_author_year: "(Wheeler, 1916)") }
    let!(:s_nigripes_dumpert) { TaxonName.find_by(name: "nigripes", cached_author_year: "Dumpert, 1995") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end

    it 'should have the correct spelling in the type material' do
      expect(TypeMaterial.first.protonym).to eq s_nigripes_dumpert
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

end
