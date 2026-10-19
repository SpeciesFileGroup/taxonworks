# lib/autoselect/otu/levels/col_valid_name.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the TaxonName ColValidName level (which resolves the term
      # through Catalogue of Life synonymy to its accepted name) — e.g. a label
      # was transcribed with an outdated/synonymized name, and the curator wants
      # the OTU CoL now recognizes.
      #
      # Wraps TaxonName::ColValidName#resolve_target's pseudo-record (flagged
      # with `resolved_from:`) with the OTU creation hook. The one thing with
      # no TaxonName-level equivalent: the hook carries the resolved name's
      # existing Otu, if any (see Autoselect::Otu::ColExistingOtu).
      class ColValidName < ::Autoselect::Level
        # Source mark + "valid name for X" note rendering, shared with the
        # TaxonName-level equivalent this delegates to.
        include ::Autoselect::Levels::ColResolvedName

        def key
          :col_valid_name
        end

        def label
          'CoL Valid Name'
        end

        def description
          'Resolve the term through Catalogue of Life synonymy to its accepted name, then match an existing OTU by that name — offering to create it if none exists yet.'
        end

        def external?
          true
        end

        # Searches with the CoL dataset chosen for the catalogue_of_life level.
        def options_level
          :catalogue_of_life
        end

        # Opt-in only — see the class comment above.
        def is_default
          false
        end

        def record_label(record)
          return record.name.to_s if record.respond_to?(:_col_extension)
          super
        end

        def record_label_html(record, term = nil)
          if record.respond_to?(:_col_extension)
            return ERB::Util.html_escape(record.name.to_s)
          end
          super
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences;
        #   falls back to default when nil
        # @return [Array<OpenStruct>] a single CoL result for the resolved valid
        #   name, whose hook carries the name's existing Otu, if any
        def call(
          term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil,
          **_kwargs
        )
          target = ::Autoselect::TaxonName::Levels::ColValidName.new
            .resolve_target(term, project_id:, dataset_id:)
          return [] if target.nil?

          ::Autoselect::Otu::ColExistingOtu.wrap([target], project_id:)
        end

      end
    end
  end
end
