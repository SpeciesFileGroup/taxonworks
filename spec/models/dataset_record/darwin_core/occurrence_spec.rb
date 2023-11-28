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

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Ponerinae", rank_class: Ranks.lookup(:iczn, :subfamily))
      tribe = Protonym.create!(parent: subfamily, name: "Ponerini", rank_class: Ranks.lookup(:iczn, :tribe))
      genus = Protonym.create!(parent: tribe, name: "Bothroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      species = Protonym.create!(parent: genus, name: "cambouei", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      @imported = @import_dataset.import(5000, 100)

    end

    let!(:results) { @imported }

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

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Ponerinae", rank_class: Ranks.lookup(:iczn, :subfamily))
      tribe = Protonym.create!(parent: subfamily, name: "Ponerini", rank_class: Ranks.lookup(:iczn, :tribe))
      genus = Protonym.create!(parent: tribe, name: "Bothroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      Protonym.create!(parent: genus, name: "cambouei", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      g_pachycondyla = Protonym.create!(parent: tribe, name: "Pachycondyla", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_euponera = Protonym.create!(parent: tribe, name: "Euponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      s_agnivo = Protonym.create!(parent: g_euponera, name: "agnivo", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

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

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Myrmicinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_aphaenogaster = Protonym.create!(parent: subfamily, name: "Aphaenogaster", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_ceratopheidole = Protonym.create!(parent: subfamily, name: "Ceratopheidole", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      s_depressa = Protonym.create!(parent: g_aphaenogaster, name: "depressa", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_perganderi = Protonym.create!(parent: g_aphaenogaster, name: "perganderi", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_pergandei = Protonym.create!(parent: g_aphaenogaster, name: "pergandei", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)


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

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Ectatomminae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_heteroponera = Protonym.create!(parent: subfamily, name: "Heteroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_ectatomma = Protonym.create!(parent: subfamily, name: "Ectatomma", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      s_brounii = Protonym.create!(parent: g_heteroponera, name: "brounii", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_brownii = Protonym.create!(parent: g_heteroponera, name: "brownii", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

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
      @import_dataset = prepare_occurrence_tsv('typeStatus_synonym_misspelling.tsv',
                                               import_settings: { 'restrict_to_existing_nomenclature' => true,
                                                                  'require_type_material_success' => true })

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Dorylinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_liponera = Protonym.create!(parent: subfamily, name: "Liponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_cerapachys = Protonym.create!(parent: subfamily, name: "Cerapachys", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)

      s_mayri = Protonym.create!(parent: g_liponera, name: "mayri", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_brachynoda = Protonym.create!(parent: g_liponera, name: "brachynoda", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(:taxon_name_id =>  s_brachynoda.id)
      s_brachynoda.send(:set_cached)

      s_brachinoda = Protonym.create!(parent: g_liponera, name: "brachinoda", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      # Create original combination relationship for misspelling and correct spelling
      s_mayri.original_genus = g_cerapachys
      s_mayri.original_species = s_mayri

      s_brachynoda.original_genus = g_cerapachys
      s_brachynoda.original_species = s_mayri
      s_brachynoda.original_subspecies = s_brachynoda

      s_brachinoda.original_genus = g_cerapachys
      s_brachinoda.original_species = s_mayri
      s_brachinoda.original_subspecies = s_brachinoda

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
      @import_dataset = prepare_occurrence_tsv('typeStatus_subsequent_combination.tsv', import_settings: { 'restrict_to_existing_nomenclature' => true,
                                                                                                           'require_type_material_success' => true })

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Dorylinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_liponera = Protonym.create!(parent: subfamily, name: "Liponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_cerapachys = Protonym.create!(parent: subfamily, name: "Cerapachys", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)

      s_mayri = Protonym.create!(parent: g_liponera, name: "mayri", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_brachynoda = Protonym.create!(parent: g_liponera, name: "brachynoda", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(:taxon_name_id =>  s_brachynoda.id)
      s_brachynoda.send(:set_cached)

      # Create original combination relationship for misspelling and correct spelling
      s_mayri.original_genus = g_cerapachys
      s_mayri.original_species = s_mayri

      s_brachynoda.original_genus = g_cerapachys
      s_brachynoda.original_species = s_mayri
      s_brachynoda.original_subspecies = s_brachynoda


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

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Ectatomminae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_heteroponera = Protonym.create!(parent: subfamily, name: "Heteroponera", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_ectatomma = Protonym.create!(parent: subfamily, name: "Ectatomma", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_acanthoponera = Protonym.create!(parent: g_ectatomma, name: "Acanthoponera", rank_class: Ranks.lookup(:iczn, :subgenus), also_create_otu: true)
      s_brounii = Protonym.create!(parent: g_heteroponera, name: "brounii", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      s_brounii.original_genus = g_ectatomma
      s_brounii.original_subgenus = g_acanthoponera
      s_brounii.original_species = s_brounii

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


      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Formicinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_camponotus = Protonym.create!(parent: subfamily, name: "Camponotus", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_dendromyrmex = Protonym.create!(parent: g_camponotus, name: "Dendromyrmex", rank_class: Ranks.lookup(:iczn, :subgenus), also_create_otu: true)
      g_karavaievia = Protonym.create!(parent: g_camponotus, name: "Karavaievia", rank_class: Ranks.lookup(:iczn, :subgenus), also_create_otu: true)

      s_nigripes_dumpert = Protonym.create!(parent: g_karavaievia, name: "nigripes", rank_class: Ranks.lookup(:iczn, :species),
                                           verbatim_author: "Dumpert", year_of_publication: 1995, also_create_otu: true)

      s_nidulans = Protonym.create!(parent: g_camponotus, name: "nidulans", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_nigripes_wheeler = Protonym.create!(parent: g_dendromyrmex, name: "nigripes", rank_class: Ranks.lookup(:iczn, :species),
                                           verbatim_author: "Wheeler", year_of_publication: 1916, also_create_otu: true)

      s_nigripes_wheeler.original_genus = g_dendromyrmex
      s_nigripes_wheeler.original_species = s_nidulans
      s_nigripes_wheeler.original_subspecies = s_nigripes_wheeler

      s_nigripes_dumpert.original_genus = g_camponotus
      s_nigripes_dumpert.original_species = s_nigripes_dumpert

      TaxonNameRelationship::Iczn::Invalidating::Usage::Synonym.create!(subject_taxon_name: s_nigripes_wheeler, object_taxon_name: s_nidulans)

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

  context 'when importing an occurrence with a type material that is a resolved homonym' do

    before :all do
      @import_dataset = prepare_occurrence_tsv('type_material_homonym.tsv',
                                               import_settings: { 'restrict_to_existing_nomenclature' => true,
                                                                  'require_type_material_success' => true }
      )

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Formicinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_camponotus = Protonym.create!(parent: subfamily, name: "Camponotus", rank_class: Ranks.lookup(:iczn, :genus))
      g_formica = Protonym.create!(parent: subfamily, name: "Formica", rank_class: Ranks.lookup(:iczn, :genus))
      g_atta = Protonym.create!(parent: family, name: "Atta", rank_class: Ranks.lookup(:iczn, :genus))

      g_tanaemyrmex = Protonym.create!(parent: g_camponotus, name: 'Tanaemyrmex', rank_class: Ranks.lookup(:iczn, :subgenus))

      # Camponotus (Tanaemyrmex) fervens (Smith, 1857) is a homonym replaced by Camponotus (Tanaemyrmex) fervidus Donisthorpe, 1943
      s_fervens_smith = Protonym.create!(parent: g_tanaemyrmex, name: "fervens", rank_class: Ranks.lookup(:iczn, :species),
                                            verbatim_author: "Smith", year_of_publication: 1857, also_create_otu: true)
      s_fervens_smith.original_genus = g_formica
      s_fervens_smith.original_species = s_fervens_smith

      s_fervidus =  Protonym.create!(parent: g_tanaemyrmex, name: "fervidus", rank_class: Ranks.lookup(:iczn, :species),
                                     verbatim_author: "Donisthorpe", year_of_publication: 1943, also_create_otu: true)
      s_fervidus.original_genus = g_camponotus
      s_fervidus.original_subgenus = g_tanaemyrmex
      s_fervidus.original_species = s_fervidus
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym.create!(subject_taxon_name: s_fervens_smith, object_taxon_name: s_fervidus)


      # Atta fervens (Drury, 1782) [originally Formica fervens] is a synonym of Atta cephalotes
      s_fervens_drury = Protonym.create!(parent: g_atta, name: "fervens", rank_class: Ranks.lookup(:iczn, :species),
                                         verbatim_author: "Drury", year_of_publication: 1782, also_create_otu: true)
      s_fervens_drury.original_genus = g_formica
      s_fervens_drury.original_species = s_fervens_drury


      s_cephalotes = Protonym.create!(parent: g_atta, name: "cephalotes", rank_class: Ranks.lookup(:iczn, :species),
                                      verbatim_author: "Linnaeus", year_of_publication: 1758, also_create_otu: true)


      TaxonNameRelationship::Iczn::Invalidating::Usage::Synonym.create!(subject_taxon_name: s_fervens_drury, object_taxon_name: s_cephalotes)

      @imported = @import_dataset.import(5000, 100)
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:results) {@imported}

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should have 1 type material record' do
      expect(TypeMaterial.count).to eq 1
    end
  end

  context 'when importing an occurrence with a type material and no type type provided' do
    # typeStatus is just the name, with no "...type of" preceding it, but the name isn't an exact match for the scientificName
    # This should raise an error

    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/typeStatus_bad_type.tsv'), 'text/plain'),
        description: 'bad type material',
        import_settings: { 'restrict_to_existing_nomenclature' => true,
                           'require_type_material_success' => true }
      ).tap { |i| i.stage }


      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Dolichoderinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_forelius = Protonym.create!(parent: subfamily, name: "Forelius", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)
      g_iridomyrmex = Protonym.create!(parent: subfamily, name: "Iridomyrmex", rank_class: Ranks.lookup(:iczn, :genus), also_create_otu: true)

      s_breviscapus = Protonym.create!(parent: g_forelius, name: "breviscapus", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      s_mccooki = Protonym.create!(parent: g_forelius, name: "mccooki", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)
      # should be obscurata, adjective
      s_obscurata = Protonym.create!(parent: g_forelius, name: "obscuratus", rank_class: Ranks.lookup(:iczn, :species), also_create_otu: true)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_iridomyrmex, object_taxon_name: s_mccooki)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mccooki, object_taxon_name: s_mccooki)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_iridomyrmex, object_taxon_name: s_breviscapus)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_mccooki, object_taxon_name: s_breviscapus)
      TaxonNameRelationship::OriginalCombination::OriginalSubspecies.create!(subject_taxon_name: s_breviscapus, object_taxon_name: s_breviscapus)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_iridomyrmex, object_taxon_name: s_obscurata)
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: s_breviscapus, object_taxon_name: s_obscurata)
      TaxonNameRelationship::OriginalCombination::OriginalSubspecies.create!(subject_taxon_name: s_obscurata, object_taxon_name: s_obscurata)

      TaxonNameRelationship::Iczn::Invalidating::Usage::Synonym.create!(subject_taxon_name: s_obscurata, object_taxon_name: s_breviscapus)


      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }
    let!(:s_breviscapus) { TaxonName.find_by(name: "breviscapus") }

    it "should import the record without failing" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Errored'))
    end

    it "should report the row's error as unprocessable typeStatus information" do
      expect(results.first.metadata["error_data"]["messages"]["typeStatus"].first).to match(/Unprocessable typeStatus information/)
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

  context 'when importing a specimen with missing intermediate ranks that needs an OTU created' do
    before :all do
      DatabaseCleaner.start
      @import_dataset = ImportDataset::DarwinCore::Occurrences.create!(
        source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/create_otu.tsv'), 'text/plain'),
        description: 'create otu',
        import_settings: { 'restrict_to_existing_nomenclature' => false }
      ).tap { |i| i.stage }


      kingdom = Protonym.create(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create(parent: family, name: "Myrmicinae", rank_class: Ranks.lookup(:iczn, :subfamily))
      tribe = Protonym.create(parent: subfamily, name: "Attini", rank_class: Ranks.lookup(:iczn, :tribe))

      g_strumigenys = Protonym.create(parent: tribe, name: "Strumigenys", rank_class: Ranks.lookup(:iczn, :genus),
                                      verbatim_author: "Smith", year_of_publication: 1860, also_create_otu: true)

      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: g_strumigenys, object_taxon_name: g_strumigenys)

      @imported = @import_dataset.import(5000, 100)
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:results) {@imported}
    let(:g_strumigenys) {Protonym.find_by(name: "Strumigenys", verbatim_author: "Smith", year_of_publication: 1860)}

    it 'should import the record' do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should reuse the existing genus protonym' do
      expect(TaxonName.where(name: 'Strumigenys').count).to eq(1)
    end

    it 'should create an otu with the existing genus protonym' do
      expect(Otu.where(name: "Strumigenys sphera_cf1").count).to eq(1)
      expect(Otu.find_by(name: "Strumigenys sphera_cf1").taxon_name).to eq(g_strumigenys)
    end

  end

  context 'when importing an occurrence with a url for institutionCode' do

    before :all do
      @import_dataset = prepare_occurrence_tsv('url_institution_code.tsv', import_settings: { 'restrict_to_existing_nomenclature' => false})

      @repository = Repository.create!(name: 'California Academy of Sciences', acronym: 'CASC',
                                       url: 'http://grbio.org/institution/california-academy-sciences')

      @imported = @import_dataset.import(5000, 100)
    end

    let!(:results) { @imported }
    let!(:repository) { @repository }

    it 'should import the record without failing' do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'the record should have the correct repository' do
      expect(CollectionObject.first.repository).to eq repository
    end

    after :all do
      DatabaseCleaner.clean
    end
  end

  context 'when importing an occurrence with duplicate acronym institutionCode' do
    before :all do
      @import_dataset = prepare_occurrence_tsv('acronym_institution_code.tsv', import_settings: { 'restrict_to_existing_nomenclature' => false,
                                                                                                  'containerize_dup_cat_no' => false})

      @repository = Repository.create!(name: 'Museum of Comparative Zoology, Harvard University, Cambridge, Massachusetts', acronym: 'MCZ')
      @imported = @import_dataset.import(5000, 100)
    end
    after :all do
      DatabaseCleaner.clean
    end

    let(:imported) {@imported}

    it 'should import fine when one institution has the specified acronym' do
      expect(imported.length).to eq(1)
      expect(imported.map { |row| row.status }).to all(eq('Imported'))
    end

    it 'should match the correct institution' do
      expect(CollectionObject.first.repository).to eq @repository
    end
  end


  context 'when importing an occurrence with duplicate acronym institutionCode' do
    before :all do
      @import_dataset = prepare_occurrence_tsv('acronym_institution_code.tsv',
                                               import_settings: { 'restrict_to_existing_nomenclature' => false,
                                                                  'containerize_dup_cat_no' => false })

      Repository.create!(name: 'Museum of Comparative Zoology, Harvard University, Cambridge, Massachusetts', acronym: 'MCZ')
      Repository.create!(name: 'Museum of Comparative Zoology', acronym: 'MCZ',
                         url: 'http://grbio.org/institution/museum-comparative-zoology')

      @imported = @import_dataset.import(5000, 100)
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:imported) {@imported}

    it 'should error when multiple institutions have the same acronym' do
      expect(imported.length).to eq(1)
      expect(imported.map { |row| row.status }).to all(eq('Errored'))
    end

    it 'should report that there were multiple matching acronyms' do
      error_messages = imported.first.metadata['error_data']['messages']['institutionCode']
      expect(error_messages.first).to match(/Could not disambiguate repository name 'MCZ'/)
      expect(error_messages.second).to match(/Multiple repositories with acronym MCZ found/)
      expect(error_messages.third).to match(/No repositories match the name MCZ/)
    end
  end

  context "when importing an occurrence with a type material, but typeStatus taxon doesn't exist" do
    before :all do
      @import_dataset = prepare_occurrence_tsv('type_material_homonym.tsv',
                                               import_settings: { 'restrict_to_existing_nomenclature' => true,
                                                                  'require_type_material_success' => true })

      kingdom = Protonym.create!(parent: @root, name: "Animalia", rank_class: Ranks.lookup(:iczn, :kingdom))
      phylum = Protonym.create!(parent: kingdom, name: "Arthropoda", rank_class: Ranks.lookup(:iczn, :phylum))
      klass = Protonym.create!(parent: phylum, name: "Insecta", rank_class: Ranks.lookup(:iczn, :class))
      order = Protonym.create!(parent: klass, name: "Hymenoptera", rank_class: Ranks.lookup(:iczn, :order))
      family = Protonym.create!(parent: order, name: "Formicidae", rank_class: Ranks.lookup(:iczn, :family))
      subfamily = Protonym.create!(parent: family, name: "Formicinae", rank_class: Ranks.lookup(:iczn, :subfamily))

      g_camponotus = Protonym.create!(parent: subfamily, name: "Camponotus", rank_class: Ranks.lookup(:iczn, :genus))
      g_formica = Protonym.create!(parent: subfamily, name: "Formica", rank_class: Ranks.lookup(:iczn, :genus))
      g_atta = Protonym.create!(parent: family, name: "Atta", rank_class: Ranks.lookup(:iczn, :genus))

      g_tanaemyrmex = Protonym.create!(parent: g_camponotus, name: 'Tanaemyrmex', rank_class: Ranks.lookup(:iczn, :subgenus))

      s_fervidus =  Protonym.create!(parent: g_tanaemyrmex, name: "fervidus", rank_class: Ranks.lookup(:iczn, :species),
                                     verbatim_author: "Donisthorpe", year_of_publication: 1943, also_create_otu: true)

      s_fervidus.original_genus = g_camponotus
      s_fervidus.original_subgenus = g_tanaemyrmex
      s_fervidus.original_species = s_fervidus


      @imported = @import_dataset.import(5000, 100)
    end

    after :all do
      DatabaseCleaner.clean
    end

    let(:results) {@imported}

    it "the record should error" do
      expect(results.length).to eq(1)
      expect(results.map { |row| row.status }).to all(eq('Errored'))
    end

    it 'should report that no names were retured in the wildcard search' do
      error_messages = results.first.metadata['error_data']['messages']['typeStatus']
      expect(error_messages.first).to match(/Could not identify or disambiguate name Formica fervens/)
      expect(error_messages.second).to match(/Could not find exact original combination match for typeStatus/)
      expect(error_messages.third).to match(/No names returned in subgenus wildcard search/)

    end
  end

end

# Set up DatabaseCleaner, stage tsv file for import
# @param [String] file_name
# @param [String, nil] description
# @param [Hash] import_settings
def prepare_occurrence_tsv(file_name, description = nil, import_settings: {})
  DatabaseCleaner.start
  ImportDataset::DarwinCore::Occurrences.create!(
    source: fixture_file_upload((Rails.root + 'spec/files/import_datasets/occurrences/' + file_name), 'text/plain'),
    description: description || file_name, # use file name as description if not given
    import_settings: import_settings
  ).tap { |i| i.stage }

end
