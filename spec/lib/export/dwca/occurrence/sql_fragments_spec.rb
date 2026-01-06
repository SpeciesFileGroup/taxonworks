# spec/models/export/dwca/occurrence/sql_fragments_spec.rb
require 'rails_helper'

RSpec.describe Export::Dwca::Occurrence::SqlFragments, type: :model do
  include Export::Dwca::Occurrence::PostgresqlFunctions

  let(:conn) { ActiveRecord::Base.connection }

  # Minimal host so we can call the fragment instance method.
  let(:fragment_host_class) do
    Class.new do
      include Export::Dwca::Occurrence::SqlFragments
    end
  end

  let(:fragment_host) { fragment_host_class.new }

  before do
    create_authorship_sentence_function
  end

  # Create a *limited* temp table in the same pattern as
  # create_media_attribution_temp_table_for_class, but only the columns needed
  # for copyright label.
  def create_temp_media_attr_table_for_images(image_ids:, temp_ids_table:, temp_table_name:)
    return if image_ids.empty?

    conn.execute("DROP TABLE IF EXISTS #{temp_ids_table}")
    conn.execute(<<~SQL)
      CREATE TEMP TABLE #{temp_ids_table} (image_id integer PRIMARY KEY)
    SQL

    values = image_ids.map { |id| "(#{id.to_i})" }.join(', ')
    conn.execute("INSERT INTO #{temp_ids_table} (image_id) VALUES #{values}")

    conn.execute("DROP TABLE IF EXISTS #{temp_table_name}")
    conn.execute(<<~SQL)
      CREATE TEMP TABLE #{temp_table_name} AS
      SELECT
        images.id AS image_id,
        attributions.copyright_year,
        copyright_holders.names_array AS copyright_holder_names_array
      FROM images
      LEFT JOIN attributions ON attributions.attribution_object_id = images.id
        AND attributions.attribution_object_type = 'Image'
      #{Image.dwc_media_copyright_holders_sql}
      JOIN #{temp_ids_table} ids ON ids.image_id = images.id
    SQL

    conn.execute("CREATE INDEX ON #{temp_table_name}(image_id)")
  end

  describe '#copyright_label_sql_from_temp' do
    let(:temp_ids_table)  { 'temp_image_ids' }
    let(:temp_table_name) { 'temp_image_attributions' }

    let(:sql_fragment) do
      fragment_host.copyright_label_sql_from_temp(temp_table_name)
    end

    after do
      conn.execute("DROP TABLE IF EXISTS #{temp_table_name}")
      conn.execute("DROP TABLE IF EXISTS #{temp_ids_table}")
    end

    def sql_value_for(image_id)
      conn.select_value(<<~SQL)
        SELECT #{sql_fragment} AS copyright_label
        FROM #{temp_table_name}
        WHERE image_id = #{image_id.to_i}
      SQL
    end

    context 'when Image has AttributionCopyrightHolder roles' do
      specify 'matches Ruby dwc_media_credit with year + 1 holder' do
        image = FactoryBot.create(:valid_image)
        person = FactoryBot.create(:valid_person, last_name: 'Smith')

        attribution = FactoryBot.create(:valid_attribution,
          attribution_object: image,
          copyright_year: 2017,
          copyright_holder_roles_attributes: [{person:}]
        )

        image.reload
        ruby_result = image.dwc_media_credit

        create_temp_media_attr_table_for_images(
          image_ids: [image.id],
          temp_ids_table: temp_ids_table,
          temp_table_name: temp_table_name
        )
        sql_result = sql_value_for(image.id)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq('©2017 Smith')
      end

      specify 'matches Ruby dwc_media_credit with year + multiple holders (sentence formatting)' do
        image = FactoryBot.create(:valid_image)
        p1 = FactoryBot.create(:person, last_name: 'Smith')
        p2 = FactoryBot.create(:person, last_name: 'Jones')
        p3 = FactoryBot.create(:person, last_name: 'Brown')

        attribution = FactoryBot.create(:valid_attribution,
          attribution_object: image,
          copyright_year: 2017,
          copyright_holder_roles_attributes: [{person: p1}, {person: p2}, {person: p3}]
        )

        image.reload
        ruby_result = image.dwc_media_credit

        create_temp_media_attr_table_for_images(
          image_ids: [image.id],
          temp_ids_table: temp_ids_table,
          temp_table_name: temp_table_name
        )
        sql_result = sql_value_for(image.id)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq('©2017 Smith, Jones & Brown')
      end

      specify 'matches Ruby dwc_media_credit with holders but no year' do
        image = FactoryBot.create(:valid_image)
        org = FactoryBot.create(:organization, name: 'Museum of Bugs')

        attribution = FactoryBot.create(:valid_attribution,
          attribution_object: image,
          copyright_year: nil,
          copyright_holder_roles_attributes: [{organization: org}]
        )

        image.reload
        ruby_result = image.dwc_media_credit

        create_temp_media_attr_table_for_images(
          image_ids: [image.id],
          temp_ids_table: temp_ids_table,
          temp_table_name: temp_table_name
        )
        sql_result = sql_value_for(image.id)

        expect(sql_result).to eq(ruby_result)
        expect(sql_result).to eq('©Museum of Bugs')
      end
    end

    context 'when Image has no AttributionCopyrightHolder roles' do
      specify 'returns nil even if year is present (matches Image dwc_media_credit semantics)' do
        image = FactoryBot.create(:valid_image)
        FactoryBot.create(:valid_attribution,
          attribution_object: image,
          copyright_year: 2017
        )

        image.reload
        ruby_result = image.dwc_media_credit
        expect(ruby_result).to be_nil

        create_temp_media_attr_table_for_images(
          image_ids: [image.id],
          temp_ids_table: temp_ids_table,
          temp_table_name: temp_table_name
        )
        sql_result = sql_value_for(image.id)

        expect(sql_result).to be_nil
      end

      specify 'returns nil when there is no attribution row at all' do
        image = FactoryBot.create(:valid_image)

        image.reload
        ruby_result = image.dwc_media_credit
        expect(ruby_result).to be_nil

        create_temp_media_attr_table_for_images(
          image_ids: [image.id],
          temp_ids_table: temp_ids_table,
          temp_table_name: temp_table_name
        )
        sql_result = sql_value_for(image.id)

        expect(sql_result).to be_nil
      end
    end
  end
end
