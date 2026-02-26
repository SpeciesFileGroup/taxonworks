# lib/autoselect/taxon_name/levels/smart.rb
module Autoselect
  module TaxonName
    module Levels
      # Delegates to the existing TaxonName autocomplete query.
      # Full fuzzy/similarity matching using GIN indexes and trigrams.
      class Smart < ::Autoselect::Levels::Smart

        def query_class
          ::Queries::TaxonName::Autocomplete
        end

      end
    end
  end
end
