require 'rails_helper'

# Spec to verify that Ruby attribution methods match their SQL counterparts
# in Export::Dwca::Data
RSpec.describe Shared::Dwc::MediaExtensions, type: :model do
  let(:conn) { ActiveRecord::Base.connection }
  let(:project) { FactoryBot.create(:valid_project) }
  let(:user) { FactoryBot.create(:valid_user) }

  # Helper to create test data in the right project/user context
  around(:each) do |example|
    Current.user_id = user.id
    Current.project_id = project.id
    example.run
    Current.user_id = nil
    Current.project_id = nil
  end

  shared_examples 'attribution method consistency' do |media_class, factory_name|
    let(:media_type) { media_class.name.downcase }

    context "for #{media_class.name}" do
      describe '#dwc_media_owner' do
        it 'matches SQL when attribution has person owners' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person1 = FactoryBot.create(:valid_person)
          person2 = FactoryBot.create(:valid_person)
          FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person1, position: 1)
          FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person2, position: 2)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_owner

          # SQL result - simulate the export query
          sql = build_attribution_owners_sql(media.id, media_class.table_name)
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{person1.cached} | #{person2.cached}")
        end

        it 'matches SQL when attribution has organization owners' do
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
          sql = build_attribution_owners_sql(media.id, media_class.table_name)
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{org1.name} | #{org2.name}")
        end

        it 'matches SQL when attribution has mixed person and organization owners' do
          media = FactoryBot.create(factory_name)
          attribution = FactoryBot.create(:valid_attribution, attribution_object: media)
          person = FactoryBot.create(:valid_person)
          org = FactoryBot.create(:valid_organization)
          AttributionOwner.create!(role_object: attribution, person: person, position: 1)
          AttributionOwner.create!(role_object: attribution, organization: org, position: 2)

          # Ruby result
          media.reload
          ruby_result = media.dwc_media_owner

          # SQL result
          sql = build_attribution_owners_sql(media.id, media_class.table_name)
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{person.cached} | #{org.name}")
        end
      end

      describe '#dwc_media_dc_creator' do
        it 'matches SQL when attribution has person creators' do
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
          sql = build_attribution_creators_sql(media.id, media_class.table_name)
          sql_result = conn.select_value(sql)

          expect(sql_result).to eq(ruby_result)
          expect(sql_result).to eq("#{person1.cached} | #{person2.cached}")
        end
      end
    end
  end

  # Helper methods to build SQL matching the export queries
  def build_attribution_owners_sql(media_id, table_name)
    delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
    <<~SQL
      SELECT owners.names
      FROM #{table_name}
      LEFT JOIN attributions ON attributions.attribution_object_id = #{table_name}.id
                            AND attributions.attribution_object_type = '#{table_name.classify}'
      LEFT JOIN LATERAL (
        SELECT STRING_AGG(COALESCE(people.cached, organizations.name), '#{delimiter}' ORDER BY roles.position) AS names
        FROM roles
        LEFT JOIN people ON people.id = roles.person_id
        LEFT JOIN organizations ON organizations.id = roles.organization_id
        WHERE roles.role_object_id = attributions.id
          AND roles.role_object_type = 'Attribution'
          AND roles.type = 'AttributionOwner'
      ) owners ON true
      WHERE #{table_name}.id = #{media_id}
    SQL
  end

  def build_attribution_creators_sql(media_id, table_name)
    delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
    <<~SQL
      SELECT creators.names
      FROM #{table_name}
      LEFT JOIN attributions ON attributions.attribution_object_id = #{table_name}.id
                            AND attributions.attribution_object_type = '#{table_name.classify}'
      LEFT JOIN LATERAL (
        SELECT STRING_AGG(people.cached, '#{delimiter}' ORDER BY roles.position) AS names
        FROM roles
        JOIN people ON people.id = roles.person_id
        WHERE roles.role_object_id = attributions.id
          AND roles.role_object_type = 'Attribution'
          AND roles.type = 'AttributionCreator'
      ) creators ON true
      WHERE #{table_name}.id = #{media_id}
    SQL
  end

  include_examples 'attribution method consistency', Image, :valid_image
  include_examples 'attribution method consistency', Sound, :valid_sound
end
