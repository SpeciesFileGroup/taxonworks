# lib/autoselect/otu/levels/col_valid_name.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the TaxonName ColValidName level (which resolves the term through
      # Catalogue of Life synonymy to its accepted name) — e.g. a label was transcribed
      # with an outdated/synonymized name, and the curator wants the OTU CoL now
      # recognizes.
      #
      # The one thing with no TaxonName-level equivalent: before offering to create
      # anything, checks whether an Otu already carries the resolved name — Smart
      # already searched the raw (pre-resolution) term and came up empty, but hasn't
      # tried the name CoL actually accepts. When found, returns those real Otu
      # records directly; otherwise wraps TaxonName::ColValidName#resolve_target's
      # pseudo-record with the OTU creation hook — flagged with `resolved_from:` so
      # the confirmation UI can make clear this is the accepted name for what was
      # typed, not a literal match on it.
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
        # @return [Array<Otu>, Array<OpenStruct>] real Otu matches, or a single CoL
        #   creation-offer pseudo-record when the resolved name isn't in the project yet
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          # The raw resolved pseudo-record — not TaxonName::ColValidName#call, which
          # would hand back an existing TaxonName once the accepted name is in the
          # project; the OTU offer needs the CoL alignment data regardless.
          target = ::Autoselect::TaxonName::Levels::ColValidName.new.resolve_target(
            term, project_id:, dataset_id:
          )
          return [] if target.nil?

          valid_name = target.cached

          matches = ::Queries::Otu::Autocomplete.new(valid_name, project_id:, exact: true).autocomplete
          return matches.each { |otu| attach_resolution(otu, term, valid_name) } if matches.any?

          extension = target._col_extension.merge(
            resolved_from: term,
            hook: { create_url: '/otus/autoselect_col_create', yields: 'otu_id' }
          )
          [OpenStruct.new(id: nil, name: valid_name, taxon_name: nil, _col_extension: extension)]
        end

        private

        # record_info / record_info_html come from ::Autoselect::Levels::ColResolvedName;
        # #existing_match? there keys off the `_col_resolution` this attaches to real
        # Otu matches, so a match shows TW_ICON and a creation offer COL_ICON.
        def attach_resolution(otu, term, valid_name)
          otu.define_singleton_method(:_col_resolution) { { input: term, valid_name: } }
          otu
        end

      end
    end
  end
end
