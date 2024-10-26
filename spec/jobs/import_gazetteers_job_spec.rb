require 'rails_helper'

RSpec.describe ImportGazetteersJob, type: :job do
  specify 'queues job in import_gazetteers' do
    expect { ImportGazetteersJob.perform_later }
      .to have_enqueued_job.on_queue(:import_gazetteers)
  end

  context 'with a valid shapefile' do
    let!(:user) { FactoryBot.create(:valid_user) }
    let!(:project) { FactoryBot.create(:valid_project,
      created_by_id: user.id, updated_by_id: user.id) }
    let!(:project2) { FactoryBot.create(:valid_project,
      created_by_id: user.id, updated_by_id: user.id) }
    let!(:project3) { FactoryBot.create(:valid_project,
      created_by_id: user.id, updated_by_id: user.id) }
    let(:shp_doc) {
      Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/four_valid_shapes.shp'),
          'application/x-shapefile'
        ))
    }
    let(:shx_doc) {
      Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/four_valid_shapes.shx'),
          'application/x-shapefile'
        ))
    }
    let(:dbf_doc) {
      Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/four_valid_shapes.dbf'),
          'application/x-dbf'
        ))
    }
    let(:prj_doc) {
      Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/four_valid_shapes.prj'),
          'text/plain'
        ))
    }
    let(:num_shapefile_records) { 4 }
    let(:shapefile) {
      {
        shp_doc_id: shp_doc.id,
        shx_doc_id: shx_doc.id,
        dbf_doc_id: dbf_doc.id,
        prj_doc_id: prj_doc.id,
        name_field: 'Name',
        iso_a2_field: 'iso_a2',
        iso_a3_field: 'iso_a3'
      }
    }
    let(:citation_options) {
      {
        cite_gzs: false,
        citation: nil
      }
    }
    let(:progress_tracker) {
      GazetteerImport.create!(
        shapefile: shp_doc.document_file_file_name
      )
    }
    let(:projects) { [project.id] }

    before(:each) {
      Current.user_id = user.id
      Current.project_id = project.id

      ImportGazetteersJob.perform_now(
        shapefile, citation_options, user.id, project.id,
        progress_tracker, projects
      )
    }

    specify 'creates the right number of Gazetteers' do
      expect(Gazetteer.all.count).to eq(num_shapefile_records)
    end

    context 'cloning into multiple projects' do
      let(:projects) { [project.id, project2.id] }

      specify 'creates the right number of Gazetteers' do
        expect(Gazetteer.where(project: ).count)
          .to eq(num_shapefile_records)

        expect(Gazetteer.where(project: project2).count)
          .to eq(num_shapefile_records)

        expect(Gazetteer.where(project: project3).count)
          .to eq(0)
      end
    end

    specify 'creates Gazetteers with the expected names' do
      expect(Gazetteer.all.map { |g| g.name })
        .to contain_exactly(
          'Walking Iron Wildlife Area', 'Walking Iron County Park',
          'Morton Forest', 'Halfway Prairie School'
        )
    end

    specify 'citation option off creates GZs with no citations' do
      expect(Citation.any?).to eq(false)
    end

    specify 'creates iso a2 values' do
      expect(Gazetteer.all.order(:id).map { |g| g.iso_3166_a2 })
        .to eq([nil, nil, 'ZZ', nil])
    end

    specify 'creates iso a3 values' do
      expect(Gazetteer.all.order(:id).map { |g| g.iso_3166_a3 })
        .to eq([nil, nil, 'ZZZ', nil])
    end

    context 'progress tracking' do
      specify 'records number of gzs in the shapefile' do
        expect(progress_tracker.num_records).to eq(num_shapefile_records)
      end

      specify 'records number of gzs created on completion' do
        expect(progress_tracker.num_records_imported)
          .to eq(num_shapefile_records)
      end

      specify 'has empty `error_messages` on success' do
        expect(progress_tracker.error_messages).to eq(nil)
      end

      context 'with an error causing the job to quit' do
        let(:citation_options) {
          {
            cite_gzs: true,
            citation: {
              is_original: false,
              pages: '3-4',
              source_id: 123456 # doesn't exist
            }
          }
        }

        specify 'records the abort reason' do
          expect(progress_tracker.error_messages)
            .to include('Citations source')
        end

        specify 'records the number of records processed before abort' do
          expect(progress_tracker.num_records_imported).to eq(0)
        end
      end
    end

    context 'with citation' do
      let(:source) {
        FactoryBot.create(:valid_source)
      }
      let(:citation_options) {
        {
          cite_gzs: true,
          citation: {
            is_original: false,
            pages: '3-4',
            source_id: source.id
          }
        }
      }

      specify 'each created GZ has the expected citation' do
        expect(
          Gazetteer.all.map { |g| g.citations.map { |c| c.source_id } }.flatten
        ).to eq([source.id] * num_shapefile_records)
      end

      context 'cloned into multiple projects' do
        let(:projects) { [project.id, project2.id] }

        specify 'there are the expected number of citations' do
          expect(Citation.where(project_id: project.id).count)
            .to eq(num_shapefile_records)

          expect(Citation.where(project_id: project2.id).count)
            .to eq(num_shapefile_records)

          expect(Citation.where(project_id: project3.id).count)
            .to eq(0)
        end

      end
    end

  end

end