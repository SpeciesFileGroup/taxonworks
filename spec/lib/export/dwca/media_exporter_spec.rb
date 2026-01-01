require 'rails_helper'

RSpec.describe Export::Dwca::MediaExporter, type: :model do
  let(:project) { FactoryBot.create(:valid_project) }
  let(:user) { FactoryBot.create(:valid_user) }
  let(:current_user_id) { user.id }
  let(:current_project_id) { project.id }

  before do
    # Set up project context
    ProjectsController.send(:define_method, :sessions_current_project_id) { current_project_id }
    ProjectsController.send(:define_method, :sessions_current_user_id) { current_user_id }
  end

  describe '#export_to' do
    let!(:specimen) { FactoryBot.create(:valid_specimen, project: project) }
    let(:scope) { DwcOccurrence.where(project_id: project.id) }
    let(:media_extension) { { collection_objects: CollectionObject.all.to_sql } }
    let(:exporter) { described_class.new(media_extension: media_extension, core_scope: scope) }

    before(:all) do
      # Ensure project has API token for media URLs
      Project.first.update!(set_new_api_access_token: true)
    end

    before do
      # Ensure dwc_occurrence exists
      specimen.get_dwc_occurrence
    end

    context 'with no media' do
      it 'writes only headers when no media exists' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        expect(lines.count).to eq(1)
        expect(lines.first).to eq(Export::CSV::Dwc::Extension::Media::HEADERS.join("\t") + "\n")

        output.close
        output.unlink
      end
    end

    context 'with image media' do
      let!(:depiction) { FactoryBot.create(:valid_depiction, depiction_object: specimen) }

      it 'exports image records' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + at least one data row
        expect(lines.count).to be >= 2

        # First line is headers
        expect(lines.first).to eq(Export::CSV::Dwc::Extension::Media::HEADERS.join("\t") + "\n")

        # Second line should contain image data
        data_line = lines[1]
        expect(data_line).to include('Image') # dc:type
        expect(data_line).to include(specimen.dwc_occurrence.occurrenceID) # coreid

        output.close
        output.unlink
      end

      it 'includes attribution data when present' do
        attribution = FactoryBot.create(:valid_attribution, attribution_object: depiction.image)
        person = FactoryBot.create(:valid_person)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person, position: 1)

        output = Tempfile.new('test_media')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + data row
        expect(lines.count).to be >= 2

        # Data line should include creator info
        data_line = lines[1]
        expect(data_line).to include(person.cached)

        output.close
        output.unlink
      end
    end

    context 'with sound media' do
      let!(:conveyance) { FactoryBot.create(:valid_conveyance, conveyance_object: specimen) }

      it 'exports sound records' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + at least one data row
        expect(lines.count).to be >= 2

        # Data line should contain sound data
        data_line = lines[1]
        expect(data_line).to include('Sound') # dc:type
        expect(data_line).to include(specimen.dwc_occurrence.occurrenceID) # coreid

        output.close
        output.unlink
      end
    end

    context 'cleanup behavior' do
      let(:conn) { ActiveRecord::Base.connection }

      it 'cleans up temporary tables after export' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)
        output.rewind
        output.close
        output.unlink

        # Verify temp tables are dropped
        temp_tables = [
          'temp_scoped_occurrences',
          'temp_media_image_ids',
          'temp_media_sound_ids',
          'temp_image_attributions',
          'temp_sound_attributions',
          'temp_image_api_links',
          'temp_sound_api_links'
        ]

        temp_tables.each do |table|
          result = conn.execute(<<~SQL).to_a
            SELECT EXISTS (
              SELECT FROM pg_tables
              WHERE schemaname = 'pg_temp'
              AND tablename = '#{table}'
            );
          SQL
          expect(result.first['exists']).to be_falsey, "#{table} should be dropped"
        end
      end
    end
  end
end
