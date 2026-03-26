require 'rails_helper'
require 'export/dwca'

describe 'checklist download packaging', type: :model, group: :darwin_core do
  include ActiveJob::TestHelper

  before(:context) do
    Current.user_id = 1
    Current.project_id = 1

    # Create taxon names with full classification
    root = FactoryBot.create(:root_taxon_name)
    kingdom = Protonym.create!(name: 'Animalia', rank_class: Ranks.lookup(:iczn, :kingdom), parent: root)
    phylum = Protonym.create!(name: 'Arthropoda', rank_class: Ranks.lookup(:iczn, :phylum), parent: kingdom)
    tn_class = Protonym.create!(name: 'Insecta', rank_class: Ranks.lookup(:iczn, :class), parent: phylum)
    order = Protonym.create!(name: 'Lepidoptera', rank_class: Ranks.lookup(:iczn, :order), parent: tn_class)
    family = Protonym.create!(name: 'Noctuidae', rank_class: Ranks.lookup(:iczn, :family), parent: order)
    genus = Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family)

    # Create species and link to OTUs
    species_names = ['alba', 'nigra', 'rubra']
    species_names.each do |name|
      taxon_name = Protonym.create!(name: name, rank_class: Ranks.lookup(:iczn, :species), parent: genus)
      otu = FactoryBot.create(:valid_otu, taxon_name: taxon_name)

      # Create specimen with determination
      specimen = FactoryBot.create(:valid_specimen)
      FactoryBot.create(:valid_taxon_determination, otu: otu, taxon_determination_object: specimen)
      specimen.get_dwc_occurrence
    end
  end

  after(:context) do
    DatabaseCleaner.clean_with(:truncation, except: %w(spatial_ref_sys users projects project_members people))
  end

  let(:otu_params) { { otu_id: Otu.all.pluck(:id) } }
  let(:extensions) { [:distribution, :references] }

  let!(:checklist_download) {
    ::Export::Dwca.checklist_download_async(
      otu_params,
      'https://example.org/checklist_url',
      extensions: extensions,
      project_id: Project.first.id
    )
  }

  specify 'queues the checklist job' do
    download = FactoryBot.create(:valid_download)
    expect {
      DwcaCreateChecklistDownloadJob.perform_later(
        download.id,
        core_otu_scope_params: otu_params,
        extensions: extensions,
        project_id: Project.first.id
      )
    }.to have_enqueued_job(DwcaCreateChecklistDownloadJob).with(
      download.id,
      core_otu_scope_params: otu_params,
      extensions: extensions,
      project_id: Project.first.id
    )
  end

  specify 'queues the checklist job with empty extensions' do
    download = FactoryBot.create(:valid_download)
    expect {
      DwcaCreateChecklistDownloadJob.perform_later(
        download.id,
        core_otu_scope_params: otu_params,
        extensions: [],
        project_id: Project.first.id
      )
    }.to have_enqueued_job(DwcaCreateChecklistDownloadJob).with(
      download.id,
      core_otu_scope_params: otu_params,
      extensions: [],
      project_id: Project.first.id
    )
  end

  specify '#checklist_download_async creates Download::DwcArchive::Checklist' do
    expect(Download.count).to eq(1)
    expect(Download.first).to be_a(Download::DwcArchive::Checklist)
  end

  specify 'uses default name when none provided' do
    expect(checklist_download.name).to match(/\ADwC Checklist on /)
  end

  specify 'uses default description when none provided' do
    expect(checklist_download.description).to eq(Export::Dwca::DEFAULT_CHECKLIST_DESCRIPTION)
  end

  specify 'uses provided name when given' do
    d = ::Export::Dwca.checklist_download_async(
      otu_params,
      'https://example.org/checklist_url',
      download_name: 'My Coleoptera Checklist',
      project_id: Project.first.id
    )
    expect(d.name).to eq('My Coleoptera Checklist')
  end

  specify 'uses provided description when given' do
    d = ::Export::Dwca.checklist_download_async(
      otu_params,
      'https://example.org/checklist_url',
      download_description: 'Beetles from the Pacific Northwest',
      project_id: Project.first.id
    )
    expect(d.description).to eq('Beetles from the Pacific Northwest')
  end

  specify 'uses default name when blank name provided' do
    d = ::Export::Dwca.checklist_download_async(
      otu_params,
      'https://example.org/checklist_url',
      download_name: '   ',
      project_id: Project.first.id
    )
    expect(d.name).to match(/\ADwC Checklist on /)
  end

  specify 'deleting checklist download before zip file is created raises in job' do
    checklist_download.delete
    expect { perform_enqueued_jobs }.to raise_error(ActiveRecord::RecordNotFound)
  end

  context 'after the archive is built' do
    before do
      perform_enqueued_jobs
    end

    let(:archive) { Zip::File.open(Download.first.file_path) }

    after do
      archive.close if archive
    end

    specify '#checklist_download_async creates Zip after worker' do
      expect(File.exist?(checklist_download.file_path)).to be_truthy
    end

    specify 'includes data.tsv' do
      expect(archive.find_entry('data.tsv')).to be_truthy
    end

    specify 'includes species_distribution.tsv when extension enabled' do
      expect(archive.find_entry('species_distribution.tsv')).to be_truthy
    end

    specify 'includes references.tsv when extension enabled' do
      expect(archive.find_entry('references.tsv')).to be_truthy
    end

    specify 'includes meta.xml' do
      expect(archive.find_entry('meta.xml')).to be_truthy
    end

    specify 'includes eml.xml' do
      expect(archive.find_entry('eml.xml')).to be_truthy
    end
  end
end
