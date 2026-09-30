# lib/autoselect/otu/levels/catalogue_of_life.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the TaxonName CatalogueOfLife level and wraps results with
      # hook metadata indicating they should trigger a TaxonName-creation flow.
      # A result whose TaxonName already has an Otu carries it in the hook (see
      # Autoselect::Otu::ColExistingOtu), so that Otu is reused, not duplicated.
      class CatalogueOfLife < ::Autoselect::Level
        include ::Autoselect::Levels::ColRecordInfo

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

        def record_label(record)
          record.name.to_s
        end

        def record_label_html(record, term = nil)
          record.name.to_s
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences; falls back to default when nil
        # @return [Array<OpenStruct>] pseudo-records with _col_extension including hook metadata
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          taxon_name_level = ::Autoselect::TaxonName::Levels::CatalogueOfLife.new
          col_records = taxon_name_level.call(term:, operator:, project_id:, user_id:, dataset_id:)

          existing_otus = ::Autoselect::Otu::ColExistingOtu.for_taxon_names(
            col_records.map { |record| record._col_extension[:target_taxonworks_id] },
            project_id:
          )

          col_records.map do |record|
            existing_otu =
              existing_otus[record._col_extension[:target_taxonworks_id]]
            extension = record._col_extension.merge(
              hook: ::Autoselect::Otu::ColExistingOtu.hook(existing_otu)
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
