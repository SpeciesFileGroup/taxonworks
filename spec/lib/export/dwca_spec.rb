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

    let!(:d) { 
      ::Export::Dwca.download_async(
        a, 'https://example.org/some_url',
        extension_scopes: { biological_associations: b.to_sql },
        predicate_extensions: {}
      )   
    } 

    specify 'queues the job' do
      download = FactoryBot.create(:valid_download)
      expect {
        DwcaCreateDownloadJob.perform_later(
          download, 
          core_scope: a.to_sql,
          extension_scopes: { biological_associations: b.to_sql }
        )
      }.to have_enqueued_job(DwcaCreateDownloadJob).with(download, core_scope: a.to_sql, extension_scopes: { biological_associations: b.to_sql } )
    end

   specify 'queues the job with empty extensions' do
      download = FactoryBot.create(:valid_download)
      expect {
        DwcaCreateDownloadJob.perform_later(
          download, 
          core_scope: a.to_sql,
          extension_scopes: { biological_associations: nil }
        )
      }.to have_enqueued_job(DwcaCreateDownloadJob).with(download, core_scope: a.to_sql, extension_scopes: { biological_associations: nil } )
    end

    specify '#download_async creates Download' do 
      expect(Download.count).to eq(1)
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
