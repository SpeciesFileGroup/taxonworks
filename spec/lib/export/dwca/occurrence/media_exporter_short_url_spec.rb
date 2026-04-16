require 'rails_helper'

# Spec to verify that media export correctly handles both paths:
# 1. Using existing shortened_urls when available
# 2. Creating new short URLs when they don't exist
RSpec.describe Export::Dwca::Occurrence::MediaExporter, type: :model do
  let(:conn) { ActiveRecord::Base.connection }

  before(:all) do
    # Media export requires an API access token.
    Project.first.update!(set_new_api_access_token: true)
  end

  describe 'short URL handling in populate_temp_image_api_links_table' do
    let(:exporter) do
      Export::Dwca::Occurrence::MediaExporter.new(
        media_extension: {
          collection_objects: CollectionObject.all,
          field_occurrences: FieldOccurrence.all
        }
      )
    end

    specify 'uses existing short URLs when available' do
      image = FactoryBot.create(:valid_image)

      # Create existing short URLs for this image.
      access_url = Shared::Api.image_file_long_url(image.image_file_fingerprint, image.project.api_access_token)
      metadata_url = Shared::Api.image_metadata_long_url(image.id, image.project.api_access_token)

      access_short = Shortener::ShortenedUrl.generate(access_url)
      metadata_short = Shortener::ShortenedUrl.generate(metadata_url)

      # Populate the temp table
      exporter.send(:populate_temp_image_api_links_table, [image.id])

      # Check the temp table has the pre-existing short URLs
      result = conn.select_one("SELECT * FROM temp_media_image_links WHERE image_id = #{image.id}")

      expect(result['access_uri']).to eq(Shared::Api.short_url_from_key(access_short.unique_key))
      expect(result['further_information_url']).to eq(Shared::Api.short_url_from_key(metadata_short.unique_key))
    end

    specify 'creates new short URLs when they do not exist' do
      image = FactoryBot.create(:valid_image)

      # Verify no short URLs exist for this image.
      access_url = Shared::Api.image_file_long_url(image.image_file_fingerprint, image.project.api_access_token)
      metadata_url = Shared::Api.image_metadata_long_url(image.id, image.project.api_access_token)

      expect(Shortener::ShortenedUrl.find_by(url: access_url)).to be_nil
      expect(Shortener::ShortenedUrl.find_by(url: metadata_url)).to be_nil

      # Populate the temp table - this should create new short URLs.
      exporter.send(:populate_temp_image_api_links_table, [image.id])

      access_short = Shortener::ShortenedUrl.find_by(url: access_url)
      metadata_short = Shortener::ShortenedUrl.find_by(url: metadata_url)

      # Check the temp table has the newly created short URLs.
      result = conn.select_one("SELECT * FROM temp_media_image_links WHERE image_id = #{image.id}")

      expect(result['access_uri']).to eq(Shared::Api.short_url_from_key(access_short.unique_key))
      expect(result['further_information_url']).to eq(Shared::Api.short_url_from_key(metadata_short.unique_key))
    end
  end
end
