require 'rails_helper'

# Spec to verify that the attribution temp tables created for media export
# contain the correct pre-aggregated data
RSpec.describe Export::Dwca::Data, type: :model do
  let(:project) { FactoryBot.create(:valid_project) }
  let(:user) { FactoryBot.create(:valid_user) }
  let(:conn) { ActiveRecord::Base.connection }

  before(:each) do
    Current.user_id = user.id
    Current.project_id = project.id
  end

  after(:each) do
    Current.user_id = nil
    Current.project_id = nil
  end

  describe '#create_media_attribution_temp_tables' do
    let(:export_instance) do
      Export::Dwca::Data.new(
        core_scope: DwcOccurrence.where('1=0'),
        extension_scopes: {
          media: {
            collection_objects: CollectionObject.where('1=0'),
            field_occurrences: FieldOccurrence.where('1=0')
          }
        }
      )
    end

    context 'for images' do
      it 'creates temp table with correct attribution data for owners' do
        image = FactoryBot.create(:valid_image)
        attribution = FactoryBot.create(:valid_attribution, attribution_object: image)
        person1 = FactoryBot.create(:valid_person)
        person2 = FactoryBot.create(:valid_person)
        FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person1, position: 1)
        FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person2, position: 2)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [])

        result = conn.select_one("SELECT * FROM temp_image_attributions WHERE image_id = #{image.id}")
        expect(result['owner_names']).to eq("#{person1.cached} | #{person2.cached}")
      end

      it 'creates temp table with correct attribution data for creators' do
        image = FactoryBot.create(:valid_image)
        attribution = FactoryBot.create(:valid_attribution, attribution_object: image)
        person1 = FactoryBot.create(:valid_person)
        person2 = FactoryBot.create(:valid_person)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person1, position: 1)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person2, position: 2)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [])

        result = conn.select_one("SELECT * FROM temp_image_attributions WHERE image_id = #{image.id}")
        expect(result['creator_names']).to eq("#{person1.cached} | #{person2.cached}")
      end

      it 'creates temp table with correct attribution data for license' do
        image = FactoryBot.create(:valid_image)
        license_key = CREATIVE_COMMONS_LICENSES.keys.first
        attribution = FactoryBot.create(:valid_attribution, attribution_object: image, license: license_key)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [])

        result = conn.select_one("SELECT * FROM temp_image_attributions WHERE image_id = #{image.id}")
        expect(result['license_url']).to eq(CREATIVE_COMMONS_LICENSES[license_key][:link])
      end

      it 'creates temp table with correct attribution data for creator identifiers' do
        image = FactoryBot.create(:valid_image)
        attribution = FactoryBot.create(:valid_attribution, attribution_object: image)
        person1 = FactoryBot.create(:valid_person)
        person2 = FactoryBot.create(:valid_person)
        orcid1 = FactoryBot.create(:identifier_global_orcid, identifier_object: person1, identifier: 'http://orcid.org/0000-0002-1825-0097')
        orcid2 = FactoryBot.create(:identifier_global_orcid, identifier_object: person2, identifier: 'https://orcid.org/0000-0002-1824-6098')
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person1, position: 1)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person2, position: 2)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [])

        result = conn.select_one("SELECT * FROM temp_image_attributions WHERE image_id = #{image.id}")
        expect(result['creator_identifiers']).to eq("#{orcid1.cached} | #{orcid2.cached}")
      end

      it 'creates temp table with copyright holder names as array for sentence formatting' do
        image = FactoryBot.create(:valid_image)
        attribution = FactoryBot.create(:valid_attribution, attribution_object: image)
        person1 = FactoryBot.create(:valid_person)
        person2 = FactoryBot.create(:valid_person)
        person3 = FactoryBot.create(:valid_person)
        FactoryBot.create(:role, type: 'AttributionCopyrightHolder', role_object: attribution, person: person1, position: 1)
        FactoryBot.create(:role, type: 'AttributionCopyrightHolder', role_object: attribution, person: person2, position: 2)
        FactoryBot.create(:role, type: 'AttributionCopyrightHolder', role_object: attribution, person: person3, position: 3)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [])

        result = conn.select_one("SELECT * FROM temp_image_attributions WHERE image_id = #{image.id}")
        # Parse the PostgreSQL array format
        array_str = result['copyright_holder_names_array']
        expect(array_str).to match(/\{.*#{Regexp.escape(person1.cached)}.*,.*#{Regexp.escape(person2.cached)}.*,.*#{Regexp.escape(person3.cached)}.*\}/)
      end

      it 'handles images with no attribution data' do
        image = FactoryBot.create(:valid_image)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [])

        result = conn.select_one("SELECT * FROM temp_image_attributions WHERE image_id = #{image.id}")
        expect(result['owner_names']).to be_nil
        expect(result['creator_names']).to be_nil
        expect(result['license_url']).to be_nil
      end
    end

    context 'for sounds' do
      it 'creates temp table with correct attribution data for owners' do
        sound = FactoryBot.create(:valid_sound)
        attribution = FactoryBot.create(:valid_attribution, attribution_object: sound)
        person = FactoryBot.create(:valid_person)
        org = FactoryBot.create(:valid_organization)
        FactoryBot.create(:role, type: 'AttributionOwner', role_object: attribution, person: person, position: 1)
        AttributionOwner.create!(role_object: attribution, organization: org, position: 2)

        export_instance.send(:create_media_attribution_temp_tables, [], [sound.id])

        result = conn.select_one("SELECT * FROM temp_sound_attributions WHERE sound_id = #{sound.id}")
        expect(result['owner_names']).to eq("#{person.cached} | #{org.name}")
      end

      it 'creates temp table with correct attribution data for creators' do
        sound = FactoryBot.create(:valid_sound)
        attribution = FactoryBot.create(:valid_attribution, attribution_object: sound)
        person1 = FactoryBot.create(:valid_person)
        person2 = FactoryBot.create(:valid_person)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person1, position: 1)
        FactoryBot.create(:role, type: 'AttributionCreator', role_object: attribution, person: person2, position: 2)

        export_instance.send(:create_media_attribution_temp_tables, [], [sound.id])

        result = conn.select_one("SELECT * FROM temp_sound_attributions WHERE sound_id = #{sound.id}")
        expect(result['creator_names']).to eq("#{person1.cached} | #{person2.cached}")
      end

      it 'handles sounds with no attribution data' do
        sound = FactoryBot.create(:valid_sound)

        export_instance.send(:create_media_attribution_temp_tables, [], [sound.id])

        result = conn.select_one("SELECT * FROM temp_sound_attributions WHERE sound_id = #{sound.id}")
        expect(result['owner_names']).to be_nil
        expect(result['creator_names']).to be_nil
        expect(result['license_url']).to be_nil
      end
    end

    context 'with multiple media items' do
      it 'creates records for all provided image IDs' do
        image1 = FactoryBot.create(:valid_image)
        image2 = FactoryBot.create(:valid_image)
        image3 = FactoryBot.create(:valid_image)

        export_instance.send(:create_media_attribution_temp_tables, [image1.id, image2.id, image3.id], [])

        count = conn.select_value("SELECT COUNT(*) FROM temp_image_attributions")
        expect(count).to eq(3)
      end

      it 'creates records for both images and sounds' do
        image = FactoryBot.create(:valid_image)
        sound = FactoryBot.create(:valid_sound)

        export_instance.send(:create_media_attribution_temp_tables, [image.id], [sound.id])

        image_count = conn.select_value("SELECT COUNT(*) FROM temp_image_attributions")
        sound_count = conn.select_value("SELECT COUNT(*) FROM temp_sound_attributions")
        expect(image_count).to eq(1)
        expect(sound_count).to eq(1)
      end
    end
  end
end
