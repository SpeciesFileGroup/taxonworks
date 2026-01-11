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

      specify 'associatedSpecimenReference is an API URL for CollectionObject' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines
        headers = lines[0].split("\t")
        data_row = lines[1].split("\t")

        # Find the associatedSpecimenReference column index
        assoc_spec_ref_index = headers.index('associatedSpecimenReference')
        expect(assoc_spec_ref_index).not_to be_nil, 'associatedSpecimenReference header should exist'

        assoc_spec_ref_value = data_row[assoc_spec_ref_index]

        # Should be a full API URL, not just a UUID
        expect(assoc_spec_ref_value).to match(%r{^https?://}),
          "Expected associatedSpecimenReference to be a URL, got: #{assoc_spec_ref_value}"
        expect(assoc_spec_ref_value).to include('/api/v1/collection_objects/'),
          "Expected associatedSpecimenReference to be a collection_objects API URL, got: #{assoc_spec_ref_value}"
        expect(assoc_spec_ref_value).to include(specimen.id.to_s),
          "Expected associatedSpecimenReference to include specimen ID #{specimen.id}, got: #{assoc_spec_ref_value}"
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

    context 'with sled image media' do
      let!(:sled_image) { FactoryBot.create(:valid_sled_image) }
      let!(:specimen1) { FactoryBot.create(:valid_specimen, no_dwc_occurrence: false) }
      let!(:specimen2) { FactoryBot.create(:valid_specimen, no_dwc_occurrence: false) }

      # Create two depictions of different specimens from the same sled image.
      # Each represents a different box/position on the specimen tray.
      let!(:depiction1) do
        FactoryBot.create(:valid_depiction,
          image: sled_image.image,
          depiction_object: specimen1,
          sled_image: sled_image,
          sled_image_x_position: 0,
          sled_image_y_position: 0,
          svg_view_box: '10 20 100 150'
        )
      end

      let!(:depiction2) do
        FactoryBot.create(:valid_depiction,
          image: sled_image.image,
          depiction_object: specimen2,
          sled_image: sled_image,
          sled_image_x_position: 1,
          sled_image_y_position: 0,
          svg_view_box: '120 20 100 150'
        )
      end

      specify 'exports separate rows for each sled image box' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        lines = output.read.lines

        # Should have header + two data rows (one per depiction).
        expect(lines.count).to eq 3
      end

      specify 'each depiction has unique cropped accessURI with scale_to_box endpoint' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines
        headers = lines[0].split("\t")

        access_uri_index = headers.index('accessURI')

        data_row1 = lines[1].split("\t")
        data_row2 = lines[2].split("\t")

        access_uri1 = data_row1[access_uri_index]
        access_uri2 = data_row2[access_uri_index]

        expect(access_uri1).not_to eq(access_uri2)

        # URLs are shortened, so expand them to verify they point to
        # scale_to_box endpoints Extract the short key from the URL (e.g.,
        # http://127.0.0.1:3000/s/abc123 -> abc123)
        short_key1 = access_uri1.split('/s/').last
        short_key2 = access_uri2.split('/s/').last

        long_url1 = Shortener::ShortenedUrl.find_by(unique_key: short_key1)&.url
        long_url2 = Shortener::ShortenedUrl.find_by(unique_key: short_key2)&.url

        expect(long_url1).to include('/scale_to_box/')
        expect(long_url2).to include('/scale_to_box/')

        expect(long_url1).to include('/file/sha/')
        expect(long_url2).to include('/file/sha/')
        expect(long_url1).to include(sled_image.image.image_file_fingerprint)
        expect(long_url2).to include(sled_image.image.image_file_fingerprint)
      end

      specify 'all depictions from same sled image share furtherInformationURL' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines
        headers = lines[0].split("\t")

        further_info_index = headers.index('furtherInformationURL')

        data_row1 = lines[1].split("\t")
        data_row2 = lines[2].split("\t")

        further_info1 = data_row1[further_info_index]
        further_info2 = data_row2[further_info_index]

        expect(further_info1).to eq(further_info2)

        expect(further_info1).not_to include('/scale_to_box/')
      end

      specify 'each depiction links to correct specimen occurrence' do
        output = Tempfile.new('test_media')
        exporter.export_to(output)

        content = output.read
        lines = content.lines
        headers = lines[0].split("\t")

        # Find the coreid column (occurrenceID).
        data_row1 = lines[1].split("\t")
        data_row2 = lines[2].split("\t")

        occurrence_id1 = data_row1[0]
        occurrence_id2 = data_row2[0]

        # Each row should link to different specimens
        expect([occurrence_id1, occurrence_id2]).to contain_exactly(
          specimen1.dwc_occurrence.occurrenceID,
          specimen2.dwc_occurrence.occurrenceID
        )
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
