require 'rails_helper'

# Spec to verify that the Ruby and SQL implementations of media identifier
# generation produce identical results
RSpec.describe Shared::Dwc::MediaIdentifier, type: :model do
  let(:conn) { ActiveRecord::Base.connection }

  shared_examples 'media identifier consistency' do |media_class, table_alias, factory_name|
    context "for #{media_class.name}" do
      let(:media_type) { media_class.name.downcase }
      it 'produces same result from Ruby and SQL when using UUID' do
        media = FactoryBot.create(factory_name)
        uuid_value = SecureRandom.uuid
        FactoryBot.create(:identifier_global_uuid, identifier_object: media, identifier: uuid_value)

        # Ruby implementation
        ruby_result = media.dwc_media_identifier

        # SQL implementation
        identifier_sql = media_class.dwc_media_identifier_sql(table_alias: table_alias)
        sql = <<~SQL
          SELECT #{identifier_sql} AS identifier
          FROM #{media_class.table_name} #{table_alias}
          LEFT JOIN identifiers uuid_id ON uuid_id.identifier_object_id = #{table_alias}.id
            AND uuid_id.identifier_object_type = '#{media_class.name}'
            AND uuid_id.type = 'Identifier::Global::Uuid'
          LEFT JOIN identifiers uri_id ON uri_id.identifier_object_id = #{table_alias}.id
            AND uri_id.identifier_object_type = '#{media_class.name}'
            AND uri_id.type = 'Identifier::Global::Uri'
          WHERE #{table_alias}.id = #{media.id}
        SQL
        sql_result = conn.select_value(sql)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq("#{media_type}:#{uuid_value}")
      end

      it 'produces same result from Ruby and SQL when using URI (no UUID)' do
        media = FactoryBot.create(factory_name)
        uri_value = 'http://example.org/media/123'
        FactoryBot.create(:identifier_global_uri, identifier_object: media, identifier: uri_value)

        # Ruby implementation
        ruby_result = media.dwc_media_identifier

        # SQL implementation
        identifier_sql = media_class.dwc_media_identifier_sql(table_alias: table_alias)
        sql = <<~SQL
          SELECT #{identifier_sql} AS identifier
          FROM #{media_class.table_name} #{table_alias}
          LEFT JOIN identifiers uuid_id ON uuid_id.identifier_object_id = #{table_alias}.id
            AND uuid_id.identifier_object_type = '#{media_class.name}'
            AND uuid_id.type = 'Identifier::Global::Uuid'
          LEFT JOIN identifiers uri_id ON uri_id.identifier_object_id = #{table_alias}.id
            AND uri_id.identifier_object_type = '#{media_class.name}'
            AND uri_id.type = 'Identifier::Global::Uri'
          WHERE #{table_alias}.id = #{media.id}
        SQL
        sql_result = conn.select_value(sql)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq("#{media_type}:#{uri_value}")
      end

      it 'produces same result from Ruby and SQL when using ID (no UUID or URI)' do
        media = FactoryBot.create(factory_name)

        # Ruby implementation
        ruby_result = media.dwc_media_identifier

        # SQL implementation
        identifier_sql = media_class.dwc_media_identifier_sql(table_alias: table_alias)
        sql = <<~SQL
          SELECT #{identifier_sql} AS identifier
          FROM #{media_class.table_name} #{table_alias}
          LEFT JOIN identifiers uuid_id ON uuid_id.identifier_object_id = #{table_alias}.id
            AND uuid_id.identifier_object_type = '#{media_class.name}'
            AND uuid_id.type = 'Identifier::Global::Uuid'
          LEFT JOIN identifiers uri_id ON uri_id.identifier_object_id = #{table_alias}.id
            AND uri_id.identifier_object_type = '#{media_class.name}'
            AND uri_id.type = 'Identifier::Global::Uri'
          WHERE #{table_alias}.id = #{media.id}
        SQL
        sql_result = conn.select_value(sql)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq("#{media_type}:#{media.id}")
      end

      it 'produces same result when both UUID and URI are present (UUID takes precedence)' do
        media = FactoryBot.create(factory_name)
        uuid_value = SecureRandom.uuid
        uri_value = 'http://example.org/media/456'
        FactoryBot.create(:identifier_global_uuid, identifier_object: media, identifier: uuid_value)
        FactoryBot.create(:identifier_global_uri, identifier_object: media, identifier: uri_value)

        # Ruby implementation
        ruby_result = media.dwc_media_identifier

        # SQL implementation
        identifier_sql = media_class.dwc_media_identifier_sql(table_alias: table_alias)
        sql = <<~SQL
          SELECT #{identifier_sql} AS identifier
          FROM #{media_class.table_name} #{table_alias}
          LEFT JOIN identifiers uuid_id ON uuid_id.identifier_object_id = #{table_alias}.id
            AND uuid_id.identifier_object_type = '#{media_class.name}'
            AND uuid_id.type = 'Identifier::Global::Uuid'
          LEFT JOIN identifiers uri_id ON uri_id.identifier_object_id = #{table_alias}.id
            AND uri_id.identifier_object_type = '#{media_class.name}'
            AND uri_id.type = 'Identifier::Global::Uri'
          WHERE #{table_alias}.id = #{media.id}
        SQL
        sql_result = conn.select_value(sql)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq("#{media_type}:#{uuid_value}")
      end
    end
  end

  include_examples 'media identifier consistency', Image, 'img', :valid_image
  include_examples 'media identifier consistency', Sound, 'snd', :valid_sound
end
