require 'rails_helper'

describe Queries::TaxonName::Tabular, type: :model, group: [:nomenclature] do
  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:genus) { Protonym.create!(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
  let!(:genus1) { Protonym.create!(name: 'Erasmoneuraa', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }

  let!(:tr1) { TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(
    subject_taxon_name: genus1,
    object_taxon_name: genus)}

  let!(:species1) { Protonym.create!(name: 'alpha', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
  let!(:species2) { Protonym.create!(name: 'beta', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
  let!(:species3) { Protonym.create!(name: 'gamma', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }

  let!(:tr2) {TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
    subject_taxon_name: species3,
    object_taxon_name: species2)}

  let!(:combination) { Combination.create!(genus: genus1, species: species2)}
  let!(:otu1) {Otu.create!(name: 'otu1', taxon_name: species1)}
  let!(:otu2) {Otu.create!(name: 'otu2', taxon_name: species1)}
  let!(:otu3) {Otu.create!(taxon_name: species2)}
  let(:observation_matrix) { ObservationMatrix.create!(name: 'Matrix') }
  let(:descriptor1) { Descriptor::Continuous.create!(name: 'descriptor1') }
  let(:descriptor2) { Descriptor::Media.create!(name: 'descriptor2') }

  let(:query) { Queries::TaxonName::Tabular.new }

  # TODO: these tests are not quite right, what we return is not what we
  # display.  Reconcile this in the view, not result here.
  context 'column headers (shared)' do
    before do
      query.ancestor_id = genus.id.to_s
      query.ranks = ['genus', 'species']
      query.rank_data =  ['genus', 'species']
      query.fieldsets = ['nomenclatural_stats']
      query.validity = false
      query.combinations = true
      query.project_id = genus.project_id.to_s

      query.build_query
    end

    specify 'valid_tribe' do
      expect(query.column_headers.include? 'valid_tribe').to be_falsey
    end

    specify 'valid_genus' do
      expect(query.column_headers.include? 'valid_genus').to be_truthy
    end

    specify 'invalid_genus' do
      expect(query.column_headers.include? 'invalid_genus').to be_truthy
    end

    specify 'valid_species' do
      expect(query.column_headers.include? 'valid_species').to be_truthy
    end

    specify 'invalid_species' do
      expect(query.column_headers.include? 'invalid_species').to be_truthy
    end

    # do not break combinations into valid and invalid, make a single column
    specify 'combination' do
      expect(query.column_headers.include? 'combination').to be_truthy
    end

    specify 'valid_combination' do
      expect(query.column_headers.include? 'valid_combination').to be_falsey
    end

    specify 'invalid_combination' do
      expect(query.column_headers.include? 'invalid_combination').to be_falsey
    end

    # otus should be excluded from nomenclature stats, but included in observations
    specify 'otu_id' do
      expect(query.column_headers.include? 'otu_id').to be_falsey
    end

    specify 'otu_name' do
      expect(query.column_headers.include? 'otu_name').to be_falsey
    end

    specify 'observation_count' do
      expect(query.column_headers.include? 'observation_count').to be_falsey
    end

    specify 'observation_depictions' do
      expect(query.column_headers.include? 'observation_depictions').to be_falsey
    end

    specify 'descriptors_scored' do
      expect(query.column_headers.include? 'descriptors_scored').to be_falsey
    end
  end

  context 'column headers: observations' do

    before do
      query.ancestor_id = genus.id.to_s
      query.ranks = ['genus', 'species']
      query.fieldsets = ['observations']
      query.validity = false
      query.combinations = true
      query.project_id = genus.project_id.to_s

      query.build_query
    end

    # Make sure we are not forking valid/invalid logic to this report
    specify 'valid_genus' do
      expect(query.column_headers.include? 'valid_tribe').to be_falsey
    end

    # Not present in observations
    specify 'combination' do
      expect(query.column_headers.include? 'combination').to be_falsey
    end

    specify 'genus' do
      expect(query.column_headers.include? 'genus').to be_truthy
    end

    specify 'species' do
      expect(query.column_headers.include? 'species').to be_truthy
    end

    specify 'otu_id' do
      expect(query.column_headers.include? 'otu_id').to be_truthy
    end

    specify 'otu_name' do
      expect(query.column_headers.include? 'otu_name').to be_truthy
    end

    specify 'otu_observation_count' do
      expect(query.column_headers.include? 'otu_observation_count').to be_truthy
    end

    specify 'otu_observation_depictions' do
      expect(query.column_headers.include? 'otu_observation_depictions').to be_truthy
    end

    specify 'descriptors_scored_for_otus' do
      expect(query.column_headers.include? 'descriptors_scored_for_otus').to be_truthy
    end
  end

  context 'number of species: nomenclature stats' do
    before do
      query.ancestor_id = genus.id.to_s
      query.ranks = ['genus', 'species']
      query.rank_data =  ['genus', 'species']
      query.fieldsets = ['nomenclatural_stats']
      query.validity = false
      query.combinations = true
      query.project_id = genus.project_id.to_s

      query.build_query
    end

    specify 'all' do
      # 3 is correct, OTUs should not increase the number of taxa
      #
      # Genus + 3 species, 2 valid, 1 not, is 4, not 3 (and also not 5)
      expect(query.all.count).to eq(4)
    end

    specify 'cached' do
      expect(query.all[0]['cached']).to eq('Erasmoneura')
    end

    #number of synonyms for the genus is not displayed
    specify 'valid_genus' do
      expect(query.all[0]['valid_genus']).to eq(1)
    end

    specify 'invalid_genus' do
      expect(query.all[0]['invalid_genus']).to eq(1)
    end

    specify 'valid_species' do
      expect(query.all[0]['valid_species']).to eq(2)
    end

    specify 'invalid_species' do
      expect(query.all[0]['invalid_species']).to eq(1)
    end

    specify 'combination' do
      expect(query.all[0]['combination']).to eq(1)
    end

    specify 'cached #2' do
      expect(query.all[1]['cached']).to eq('Erasmoneura alpha')
    end

    specify 'valid_genus #2' do
      expect(query.all[1]['valid_genus'].nil?).to be_truthy
    end

    specify 'invalid_genus #2' do
      expect(query.all[1]['invalid_genus'].nil?).to be_truthy
    end

    specify 'valid_species #2' do
      expect(query.all[1]['valid_species']).to eq(1)
    end

    specify 'invalid_species #2' do
      expect(query.all[1]['invalid_species'].nil?).to be_truthy
    end

    specify 'combination #2' do
      expect(query.all[1]['combination'].nil?).to be_truthy
    end

    specify 'cached #3' do
      expect(query.all[2]['cached']).to eq('Erasmoneura beta')
    end

    specify 'valid_genus #3' do
      expect(query.all[2]['valid_genus'].nil?).to be_truthy
    end

    specify 'invalid_genus #3' do
      expect(query.all[2]['invalid_genus'].nil?).to be_truthy
    end

    #synonyms and combinations for each species are not displayed
    specify 'valid_species #3' do
      expect(query.all[2]['valid_species']).to eq(1)
    end
    specify 'invalid_species #3' do
      expect(query.all[2]['invalid_species']).to eq(1)
    end
    specify 'combination #3' do
      expect(query.all[2]['combination']).to eq(1)
    end
  end

  context 'number of species: nomenclature stats: unavailable' do
    before do
      # all TN with the TaxonNameClassification in the array: TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID
      # should be excluded from counting of valid names.
      tc = TaxonNameClassification::Iczn::Unavailable::NomenNudum.create!( taxon_name: species1 )
      query.ancestor_id = genus.id.to_s
      query.ranks = ['genus', 'species']
      query.rank_data =  ['genus', 'species']
      query.fieldsets = ['nomenclatural_stats']
      query.validity = false
      query.combinations = true
      query.project_id = genus.project_id.to_s

      query.build_query
    end

    #otus should not be included in the list
    specify 'all' do
      # Genus plus 3 species
      expect(query.all.count).to eq(4)
    end

    specify 'cached' do
      expect(query.all[0]['cached']).to eq('Erasmoneura')
    end
    specify 'valid_genus' do
      expect(query.all[0]['valid_genus']).to eq(1)
    end
    specify 'invalid_genus' do
      expect(query.all[0]['invalid_genus']).to eq(1)
    end
    specify 'valid_species' do
      expect(query.all[0]['valid_species']).to eq(1)
    end
    specify 'invalid_species' do
      expect(query.all[0]['invalid_species']).to eq(2) # eq(1) is also OK
    end
    specify 'combination' do
      expect(query.all[0]['combination']).to eq(1)
    end
  end

  context 'observation stats' do
    before do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)

      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single.new(observation_object: otu1)

      observation_matrix.save!
      o1 = Observation.create!(observation_object: otu1, descriptor: descriptor1, continuous_value: 5)
      o2 = Observation.create!(observation_object: otu1, descriptor: descriptor2)

      FactoryBot.create(:valid_depiction, depiction_object: o2)
      FactoryBot.create(:valid_depiction, depiction_object: o2)


      query.ancestor_id = genus.id.to_s
      query.ranks = ['genus', 'species']
      query.rank_data =  ['genus', 'species']
      query.fieldsets = ['observations']
      query.validity = true
      query.combinations = true
      query.project_id = genus.project_id.to_s

      query.build_query
    end

    specify '#all' do
      # 4 is correct, because each OTU is listed as a separate line
      expect(query.all.count).to eq(4)
    end

    specify 'cached' do
      expect(query.all[1]['cached']).to eq('Erasmoneura alpha')
    end

    specify 'otu_name' do
      expect(query.all[1]['otu_name']).to eq('otu1')
    end

    specify 'otu_observation_count' do
      expect(query.all[1]['otu_observation_count']).to eq(2)
    end

    specify 'otu_observation_depictions' do
      expect(query.all[1]['otu_observation_depictions']).to eq(2)
    end

    specify 'descriptors_scored_for_otus' do
      expect(query.all[1]['descriptors_scored_for_otus']).to eq(2) # descriptor 1 and 2 for otu1
    end
  end

end
