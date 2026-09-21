# lib/autoselect/asserted_environment/levels/smart.rb
module Autoselect
  module AssertedEnvironment
    module Levels
      # Delegates to Queries::AssertedEnvironment::Autocomplete - broader than
      # Fast's uri_label prefix-only match: contains-matching on uri_label,
      # exact/ends-with on uri, and matching through to the asserted object's
      # own label (CollectingEvent#cached, Otu#name/taxon_name, Gazetteer#name).
      class Smart < ::Autoselect::Levels::Smart

        def query_class
          ::Queries::AssertedEnvironment::Autocomplete
        end

      end
    end
  end
end
