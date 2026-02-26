# lib/autoselect/taxon_name/levels/catalog_of_life.rb
module Autoselect
  module TaxonName
    module Levels
      class CatalogOfLife < ::Autoselect::Level

        def key
          :catalog_of_life
        end

        def label
          'Catalog of Life'
        end

        def description
          'Search the Catalog of Life for matching names. Returns external results with alignment data for confirmation.'
        end

        def external?
          true
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @return [Array<OpenStruct>] pseudo-records compatible with TaxonName autoselect format_results
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          raw = ::Vendor::Colrapi.search(term)
          results = raw['result'] || []
          return [] if results.empty?

          results.map do |col_result|
            col_name   = col_result.dig('usage', 'name', 'scientificName') ||
                         col_result.dig('name', 'scientificName') ||
                         col_result['scientificName']
            col_status = col_result.dig('usage', 'status') || col_result['status']
            col_key    = col_result.dig('usage', 'id') || col_result['id']
            extension  = ::Vendor::Colrapi.build_extension(col_result, project_id)

            OpenStruct.new(
              id: nil,
              cached: col_name,
              name: col_name,
              rank_string: nil,
              cached_valid_taxon_name_id: nil,
              _col_extension: extension.merge(col_status:, col_key:)
            )
          end
        end

      end
    end
  end
end
