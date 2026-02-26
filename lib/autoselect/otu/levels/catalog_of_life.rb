# lib/autoselect/otu/levels/catalog_of_life.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the TaxonName CatalogOfLife level and wraps results with
      # hook metadata indicating they should trigger a TaxonName-creation flow.
      class CatalogOfLife < ::Autoselect::Level

        def key
          :catalog_of_life
        end

        def label
          'Catalog of Life'
        end

        def description
          'Search the Catalog of Life for matching names. Returns external results that can be used to create a new OTU linked to a TaxonName.'
        end

        def external?
          true
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @return [Array<OpenStruct>] pseudo-records with _col_extension including hook metadata
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          taxon_name_level = ::Autoselect::TaxonName::Levels::CatalogOfLife.new
          col_records = taxon_name_level.call(term:, operator:, project_id:, user_id:)

          col_records.map do |record|
            extension = record._col_extension.merge(
              hook: { model: 'TaxonName', level: 'catalog_of_life', yields: 'taxon_name_id' }
            )

            OpenStruct.new(
              id: nil,
              name: record.cached,
              taxon_name: nil,
              _col_extension: extension
            )
          end
        end

      end
    end
  end
end
