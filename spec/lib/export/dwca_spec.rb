require 'rails_helper'
require 'export/dwca'

# TODO: replace Current.project_id with @project_id
describe Export::Dwca, type: :model, group: :darwin_core do
  include ActiveJob::TestHelper

  # specify "stores a compressed file in rails' temp directory" do
  #   path = Export::Dwca.get_archive
  #   expect(File.exist?(path)).to be_truthy
  #   File.delete(path)
  #   expect(path.to_s.index(Rails.root.join('tmp').to_s)).to eq(0)
  # end

  context 'download packaging' do
    before do
      include ActiveJob::TestHelper
      3.times do
        f = FactoryBot.create(:valid_specimen)
        f.get_dwc_occurrence
      end

      FactoryBot.create(
        :valid_biological_association,
        biological_association_subject: CollectionObject.first,
        biological_association_object: CollectionObject.last
      )
    end

    let(:a) { DwcOccurrence.all }
    let(:b) { BiologicalAssociation.all }
    let(:c) { CollectionObject.all }
    let(:f) { FieldOccurrence.all}

    let!(:d) {
      ::Export::Dwca.download_async(
        a, 'https://example.org/some_url',
        extension_scopes: {
          biological_associations: {
            core_params: {},
            collection_objects_query: b.to_sql
          },
          media: {
            collection_objects: c.to_sql,
            field_occurrences: f.to_sql
          }
         },
        predicate_extensions: {},
        project_id: Project.first.id
      )
    }

    specify 'queues the job' do
      download = FactoryBot.create(:valid_download)
      expect {
        DwcaCreateDownloadJob.perform_later(
          download.id,
          core_scope: a.to_sql,
          extension_scopes: {
            biological_associations: b.to_sql,
            media: {
              collection_objects: c.to_sql,
              field_occurrences: f.to_sql
            }
          }
        )
      }.to have_enqueued_job(DwcaCreateDownloadJob).with(download.id, core_scope: a.to_sql, extension_scopes: {
        biological_associations: b.to_sql,
        media: {
          collection_objects: c.to_sql,
          field_occurrences: f.to_sql
        }
      } )
    end

   specify 'queues the job with empty extensions' do
      download = FactoryBot.create(:valid_download)
      expect {
        DwcaCreateDownloadJob.perform_later(
          download.id,
          core_scope: a.to_sql,
          extension_scopes: { biological_associations: nil }
        )
      }.to have_enqueued_job(DwcaCreateDownloadJob).with(download.id, core_scope: a.to_sql, extension_scopes: { biological_associations: nil } )
    end

    specify '#download_async creates Download' do
      expect(Download.count).to eq(1)
    end

    specify 'deleting download before zip file is created raises in job' do
      d.delete
      expect{perform_enqueued_jobs}.to raise_error(ActiveRecord::RecordNotFound)
    end

    specify '#download_async creates Zip after worker' do
      perform_enqueued_jobs
      expect(File.exist?(d.file_path)).to be_truthy
    end

    specify 'includes data.tsv' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('data.tsv')).to be_truthy
    end

    specify 'includes resource_relationships.tsv' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('resource_relationships.tsv')).to be_truthy
    end

    specify 'includes media.tsv' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('media.tsv')).to be_truthy
    end

  end

  context 'checklist download packaging' do
    before do
      include ActiveJob::TestHelper

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

    specify 'deleting checklist download before zip file is created raises in job' do
      checklist_download.delete
      expect { perform_enqueued_jobs }.to raise_error(ActiveRecord::RecordNotFound)
    end

    specify '#checklist_download_async creates Zip after worker' do
      perform_enqueued_jobs
      expect(File.exist?(checklist_download.file_path)).to be_truthy
    end

    specify 'includes data.tsv' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('data.tsv')).to be_truthy
    end

    specify 'includes distribution.tsv when extension enabled' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('distribution.tsv')).to be_truthy
    end

    specify 'includes references.tsv when extension enabled' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('references.tsv')).to be_truthy
    end

    specify 'includes meta.xml' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('meta.xml')).to be_truthy
    end

    specify 'includes eml.xml' do
      perform_enqueued_jobs
      z = Zip::File.open(Download.first.file_path)
      expect(z.find_entry('eml.xml')).to be_truthy
    end
  end

  specify '.sample is ordered correctly #3' do
    13.times do
      FactoryBot.create(:valid_specimen)
    end

    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(10)
    m = Export::Dwca.index_metadata(CollectionObject, s)

    expect(m[:sample]).to contain_exactly(*s.collect{|a| a.to_global_id.to_s} )
  end

  specify 'index_metadata :sample is ordered correctly #2' do
    6.times do
      FactoryBot.create(:valid_specimen)
    end

    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(3)
    m = Export::Dwca.index_metadata(CollectionObject, s)

    expect(m[:sample]).to contain_exactly(*(s.collect{|a| a.to_global_id.to_s} - []) )
  end

  specify 'index_metadata .sample is ordered correctly (1 record)' do
    2.times do
      FactoryBot.create(:valid_specimen)
    end

    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(1)
    m = Export::Dwca.index_metadata(CollectionObject, s)
    expect(m[:sample]).to contain_exactly(*(s.collect{|a| a.to_global_id.to_s}) )
  end

  specify 'index_metadata .sample is ordered correctly (no records)' do
    FactoryBot.create(:valid_specimen)
    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(0)
    m = Export::Dwca.index_metadata(CollectionObject, s)
    expect(m[:sample]).to contain_exactly( )
  end

end
