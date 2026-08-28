# lib/autoselect/taxon_name/levels/col_valid_name.rb
module Autoselect
  module TaxonName
    module Levels
      # Resolves a term through Catalogue of Life synonymy to its accepted name, then
      # reuses Levels::CatalogueOfLife#build_pseudo_record for the actual
      # alignment/extension data and existing-TaxonName check — feeding it the accepted
      # nameusage hash that resolve_accepted_name already returned, so no second CoL
      # search (and no per-result classification fetch) is needed.
      #
      # Returns at most one pseudo-record — the resolved valid name — flagged with
      # `resolved_from:` so callers (and the confirmation UI) can show this is the
      # accepted name for what was typed, not a literal search match.
      #
      # Also reached indirectly via Autoselect::Otu::Levels::ColValidName's
      # delegation (which renders its own record_info/label instead of this level's).
      class ColValidName < ::Autoselect::Level
        include ::Autoselect::Levels::ColRecordInfo

        def key
          :col_valid_name
        end

        def label
          'CoL Valid Name'
        end

        def description
          'Resolve the term through Catalogue of Life synonymy to its accepted name.'
        end

        def external?
          true
        end

        # Opt-in only — fast/smart/catalogue_of_life cover the common cases; this
        # stays present-but-unchecked in the preferences modal until a user opts in.
        def is_default
          false
        end

        def record_label(record)
          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new.record_label(record)
        end

        def record_label_html(record)
          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new.record_label_html(record)
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences; falls back to default when nil
        # @return [Array<OpenStruct>] at most one pseudo-record, for the resolved valid name
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          resolved = ::Vendor::Colrapi.resolve_accepted_name(term, dataset_id:)
          return [] if resolved.nil? || resolved[:valid_name].blank? || resolved[:valid_col_result].blank?

          target = ::Autoselect::TaxonName::Levels::CatalogueOfLife.new.build_pseudo_record(
            resolved[:valid_col_result], project_id:, dataset_id: resolved[:dataset_id]
          )
          extension = target._col_extension.merge(resolved_from: term)

          [OpenStruct.new(
            id: nil,
            cached: target.cached,
            name: target.cached,
            rank_string: nil,
            cached_valid_taxon_name_id: nil,
            _col_extension: extension
          )]
        end

      end
    end
  end
end
