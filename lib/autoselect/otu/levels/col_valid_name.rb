# lib/autoselect/otu/levels/col_valid_name.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the TaxonName ColValidName level (which resolves the term through
      # Catalogue of Life synonymy to its accepted name) — e.g. a label was transcribed
      # with an outdated/synonymized name, and the curator wants the OTU CoL now
      # recognizes.
      #
      # Wraps TaxonName::ColValidName#resolve_target's pseudo-record with the OTU
      # creation hook — flagged with `resolved_from:` so the confirmation UI can
      # make clear this is the accepted name for what was typed, not a literal
      # match on it. The one thing with no TaxonName-level equivalent: the hook
      # carries the resolved name's existing Otu, if any (see
      # Autoselect::Otu::ColExistingOtu) — Smart already searched the raw
      # (pre-resolution) term and came up empty, but hasn't tried the name CoL
      # actually accepts.
      #
      # Always the last level in Autoselect::Otu::Autoselect#levels, but `is_default`
      # false (see Autoselect::Level#is_default) — it stays present-but-unchecked in
      # the preferences modal for every OTU field until a user opts in, since
      # fast/smart/catalogue_of_life cover the common cases on their own.
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

        def record_label_html(record)
          return record.name.to_s if record.respond_to?(:_col_extension)
          super
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences; falls back to default when nil
        # @return [Array<OpenStruct>] a single CoL result for the resolved valid
        #   name, whose hook carries the name's existing Otu, if any
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          # The raw resolved pseudo-record, which carries the CoL alignment data
          # the confirmation modal shows.
          target = ::Autoselect::TaxonName::Levels::ColValidName.new.resolve_target(
            term, project_id:, dataset_id:
          )
          return [] if target.nil?

          existing_otu = ::Autoselect::Otu::ColExistingOtu.for_taxon_name(
            target._col_extension[:target_taxonworks_id], project_id:
          )

          extension = target._col_extension.merge(
            resolved_from: term,
            hook: ::Autoselect::Otu::ColExistingOtu.hook(existing_otu)
          )
          [OpenStruct.new(id: nil, name: target.cached, taxon_name: nil, _col_extension: extension)]
        end

      end
    end
  end
end
