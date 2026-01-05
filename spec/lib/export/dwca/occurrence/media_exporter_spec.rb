require 'rails_helper'

RSpec.describe Export::Dwca::Occurrence::MediaExporter, type: :model do

  describe '#export_to' do
    let!(:specimen) { FactoryBot.create(:valid_specimen, no_dwc_occurrence: false) }
    let(:scope) { DwcOccurrence.all }
    let(:media_extension) { { collection_objects: CollectionObject.all.to_sql } }
    let(:exporter) { described_class.new(media_extension: media_extension) }

    before(:all) do
      # Ensure project has API token for media URLs.
      Project.first.update!(set_new_api_access_token: true)
    end

    context 'with no media' do
      specify 'writes only headers when no media exists' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines

        expect(lines.count).to eq(1)
        expect(lines.first).to eq(Export::CSV::Dwc::Extension::Media::HEADERS.join("\t") + "\n")
      end
    end

    context 'with image media' do
      let!(:depiction) { FactoryBot.create(:valid_depiction, depiction_object: specimen) }

      specify 'exports expected number of rows' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines

        # Should have header + one data row.
        expect(lines.count).to eq 2
      end

      specify 'exports expected header row' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines

        expect(lines.first).to eq(Export::CSV::Dwc::Extension::Media::HEADERS.join("\t") + "\n")
      end

      specify 'exports expected data in data row' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines

        data_line = lines[1]
        expect(data_line).to include('Image') # dc:type
        expect(data_line).to include(specimen.dwc_occurrence.occurrenceID) # coreid
      end

      specify 'includes attribution data when present' do
        attribution = FactoryBot.create(:valid_attribution, attribution_object: depiction.image)
        person = FactoryBot.create(:valid_person)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person)

        output = Tempfile.new('test_media')
        exporter.export_to(output)

        data_line = output.read.lines[1]

        expect(data_line).to include(person.cached)
      end
    end

    context 'with sound media' do
      let!(:conveyance) { FactoryBot.create(:valid_conveyance, conveyance_object: specimen) }

      specify 'exports sound records' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        lines = output.read.lines

        # Data line should contain sound data.
        data_line = lines[1]
        expect(data_line).to include('Sound') # dc:type
        expect(data_line).to include(specimen.dwc_occurrence.occurrenceID) # coreid
      end
    end

    context 'cleanup behavior' do
      let(:conn) { ActiveRecord::Base.connection }

      specify 'cleans up temporary tables after export' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        # Verify temp tables are dropped.
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
