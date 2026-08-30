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
      # records directly; otherwise wraps the TaxonName-level's result with the OTU
      # creation hook, exactly as Levels::CatalogueOfLife does — flagged with
      # `resolved_from:` so the confirmation UI can make clear this is the accepted
      # name for what was typed, not a literal match on it.
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
          tn_records = ::Autoselect::TaxonName::Levels::ColValidName.new.call(
            term:, project_id:, user_id:, dataset_id:
          )
          return [] if tn_records.empty?

          resolved_record = tn_records.first
          valid_name = resolved_record.cached

          matches = ::Queries::Otu::Autocomplete.new(valid_name, project_id:, exact: true).autocomplete
          return matches.each { |otu| attach_resolution(otu, term, valid_name) } if matches.any?

          extension = resolved_record._col_extension.merge(
            hook: { create_url: '/otus/autoselect_col_create', yields: 'otu_id' }
          )
          [OpenStruct.new(id: nil, name: resolved_record.cached, taxon_name: nil, _col_extension: extension)]
        end

        private

        # record_info / record_info_html and their helpers (resolved_from,
        # valid_name_for, resolved_and_renamed?, existing_match?) come from
        # ::Autoselect::Levels::ColResolvedName. Here `existing_match?` is real —
        # #call attaches _col_resolution to Otu matches it finds via the resolved
        # name — so a match shows TW_ICON, a creation offer COL_ICON.
        def attach_resolution(otu, term, valid_name)
          otu.define_singleton_method(:_col_resolution) { { input: term, valid_name: } }
          otu
        end

      end
    end
  end
end
