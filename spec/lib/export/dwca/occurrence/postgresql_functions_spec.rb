require 'rails_helper'

RSpec.describe Export::Dwca::Occurrence::PostgresqlFunctions, type: :model do
  # Create a minimal test class to include the module
  let(:test_class) do
    Class.new do
      include Export::Dwca::Occurrence::PostgresqlFunctions
    end
  end
  let(:instance) { test_class.new }

  describe '#create_api_link_for_model_id_function' do
    before(:all) do
      # Create the function once for all tests
      conn = ActiveRecord::Base.connection
      test_obj = Class.new do
        include Export::Dwca::Occurrence::PostgresqlFunctions
      end.new
      test_obj.create_api_link_for_model_id_function
    end

    after(:all) do
      conn = ActiveRecord::Base.connection
      conn.execute('DROP FUNCTION IF EXISTS pg_temp.api_link_for_model_id(text, integer)')
    end

    context 'SQL function matches Ruby implementation' do
      let(:test_cases) do
        [
          { model: 'CollectionObject', id: 123 },
          { model: 'FieldOccurrence', id: 456 },
          { model: 'AssertedDistribution', id: 789 }
        ]
      end

      specify 'produces same results for all dwc_occurrence model types' do
        conn = ActiveRecord::Base.connection

        test_cases.each do |test_case|
          model_type = test_case[:model]
          model_id = test_case[:id]

          # Get Ruby version result
          ruby_result = Shared::Api.api_link_for_model_id(model_type.constantize, model_id)

          # Get SQL version result
          sql_result = conn.select_value(
            "SELECT pg_temp.api_link_for_model_id(#{conn.quote(model_type)}, #{model_id})"
          )

          expect(sql_result).to eq(ruby_result),
            "Expected SQL function to return #{ruby_result.inspect} for #{model_type}(#{model_id}), but got #{sql_result.inspect}"
        end
      end

      specify 'returns NULL for NULL inputs' do
        conn = ActiveRecord::Base.connection

        expect(conn.select_value("SELECT pg_temp.api_link_for_model_id(NULL, 123)")).to be_nil

        expect(conn.select_value("SELECT pg_temp.api_link_for_model_id('CollectionObject', NULL)")).to be_nil

        expect(conn.select_value("SELECT pg_temp.api_link_for_model_id(NULL, NULL)")).to be_nil
      end
    end
  end

  describe '#create_image_url_functions' do
    before(:all) do
      conn = ActiveRecord::Base.connection
      test_obj = Class.new do
        include Export::Dwca::Occurrence::PostgresqlFunctions
      end.new
      test_obj.create_image_url_functions
    end

    after(:all) do
      conn = ActiveRecord::Base.connection
      conn.execute('DROP FUNCTION IF EXISTS pg_temp.image_file_url(text, text)')
      conn.execute('DROP FUNCTION IF EXISTS pg_temp.image_metadata_url(integer, text)')
      conn.execute('DROP FUNCTION IF EXISTS pg_temp.sled_image_file_url(text, text, text)')
    end

    context 'SQL functions match Ruby implementations' do
      let(:test_fingerprint) { 'abc123def456' }
      let(:test_token) { 'test_api_token_xyz' }
      let(:test_image_id) { 789 }
      let(:test_svg_view_box) { '10 20 100 150' }

      specify 'image_file_url produces same result as Shared::Api.image_file_long_url' do
        conn = ActiveRecord::Base.connection

        # Get Ruby version result
        ruby_result = Shared::Api.image_file_long_url(test_fingerprint, test_token)

        # Get SQL version result
        sql_result = conn.select_value(
          "SELECT pg_temp.image_file_url(#{conn.quote(test_fingerprint)}, #{conn.quote(test_token)})"
        )

        expect(sql_result).to eq(ruby_result),
          "Expected SQL function to return #{ruby_result.inspect}, but got #{sql_result.inspect}"
      end

      specify 'image_metadata_url produces same result as Shared::Api.image_metadata_long_url' do
        conn = ActiveRecord::Base.connection

        # Get Ruby version result
        ruby_result = Shared::Api.image_metadata_long_url(test_image_id, test_token)

        # Get SQL version result
        sql_result = conn.select_value(
          "SELECT pg_temp.image_metadata_url(#{test_image_id}, #{conn.quote(test_token)})"
        )

        expect(sql_result).to eq(ruby_result),
          "Expected SQL function to return #{ruby_result.inspect}, but got #{sql_result.inspect}"
      end

      specify 'sled_image_file_url produces same result as Shared::Api.sled_image_file_long_url' do
        conn = ActiveRecord::Base.connection

        # Get Ruby version result
        ruby_result = Shared::Api.sled_image_file_long_url(test_fingerprint, test_svg_view_box, test_token)

        # Get SQL version result
        sql_result = conn.select_value(
          "SELECT pg_temp.sled_image_file_url(#{conn.quote(test_fingerprint)}, #{conn.quote(test_svg_view_box)}, #{conn.quote(test_token)})"
        )

        expect(sql_result).to eq(ruby_result),
          "Expected SQL function to return #{ruby_result.inspect}, but got #{sql_result.inspect}"
      end

      specify 'sled_image_file_url correctly parses svg_view_box coordinates' do
        conn = ActiveRecord::Base.connection

        # Test with different svg_view_box values
        test_cases = [
          '0 0 50 50',
          '10 20 100 150',
          '100 200 300 400'
        ]

        test_cases.each do |svg_view_box|
          ruby_result = Shared::Api.sled_image_file_long_url(test_fingerprint, svg_view_box, test_token)
          sql_result = conn.select_value(
            "SELECT pg_temp.sled_image_file_url(#{conn.quote(test_fingerprint)}, #{conn.quote(svg_view_box)}, #{conn.quote(test_token)})"
          )

          expect(sql_result).to eq(ruby_result),
            "Expected SQL function to return #{ruby_result.inspect} for svg_view_box #{svg_view_box.inspect}, but got #{sql_result.inspect}"
        end
      end

      specify 'sled_image_file_url handles decimal svg_view_box values' do
        conn = ActiveRecord::Base.connection
        svg_view_box = '0 0 1263.0 1263.0'
        ruby_result = Shared::Api.sled_image_file_long_url(test_fingerprint, svg_view_box, test_token)

        sql_result = conn.select_value(
          "SELECT pg_temp.sled_image_file_url(#{conn.quote(test_fingerprint)}, #{conn.quote(svg_view_box)}, #{conn.quote(test_token)})"
        )

        expect(sql_result).to eq(ruby_result)
      end

    end
  end

  describe 'dwc_occurrence model types' do
    specify 'only expected model types can be dwc_occurrence_object_type' do
      actual_models = ApplicationRecord.descendants.select do |model|
        model.included_modules.include?(Shared::IsDwcOccurrence) &&
        model.base_class == model
      end.map(&:name).sort

      expected_models = ['AssertedDistribution', 'CollectionObject', 'FieldOccurrence'].sort

      expect(actual_models).to match_array(expected_models),
        "Found unexpected DwcOccurrence base models: #{actual_models}. " \
        "If new models were added, update Export::Dwca::Occurrence::PostgresqlFunctions#create_api_link_for_model_id_function"
    end
  end
end
