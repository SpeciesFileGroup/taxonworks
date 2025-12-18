require 'rails_helper'

# Spec to verify that Ruby attribution methods match their SQL counterparts
# in the new Shared::Dwc::MediaAttributionSql concern
RSpec.describe Shared::Dwc::MediaAttributionSql, type: :model do
  let(:conn) { ActiveRecord::Base.connection }

  shared_examples 'SQL method consistency' do |media_class, table_alias, factory_name|
    let(:media_type) { media_class.name.downcase }

    context "for #{media_class.name}" do
      describe '.dwc_media_license_sql' do
        it 'produces same result as dwc_media_dcterms_rights when license is set' do
          media = FactoryBot.create(factory_name)
          license_key = CREATIVE_COMMONS_LICENSES.keys.first
          attribution = FactoryBot.create(:valid_attribution,
            attribution_object: media,
            license: license_key
          )

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_dcterms_rights

          # SQL result
          license_sql = media_class.dwc_media_license_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT #{license_sql} AS license
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq(CREATIVE_COMMONS_LICENSES[license_key][:link])
        end

        it 'returns nil when no license is set' do
          media = FactoryBot.create(factory_name)

          # Ruby result
          ruby_result = media.dwc_media_dcterms_rights

          # SQL result
          license_sql = media_class.dwc_media_license_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT #{license_sql} AS license
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to be_nil
        end
      end

      describe '.dwc_media_owner_sql' do
        it 'produces same result as dwc_media_owner with person owners' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person1 = FactoryBot.create(:valid_person)
          person2 = FactoryBot.create(:valid_person)
          FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person1, position: 1)
          FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person2, position: 2)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_owner

          # SQL result
          owner_sql = media_class.dwc_media_owner_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT owners.names
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            #{owner_sql}
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{person1.cached} | #{person2.cached}")
        end

        it 'produces same result as dwc_media_owner with organization owners' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          org1 = FactoryBot.create(:valid_organization)
          org2 = FactoryBot.create(:valid_organization)
          AttributionOwner.create!(role_object: attribution, organization: org1, position: 1)
          AttributionOwner.create!(role_object: attribution, organization: org2, position: 2)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_owner

          # SQL result
          owner_sql = media_class.dwc_media_owner_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT owners.names
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            #{owner_sql}
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{org1.name} | #{org2.name}")
        end
      end

      describe '.dwc_media_creator_sql' do
        it 'produces same result as dwc_media_dc_creator' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person1 = FactoryBot.create(:valid_person)
          person2 = FactoryBot.create(:valid_person)
          FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person1, position: 1)
          FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person2, position: 2)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_dc_creator

          # SQL result
          creator_sql = media_class.dwc_media_creator_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT creators.names
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            #{creator_sql}
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{person1.cached} | #{person2.cached}")
        end
      end

      describe '.dwc_media_creator_identifiers_sql' do
        it 'produces same result as dwc_media_dcterms_creator with ORCID' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person1 = FactoryBot.create(:valid_person)
          person2 = FactoryBot.create(:valid_person)
          # Use valid ORCIDs with correct check digits
          orcid1 = FactoryBot.create(:identifier_global_orcid, identifier_object: person1, identifier: 'http://orcid.org/0000-0002-1825-0097')
          orcid2 = FactoryBot.create(:identifier_global_orcid, identifier_object: person2, identifier: 'https://orcid.org/0000-0002-1824-6098')
          FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person1, position: 1)
          FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person2, position: 2)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_dcterms_creator

          # SQL result
          creator_ids_sql = media_class.dwc_media_creator_identifiers_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT creator_ids.ids
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            #{creator_ids_sql}
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{orcid1.cached} | #{orcid2.cached}")
        end

        it 'returns empty/nil when creators have no identifiers' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person = FactoryBot.create(:valid_person)
          FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person, position: 1)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_dcterms_creator

          # SQL result
          creator_ids_sql = media_class.dwc_media_creator_identifiers_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT creator_ids.ids
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            #{creator_ids_sql}
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          # Ruby returns empty string, SQL returns nil - both are acceptable for "no data"
          expect(ruby_result).to eq('')
          expect(sql_result).to be_nil
        end
      end

      describe '.dwc_media_copyright_holders_sql' do
        it 'produces SQL matching the export query structure' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person = FactoryBot.create(:valid_person)
          org = FactoryBot.create(:valid_organization)
          FactoryBot.create(:role, type: 'AttributionCopyrightHolder', role_object: attribution, person: person, position: 1)
          AttributionCopyrightHolder.create!(role_object: attribution, organization: org, position: 2)

          # SQL result
          holders_sql = media_class.dwc_media_copyright_holders_sql(table_alias: table_alias)
          sql = <<~SQL
            SELECT copyright_holders.names
            FROM #{media_class.table_name} #{table_alias}
            LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
              AND attributions.attribution_object_type = '#{media_class.name}'
            #{holders_sql}
            WHERE #{table_alias}.id = #{media.id}
          SQL
          sql_result = conn.select_value(sql)

          # Should have both person and organization
          expect(sql_result).to eq("#{person.cached} | #{org.name}")
        end
      end
    end
  end

  include_examples 'SQL method consistency', Image, 'img', :valid_image
  include_examples 'SQL method consistency', Sound, 'snd', :valid_sound

  # Test the PostgreSQL authorship_sentence function matches Utilities::Strings.authorship_sentence
  describe 'pg_temp.authorship_sentence' do
    before(:all) do
      # Create the temporary function
      conn = ActiveRecord::Base.connection
      conn.execute(<<~SQL)
        CREATE OR REPLACE FUNCTION pg_temp.authorship_sentence(names text[])
        RETURNS text AS $$
          SELECT CASE
            WHEN array_length(names, 1) IS NULL THEN NULL
            WHEN array_length(names, 1) = 1 THEN names[1]
            WHEN array_length(names, 1) = 2 THEN names[1] || ' & ' || names[2]
            ELSE array_to_string(names[1:array_length(names,1)-1], ', ') || ' & ' || names[array_length(names,1)]
          END
        $$ LANGUAGE SQL IMMUTABLE;
      SQL
    end

    it 'matches Ruby version with 1 name' do
      names = ['Smith']
      ruby_result = Utilities::Strings.authorship_sentence(names)
      sql_result = conn.select_value("SELECT pg_temp.authorship_sentence(ARRAY['Smith'])")
      expect(sql_result).to eq(ruby_result)
      expect(sql_result).to eq('Smith')
    end

    it 'matches Ruby version with 2 names' do
      names = ['Smith', 'Jones']
      ruby_result = Utilities::Strings.authorship_sentence(names)
      sql_result = conn.select_value("SELECT pg_temp.authorship_sentence(ARRAY['Smith', 'Jones'])")
      expect(sql_result).to eq(ruby_result)
      expect(sql_result).to eq('Smith & Jones')
    end

    it 'matches Ruby version with 3 names' do
      names = ['Smith', 'Jones', 'Brown']
      ruby_result = Utilities::Strings.authorship_sentence(names)
      sql_result = conn.select_value("SELECT pg_temp.authorship_sentence(ARRAY['Smith', 'Jones', 'Brown'])")
      expect(sql_result).to eq(ruby_result)
      expect(sql_result).to eq('Smith, Jones & Brown')
    end

    it 'matches Ruby version with 4+ names' do
      names = ['Smith', 'Jones', 'Brown', 'Davis']
      ruby_result = Utilities::Strings.authorship_sentence(names)
      sql_result = conn.select_value("SELECT pg_temp.authorship_sentence(ARRAY['Smith', 'Jones', 'Brown', 'Davis'])")
      expect(sql_result).to eq(ruby_result)
      expect(sql_result).to eq('Smith, Jones, Brown & Davis')
    end

    it 'matches Ruby version with empty array' do
      names = []
      ruby_result = Utilities::Strings.authorship_sentence(names)
      sql_result = conn.select_value("SELECT pg_temp.authorship_sentence(ARRAY[]::text[])")
      expect(sql_result).to eq(ruby_result)
      expect(sql_result).to be_nil
    end
  end
end
