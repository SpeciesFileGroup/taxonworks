require 'rails_helper'

describe Queries::TaxonName::Tabular, type: :model, group: [:nomenclature] do
  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:genus) { Protonym.create!(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
  let!(:genus1) { Protonym.create!(name: 'Erasmoneuraa', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
  let!(:tr1) {TaxonNameRelationship.create!(subject_taxon_name: genus1, object_taxon_name: genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling')}
  let!(:species1) { Protonym.create!(name: 'alpha', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
  let!(:species2) { Protonym.create!(name: 'beta', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
  let!(:species3) { Protonym.create!(name: 'gamma', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
  let!(:tr2) {TaxonNameRelationship.create!(subject_taxon_name: species3, object_taxon_name: species2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')}
  let!(:combination) { Combination.create!(genus: genus1, species: species2)}
  let!(:otu1) {Otu.create!(name: 'otu1', taxon_name: species1)}
  let!(:otu2) {Otu.create!(name: 'otu2', taxon_name: species1)}
  let!(:otu3) {Otu.create!(taxon_name: species2)}
  let(:observation_matrix) { ObservationMatrix.create!(name: 'Matrix') }
  let(:descriptor1) { Descriptor::Continuous.create!(name: 'descriptor1') }
  let(:descriptor2) { Descriptor::Media.create!(name: 'descriptor2') }
  let(:image_file) { fixture_file_upload( Spec::Support::Utilities::Files.generate_png, 'image/png') }

  let(:query) { Queries::TaxonName::Tabular.new }

  xspecify '#column_headers: nomenclatural_stats' do
    query.ancestor_id = genus.id.to_s
    query.ranks = ['genus', 'species']
    query.rank_data =  ['genus', 'species']
    query.fieldsets = ['nomenclatural_stats']
    query.validity = false
    query.combinations = true
    query.project_id = genus.project_id.to_s

    query.build_query
    expect(query.column_headers.include? 'valid_tribe').to be_falsey
    expect(query.column_headers.include? 'valid_genus').to be_truthy
    expect(query.column_headers.include? 'invalid_genus').to be_truthy
    expect(query.column_headers.include? 'valid_species').to be_truthy
    expect(query.column_headers.include? 'invalid_species').to be_truthy
    # do not breack combinations into valid and invalid, make a single column
    expect(query.column_headers.include? 'combination').to be_trythy
    expect(query.column_headers.include? 'valid_combination').to be_falsey
    expect(query.column_headers.include? 'invalid_combination').to be_falsey
    #otus should be excluded from nomenclature stats, but included in observations
    expect(query.column_headers.include? 'otu_id').to be_falsey
    expect(query.column_headers.include? 'otu').to be_falsey
    expect(query.column_headers.include? 'observation_count').to be_falsey
    expect(query.column_headers.include? 'observation_depictions').to be_falsey
    expect(query.column_headers.include? 'descriptors_scored').to be_falsey
  end

  xspecify '#column_headers: observations' do
    query.ancestor_id = genus.id.to_s
    query.ranks = ['genus', 'species']
    query.rank_data =  ['genus', 'species']
    query.fieldsets = ['observations']
    query.validity = false
    query.combinations = true
    query.project_id = genus.project_id.to_s

    query.build_query
    expect(query.column_headers.include? 'valid_tribe').to be_falsey
    expect(query.column_headers.include? 'valid_genus').to be_truthy
    expect(query.column_headers.include? 'invalid_genus').to be_truthy
    expect(query.column_headers.include? 'valid_species').to be_truthy
    expect(query.column_headers.include? 'invalid_species').to be_truthy
    expect(query.column_headers.include? 'combination').to be_falsey
    expect(query.column_headers.include? 'valid_combination').to be_falsey
    expect(query.column_headers.include? 'invalid_combination').to be_falsey
    expect(query.column_headers.include? 'otu_id').to be_truthy
    expect(query.column_headers.include? 'otu').to be_truthy
    expect(query.column_headers.include? 'observation_count').to be_truthy
    expect(query.column_headers.include? 'observation_depictions').to be_truthy
    expect(query.column_headers.include? 'descriptors_scored').to be_truthy
  end

  xspecify '#number_of_species: nomenclature stats' do
    query.ancestor_id = genus.id.to_s
    query.ranks = ['genus', 'species']
    query.rank_data =  ['genus', 'species']
    query.fieldsets = ['nomenclatural_stats']
    query.validity = false
    query.combinations = true
    query.project_id = genus.project_id.to_s

    query.build_query
    # 3 is correct, OTUs should not increase the number of taxa
    expect(query.all.count).to eq(3)

    expect(query.all[0]['cached']).to eq('Erasmoneura')
    #number of synonyms for the genus is not displayed
    expect(query.all[0]['valid_genus']).to eq(1)
    expect(query.all[0]['invalid_genus']).to eq(1)
    expect(query.all[0]['valid_species']).to eq(2)
    expect(query.all[0]['invalid_species']).to eq(1)
    expect(query.all[0]['combination']).to eq(1)

    expect(query.all[1]['cached']).to eq('Erasmoneura alpha')
    expect(query.all[1]['valid_genus'].nil?).to be_truthy
    expect(query.all[1]['invalid_genus'].nil?).to be_truthy
    expect(query.all[1]['valid_species']).to eq(1)
    expect(query.all[1]['invalid_species'].nil?).to be_truthy
    expect(query.all[1]['combination'].nil?).to be_truthy

    expect(query.all[2]['cached']).to eq('Erasmoneura beta')
    expect(query.all[2]['valid_genus'].nil?).to be_truthy
    expect(query.all[2]['invalid_genus'].nil?).to be_truthy
    #synonyms and combinations for each species are not displayed
    expect(query.all[2]['valid_species']).to eq(1)
    expect(query.all[2]['invalid_species']).to eq(1)
    expect(query.all[2]['combination']).to eq(1)
  end

  xspecify '#number_of_species: nomenclature stats: unavailable' do
    # all TN with the TaxonNameClassification in the array: TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID
    # should be excluded from counting of valid names.
    tc = TaxonNameClassification.create!(taxon_name: species1, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
    query.ancestor_id = genus.id.to_s
    query.ranks = ['genus', 'species']
    query.rank_data =  ['genus', 'species']
    query.fieldsets = ['nomenclatural_stats']
    query.validity = false
    query.combinations = true
    query.project_id = genus.project_id.to_s

    query.build_query
    #otus should not be inluded in the list
    expect(query.all.count).to eq(3)

    expect(query.all[0]['cached']).to eq('Erasmoneura')
    expect(query.all[0]['valid_genus']).to eq(1)
    expect(query.all[0]['invalid_genus']).to eq(1)
    expect(query.all[0]['valid_species']).to eq(1)
    expect(query.all[0]['invalid_species']).to eq(2) # eq(1) is also OK
    expect(query.all[0]['combination']).to eq(1)
  end

  xspecify '#number_of_species: observations' do
    observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
    observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)
    observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleOtu.new(otu: otu1)
    o1 = Observation.create!(otu: otu1, descriptor: descriptor1, continuous_value: 5)
    o2 = Observation.create!(otu: otu1, descriptor: descriptor2)
    d = Depiction.create!(depiction_object: o2, image_attributes: {image_file: image_file})

    query.ancestor_id = genus.id.to_s
    query.ranks = ['genus', 'species']
    query.rank_data =  ['genus', 'species']
    query.fieldsets = ['observations']
    query.validity = true
    query.combinations = true
    query.project_id = genus.project_id.to_s

    query.build_query
    # 4 is correct, because each OTU is listed as a separate line
    expect(query.all.count).to eq(4)

    expect(query.all[1]['cached']).to eq('Erasmoneura alpha')
    expect(query.all[1]['otu_name']).to eq('otu1')
    expect(query.all[1]['observation_count']).to eq(2)
    #att the moment all depictions go to the "descriptors_scored" column
    expect(query.all[1]['observation_depictions']).to eq(1)
    expect(query.all[1]['descriptors_scored']).to eq(1)
  end

end
