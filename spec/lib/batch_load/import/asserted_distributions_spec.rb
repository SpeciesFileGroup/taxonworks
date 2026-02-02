require 'rails_helper'

describe BatchLoad::Import::AssertedDistributions, type: :model do
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  context 'Otu id, Geographic Area id, Source id' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/otuid_gaid_sourceid.csv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu) { FactoryBot.create(:valid_otu, id: 100) }
    let!(:ga) { FactoryBot.create(:valid_geographic_area, id: 110) }
    let!(:source) { FactoryBot.create(:valid_source, id: 120) }

    before { import.create }

    specify '#create_attempted' do
      expect(import.create_attempted).to eq(true)
    end

    specify '#valid_objects' do
      expect(import.valid_objects.count).to eq(1)
    end

    specify '#successful_rows' do
      expect(import.successful_rows).to be_truthy
    end

    specify '#total_records_created' do
      expect(import.total_records_created).to eq(1)
    end

    specify 'created asserted distribution' do
      expect(AssertedDistribution.count).to eq(1)
    end
  end

  context 'All text fields, no ids' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/all_text.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu1) { FactoryBot.create(:valid_otu, name: 'Triumph') }
    let!(:otu2) { FactoryBot.create(:valid_otu, name: 'Dust') }

    let!(:ga) { FactoryBot.create(:valid_geographic_area, name: 'Mallow') }
    let!(:state) { FactoryBot.create(:level1_geographic_area, name: 'Tumbler') }
    let!(:country) {
      c = state.parent
      c.update!(name: 'Piggy')
      c
    }

    let!(:source1) { FactoryBot.create(:valid_source, doi: '10.11646/zootaxa.5174.4.4') }
    # cached == verbatim
    let!(:source2) { Source::Verbatim.create!(verbatim: 'Butters') }

    before { import.create }

    specify '#create_attempted' do
      expect(import.create_attempted).to eq(true)
    end

    specify '#valid_objects' do
      expect(import.valid_objects.count).to eq(2)
    end

    specify '#successful_rows' do
      expect(import.successful_rows).to be_truthy
    end

    specify '#total_records_created' do
      expect(import.total_records_created).to eq(2)
    end

    specify 'created asserted distributions' do
      expect(AssertedDistribution.count).to eq(2)
    end

    specify 'expected asserted distribution data' do
      expect(AssertedDistribution.all.map{|ad| ad.asserted_distribution_object.name}).to eq(['Triumph', 'Dust'])
      expect(AssertedDistribution.all.map{|ad| ad.asserted_distribution_shape.name}).to eq(['Mallow', 'Tumbler'])
      expect(AssertedDistribution.all.map{|ad| ad.sources.map(&:type)}).to eq([['Source::Bibtex'], ['Source::Verbatim']])
    end
  end

  context 'Citation matches after stripping italics tags' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/citation_strip_html.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu) { FactoryBot.create(:valid_otu, name: 'Alpha') }
    let!(:ga) { FactoryBot.create(:valid_geographic_area, name: 'Mallow') }
    let!(:source) {
      Source::Verbatim.create!(
        verbatim: 'Miyamoto, S. (1956) Anatomy of bug. <i>Shin. Konchu</i>, 9(4), 18-23.'
      )
    }

    before { import.create }

    specify 'created asserted distribution with citation' do
      expect(import.total_records_created).to eq(1)
      expect(AssertedDistribution.count).to eq(1)
      expect(AssertedDistribution.first.sources).to contain_exactly(source)
    end
  end

  context 'Name and taxon_name columns resolve OTU' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/taxon_name.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:taxon_name_one) { FactoryBot.create(:valid_taxon_name, name: 'Adidae') }
    let!(:taxon_name_two) { FactoryBot.create(:valid_taxon_name, name: 'Bididae') }
    let!(:otu_one) { FactoryBot.create(:valid_otu, name: 'Alpha', taxon_name: taxon_name_one) }
    let!(:otu_two) { FactoryBot.create(:valid_otu, name: 'Beta', taxon_name: taxon_name_two) }
    let!(:ga) { FactoryBot.create(:valid_geographic_area, name: 'Fallow') }
    let!(:source) { FactoryBot.create(:valid_source, id: 121) }

    before { import.create }

    specify 'created asserted distributions via name and taxon_name' do
      expect(import.total_records_created).to eq(2)
      expect(AssertedDistribution.count).to eq(2)
      expect(AssertedDistribution.all.map(&:asserted_distribution_object)).to match_array([otu_one, otu_two])
    end

    specify 'uses taxon_name column when provided' do
      taxon_name_distribution = AssertedDistribution.find_by(
        asserted_distribution_object_id: otu_two.id,
        asserted_distribution_object_type: 'Otu'
      )

      expect(taxon_name_distribution).to be_present
    end
  end

  context 'Name column prefers OTU name over taxon_name' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/name_precedence.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu_name_match) { FactoryBot.create(:valid_otu, name: 'Alpha', taxon_name: FactoryBot.create(:valid_taxon_name, name: 'Gammaidae')) }
    let!(:otu_taxon_name_match) { FactoryBot.create(:valid_otu, name: 'Different', taxon_name: FactoryBot.create(:valid_taxon_name, name: 'Alphaidae')) }
    let!(:ga) { FactoryBot.create(:valid_geographic_area, name: 'Fallow') }
    let!(:source) { FactoryBot.create(:valid_source, id: 121) }

    before { import.create }

    specify 'resolves to OTU name match' do
      expect(import.total_records_created).to eq(1)
      expect(AssertedDistribution.count).to eq(1)
      expect(AssertedDistribution.first.asserted_distribution_object).to eq(otu_name_match)
    end
  end

end
