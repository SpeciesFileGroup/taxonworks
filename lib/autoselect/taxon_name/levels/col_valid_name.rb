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
      # Returns at most one record — the resolved valid name. When that name is
      # already a TaxonName in the project the real record is returned (selecting it
      # just picks that name); otherwise a CoL creation-offer pseudo-record, flagged
      # with `resolved_from:` so the confirmation UI can show it's the accepted name
      # for what was typed, not a literal search match.
      #
      # Autoselect::Otu::Levels::ColValidName reuses #resolve_target directly — it
      # makes its own existing-Otu decision and always needs the raw pseudo-record.
      class ColValidName < ::Autoselect::Level
        # Source mark + "valid name for X" note, shared with the Otu-level equivalent.
        include ::Autoselect::Levels::ColResolvedName

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

        # Searches with the CoL dataset chosen for the catalogue_of_life level.
        def options_level
          :catalogue_of_life
        end

        # Opt-in only — fast/smart/catalogue_of_life cover the common cases; this
        # stays present-but-unchecked in the preferences modal until a user opts in.
        def is_default
          false
        end

        def record_label(record)
          return super if record.is_a?(::TaxonName)
          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new.record_label(record)
        end

        def record_label_html(record)
          return super if record.is_a?(::TaxonName)
          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new.record_label_html(record)
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences; falls back to default when nil
        # @return [Array<::TaxonName>, Array<OpenStruct>] the existing TaxonName for the
        #   resolved valid name, or a single creation-offer pseudo-record
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          target = resolve_target(term, project_id:, dataset_id:)
          return [] if target.nil?

          if (tw_id = target._col_extension[:target_taxonworks_id]).present? &&
             (existing = ::TaxonName.where(project_id:).find_by(id: tw_id))
            existing.define_singleton_method(:_col_resolution) { { input: term, valid_name: existing.cached } }
            return [existing]
          end

          [OpenStruct.new(
            id: nil,
            cached: target.cached,
            name: target.cached,
            rank_string: nil,
            cached_valid_taxon_name_id: nil,
            _col_extension: target._col_extension.merge(resolved_from: term)
          )]
        end

        # The raw resolved pseudo-record — the accepted name's CoL alignment/extension
        # data plus build_pseudo_record's existing-TaxonName check — before #call's
        # real-record-vs-creation-offer decision. nil when CoL resolves nothing usable.
        #
        # @return [OpenStruct, nil]
        def resolve_target(term, project_id: nil, dataset_id: nil)
          resolved = ::Vendor::Colrapi.resolve_accepted_name(term, dataset_id:)
          return nil if resolved.nil? || resolved[:valid_name].blank? || resolved[:valid_col_result].blank?

          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new.build_pseudo_record(
            resolved[:valid_col_result], project_id:, dataset_id: resolved[:dataset_id]
          )
        end

      end
    end
  end
end
