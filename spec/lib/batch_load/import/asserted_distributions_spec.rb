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

  context 'Gazetteer id' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/gazetteer_id.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu) { FactoryBot.create(:valid_otu, id: 100) }
    let!(:gazetteer) { FactoryBot.create(:valid_gazetteer, id: 110) }
    let!(:source) { FactoryBot.create(:valid_source, id: 120) }

    before { import.create }

    specify '#create_attempted' do
      expect(import.create_attempted).to eq(true)
    end

    specify '#valid_objects' do
      expect(import.valid_objects.count).to eq(1)
    end

    specify '#total_records_created' do
      expect(import.total_records_created).to eq(1)
    end

    specify 'created asserted distribution with gazetteer shape' do
      expect(AssertedDistribution.count).to eq(1)
      ad = AssertedDistribution.first
      expect(ad.asserted_distribution_shape).to eq(gazetteer)
      expect(ad.asserted_distribution_shape_type).to eq('Gazetteer')
    end
  end

  context 'Gazetteer id is ignored when geographic_area_id is present' do
    let(:file_name) { 'spec/files/batch/asserted_distribution/gazetteer_id_ignored.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu) { FactoryBot.create(:valid_otu, id: 100) }
    let!(:ga) { FactoryBot.create(:valid_geographic_area, id: 110) }
    let!(:gazetteer) { FactoryBot.create(:valid_gazetteer, id: 999) }
    let!(:source) { FactoryBot.create(:valid_source, id: 120) }

    before { import.create }

    specify '#total_records_created' do
      expect(import.total_records_created).to eq(1)
    end

    specify 'uses geographic_area, not gazetteer' do
      expect(AssertedDistribution.count).to eq(1)
      ad = AssertedDistribution.first
      expect(ad.asserted_distribution_shape).to eq(ga)
      expect(ad.asserted_distribution_shape_type).to eq('GeographicArea')
    end
  end

  context 'More than one citation for the same OTU and area' do
    # line 2: new AD (otu 100, ga 110, source 120)
    # line 3: same pair as line 2, new source -> citation on line 2's AD
    # line 4: pair of an existing AD, new source -> citation on existing AD
    # line 5: pair and source of an existing AD -> duplicate citation, invalid
    # line 6: repeats line 3 -> parse error
    let(:file_name) { 'spec/files/batch/asserted_distribution/multiple_citations.tsv' }
    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) { BatchLoad::Import::AssertedDistributions.new(
      project_id: project.id,
      user_id: user.id,
      file: upload_file)
    }

    let!(:otu) { FactoryBot.create(:valid_otu, id: 100) }
    let!(:ga1) { FactoryBot.create(:valid_geographic_area, id: 110) }
    let!(:ga2) { FactoryBot.create(:valid_geographic_area, id: 111) }
    let!(:source1) { FactoryBot.create(:valid_source, id: 120) }
    let!(:source2) { FactoryBot.create(:valid_source, id: 121) }

    let!(:existing_ad) {
      AssertedDistribution.create!(
        asserted_distribution_object: otu,
        asserted_distribution_shape: ga2,
        source: source2
      )
    }

    let(:new_ad) {
      AssertedDistribution.find_by(
        asserted_distribution_object: otu, asserted_distribution_shape: ga1
      )
    }

    context 'preview' do
      before { import }

      specify 'rows for an already seen pair are valid citations' do
        expect(import.processed_rows[3].objects[:citations].first).to be_valid
        expect(import.processed_rows[4].objects[:citations].first).to be_valid
      end

      specify 'existing citation is invalid' do
        expect(import.processed_rows[5].objects[:citations].first).not_to be_valid
      end

      specify 'repeated line is a parse error' do
        expect(import.processed_rows[6].parse_errors).to be_present
        expect(import.processed_rows[6].all_objects).to be_empty
      end
    end

    context 'create' do
      before { import.create }

      specify '#total_records_created' do
        expect(import.total_records_created).to eq(3)
      end

      specify 'does not duplicate asserted distributions' do
        expect(AssertedDistribution.count).to eq(2)
      end

      specify 'adds citations to asserted distribution created from the file' do
        expect(new_ad.sources).to contain_exactly(source1, source2)
      end

      specify 'adds citation to existing asserted distribution' do
        expect(existing_ad.reload.sources).to contain_exactly(source1, source2)
      end
    end
  end

end
