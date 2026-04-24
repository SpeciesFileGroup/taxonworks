# lib/autoselect/otu/levels/catalogue_of_life.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the TaxonName CatalogueOfLife level and wraps results with
      # hook metadata indicating they should trigger a TaxonName-creation flow.
      class CatalogueOfLife < ::Autoselect::Level

        def key
          :catalogue_of_life
        end

        def label
          'Catalogue of Life'
        end

        def description
          'Search the Catalogue of Life for matching names. Returns external results that can be used to create a new OTU linked to a TaxonName.'
        end

        def external?
          true
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @return [Array<OpenStruct>] pseudo-records with _col_extension including hook metadata
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          taxon_name_level = ::Autoselect::TaxonName::Levels::CatalogueOfLife.new
          col_records = taxon_name_level.call(term:, operator:, project_id:, user_id:)

          col_records.map do |record|
            extension = record._col_extension.merge(
              hook: { model: 'TaxonName', level: 'catalogue_of_life', yields: 'taxon_name_id' }
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
