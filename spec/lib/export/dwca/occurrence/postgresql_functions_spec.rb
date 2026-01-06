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
      # Clean up the function after all tests
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

        # NULL model_type
        expect(conn.select_value("SELECT pg_temp.api_link_for_model_id(NULL, 123)")).to be_nil

        # NULL model_id
        expect(conn.select_value("SELECT pg_temp.api_link_for_model_id('CollectionObject', NULL)")).to be_nil

        # Both NULL
        expect(conn.select_value("SELECT pg_temp.api_link_for_model_id(NULL, NULL)")).to be_nil
      end
    end
  end

  describe 'dwc_occurrence model types' do
    specify 'only expected model types can be dwc_occurrence_object_type' do
      # This spec ensures the SQL function handles all possible dwc_occurrence models.
      # If a new base model is added that includes Shared::IsDwcOccurrence, this spec will fail
      # and remind us to update the create_api_link_for_model_id_function.

      # Find all base class models that include Shared::IsDwcOccurrence
      # (excluding subclasses like CollectionObject::BiologicalCollectionObject)
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
