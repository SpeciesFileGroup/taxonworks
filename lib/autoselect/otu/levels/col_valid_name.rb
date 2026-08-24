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
      # Only ever included in the level stack when explicitly requested (see
      # Autoselect::Otu::Autoselect#levels) — this is a task-specific tool, not a
      # default search strategy for OTU fields generally.
      class ColValidName < ::Autoselect::Level

        # Source-of-truth marks for the info badge: TW_ICON for an existing-match
        # record (a real TaxonWorks record — CoL only helped find it), COL_ICON for
        # a creation offer (still purely CoL data, not yet in TW). Inlined rather
        # than <img src=...> so TW_ICON's embedded dark-mode media query resolves
        # against the page itself, the same as any other inline SVG.
        #
        # COL_ICON reuses the four-square mark from AutoselectField/CatalogueOfLifeSpinner.vue
        # (static, not animated). TW_ICON reuses app/assets/images/favicon.svg verbatim,
        # with its .st0 class renamed to avoid colliding with any other copy of that
        # same SVG already on the page.
        COL_ICON = <<~SVG.freeze
          <svg class="col-valid-name-source-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="13" height="13" style="vertical-align:-2px;margin-right:3px;">
            <rect fill="#305fc4" x="6.7" y="6.7" width="40" height="40"/>
            <rect fill="#ecdc59" x="53.3" y="6.7" width="40" height="40"/>
            <rect fill="#db3f3f" x="6.7" y="53.3" width="40" height="40"/>
            <rect fill="#53c652" x="53.3" y="53.3" width="40" height="40"/>
          </svg>
        SVG

        TW_ICON = <<~SVG.freeze
          <svg class="col-valid-name-source-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="13" height="13" style="vertical-align:-2px;margin-right:3px;">
            <style>.cvn-tw{fill-rule:evenodd;clip-rule:evenodd;fill:#454545}@media (prefers-color-scheme: dark){.cvn-tw{fill:#FFFFFF}}</style>
            <path class="cvn-tw" d="M21.5,80.7c12.9,0,17.7,17,17.7,17s6.5,19.8,19.6,19.8c9.9,0,12.1-8.1,12.5-11.6l0-0.5l0.1-1l0-0.2c0.5-4.7-3.5-6.2-3.5-6.2c-3.9-1.3-7.3-3.7-10.2-7.1c-8.2-9.5-3.8-21.8,5.8-30.2c-4.5-5.1-10.3-11.1-15.4-13.8C37,41,28,50.2,27.4,51l-0.1,0.2c-0.8,1.1-1.5,2.1-2.3,3.2l-0.1,0.1c-0.8,1.1-1.5,2.3-2.3,3.4l-0.1,0.2c-0.6,1-1.3,2-1.9,3.1c-1.5,2.5-2.9,5-4.2,7.6l-0.3,0.7c-0.6,1.1-1.1,2.3-1.6,3.4L14.4,73c-1.1,2.4-2.1,4.9-3.1,7.3l-0.3,0.8c-0.5,1.2-0.9,2.5-1.3,3.7l-0.2,0.5l-0.3,1C12,83.3,16,80.7,21.5,80.7"/>
            <path class="cvn-tw" d="M71.4,136.8c-0.3-2.7-0.5-5.4-0.6-8.1c-2.9,1.2-6.1,1.9-9.2,1.9c-24.4,0-25-24-33.6-37.3c-9-13.9-21.5,1.2-22.7,9.3c-0.1,0.4-0.1,0.7-0.2,0.9c-0.1,0.8-0.3,1.6-0.4,2.5l-0.1,1c-0.1,1-0.3,2-0.4,3c-0.2,1.7-0.4,3.3-0.5,5l0,0.4c-0.1,1.2-0.2,2.4-0.2,3.6c0,0.4,0,0.7,0,1.1c0,1.2-0.1,2.4-0.1,3.5l0,0.4v0.3c0,0.5,0,1,0,1.5c0,0.5,0,1,0,1.5c0,0.7,0,1.5,0.1,2.2l0,0.9c2,40.6,23.3,76,55,97.3c-10.2-10-16.3-22.7-16.3-36.5c0-17.2,9.4-33.2,24.4-44.1C70,144.9,71.8,140.9,71.4,136.8"/>
            <path class="cvn-tw" d="M167.5,217.6c-5.7,2.4-14,5-23.4,5.7c-1.4,0.1-2.8,0.1-4.3,0.1c-15.8,0-36.3-6.1-52.1-32.4l-2.1-3.4c-2.4,3.6-3.7,7.6-3.7,11.9c0,17.8,21.3,33.9,46.9,33.9c6.7,0,14.6-0.8,20.3-2.5c-5.9,3.7-17.7,7.1-28,7.1c-29.4,0-53.9-19.5-53.9-42.6c0-7.8,2.7-15.8,7.4-22.5c1.9-2.7,2.4-6.1,1.4-9.2c-13.5,7.8-21.7,19.8-21.7,34c0,22,19.6,40.8,47.3,48.5c1.6,0.3,3.2,0.6,4.7,0.9c20,3.3,37.8-0.2,49.9-11.7C161.4,230.5,165.1,224.5,167.5,217.6"/>
            <path class="cvn-tw" d="M222.3,43.3c13.5,18.9,20.7,41.6,20.7,64.8c0,41.7-22.8,78-56.6,97.2l-0.2,0.2c0-0.3,0-0.5,0.2-1.7c0.8-5,2.7-9.7,5.6-13.8c9.5-13.7,15.9-34.6-0.4-61.6c-9-14.9-27.7-35.9-66.2-51.3c-5-2-10-3.8-15.1-5.4l-2-0.6c-0.1,0-0.2-0.1-0.2-0.1c-1.3-0.4-2.6-0.8-4-1.2l-0.2-0.1c-1.3-0.4-2.5-0.7-3.7-1l-0.1,0c-0.6-0.2-1.1-0.3-1.7-0.4l-0.1,0c-1.2-0.3-2.3-0.6-3.5-0.9c-1-0.2-1.9-0.5-2.9-0.7l-0.2-0.1c-0.4-0.1-0.9-0.2-1.3-0.3L89,66.1l-0.2,0l-0.9-0.2l-0.2-0.1c-0.4-0.1-0.8-0.2-1.2-0.2c-0.2-0.1-0.5-0.1-0.7-0.1c-0.3-0.1-0.7-0.1-1-0.2l-0.2,0.5c-0.1,0.2-0.1,0.4-0.2,0.6l-0.1,0.2l-0.1,0.4l-0.1,0.3c0,0.1-0.1,0.3-0.1,0.4l-0.1,0.3l-0.1,0.4l-0.1,0.3l-0.1,0.5l-0.1,0.3l-0.2,0.6c0,0.1-0.1,0.3-0.1,0.4l-0.2,0.7c0,0.1-0.1,0.2-0.1,0.4L83,72.3c0,0.1-0.1,0.3-0.1,0.4c0,0.2-0.1,0.4-0.1,0.6l-0.1,0.5c0,0.2-0.1,0.4-0.1,0.5l-0.1,0.5c-0.1,0.2-0.1,0.4-0.1,0.6c0,0.2-0.1,0.3-0.1,0.5C82.1,76,82,76.2,82,76.4l-0.1,0.5l-0.2,0.7c0,0.2-0.1,0.4-0.1,0.7c-0.1,0.3-0.1,0.6-0.2,0.9l-0.1,0.5l-0.1,0.7L81,81l-0.1,0.7l-0.1,0.6c-0.1,0.2-0.1,0.4-0.1,0.7l-0.1,0.6l-0.1,0.7l-0.1,0.7c0,0.2-0.1,0.5-0.1,0.7c-0.1,0.5-0.2,1-0.3,1.5l-0.1,0.7L79.5,89l-0.1,0.6l-0.1,0.8c0,0.2-0.1,0.5-0.1,0.7L79,92l-0.1,0.7l-0.1,0.8l-0.1,0.7l-0.1,0.8c0,0.2-0.1,0.5-0.1,0.7l-0.1,0.9l-0.1,0.7l-0.1,1L78.1,99c-0.3,2.3-0.5,4.7-0.7,7l0,0.2c-0.1,0.7-0.1,1.4-0.2,2.2l0,0.1c-0.1,0.7-0.1,1.5-0.1,2.2l0,0.1c0,0.7-0.1,1.5-0.1,2.2l0,0c-0.2,3.9-0.3,8-0.2,12.2c0.1,5.2,0.4,10.7,1.1,16.3l0.2,1.4c0.9,7.4,2.5,14.7,4.6,21.8c1.6,4.9,4.2,11.8,6.7,16.9c1.1,2.2,2.3,4.4,3.6,6.5c11.8,19.6,27.5,29.5,46.8,29.5c1.3,0,2.7-0.1,4-0.1c11.6-0.8,21.2-4.9,25.9-7.2c6.3-31.3-10.7-75.9-46.2-113c-4.9-5.2-10.1-10.1-15.5-14.7c11.8,8.9,17.8,13.6,24.6,20.8c48.4,50.7,63.6,114.8,33.9,143.2c-4.4,4.2-9.6,7.4-15.3,9.6c7.5-2.1,14.2-5.8,19.7-11.1c1.8-1.7,3.4-3.5,4.8-5.4c45-18.8,76.7-63.2,76.7-115C252.4,94.7,241.7,65.9,222.3,43.3"/>
            <path class="cvn-tw" d="M189.9,43.4c2.8-1.6,6.7-1.2,9.9,1.2c3.2,2.4,4.6,6.1,3.9,9.2c-2.8,1.6-6.7,1.2-9.9-1.2C190.6,50.2,189.2,46.5,189.9,43.4 M49.6,42.2c6.8,2.3,14.6,8.7,20.1,14c3.5-2.1,7.3-3.6,11.3-4.6c-3.1-6.3-7.2-16.4-6.2-23.4C76.6,14,92.3,12.9,92.3,12.9S77.9,16,78.8,29.3c0.4,6.5,6,15.9,9.6,21.5c8.9-0.1,16.7,3.5,20.2,10.2c0.4,0.7,0.6,1.4,0.9,2.1h0c0,0,1.1,2.4,3,3.1c5,1.6,10,3.4,14.9,5.4c7.4,3,14.7,6.4,21.7,10.3c1.2,0.7,2.3-0.9,1.3-1.8c-34.9-33.5-10.2-46.5-10.2-46.5c-12.6,18.2,8.5,31.4,32.6,45c21.3,12,36.4,24.9,52.9,16.2c8.2-4.4,2.5-14-1.2-19.4c-2.8-4-4.7-6.5-7.2-11.8c-1.3-2.6-1.6-5.6-1-8.5c0.9-4-0.5-8.7-3.5-13.4c-2.2-3.5-6.5-7.3-9.8-9.8c-2.1-1.6-3.9-3.5-5.5-5.7C186.1,10,156.3,3.3,156.3,3.3v0C147,1.1,137.4,0,127.9,0c-19.9,0-38.7,4.7-55.4,13h0c-8.9,4.4-17.2,9.9-24.8,16.3l-1,0.8c-1.8,1.6-3.6,3.2-5.3,4.9l0,0c-1,1-2,2-2.9,3l0,0c-1.9,2-3.8,4-5.5,6.1l-0.2,0.3L32,45C35.6,42,41.3,39.5,49.6,42.2"/>
          </svg>
        SVG

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

        # @return [Array<String>] a source tag ("TW" for an existing match, "CoL" for
        #   a creation offer) for anything this level resolved via CoL — so it's
        #   always clear the result came through CoL resolution, not a plain local
        #   match — plus a "valid name for X" note when CoL actually changed the
        #   name (a genuine synonym/recombination). The note is left off when what
        #   was typed already *is* the valid name: seeing "valid name for X" implies
        #   a difference, and showing it when there isn't one is misleading, not just
        #   redundant. The default otu info for anything without CoL provenance at
        #   all. The source tag comes first — without it, an existing-match result
        #   sitting next to whatever project-local info (e.g. a "now <name>" synonym
        #   flag) the record already carries gives no visual cue where a note (when
        #   present) came from.
        def record_info(record)
          input = resolved_from(record)
          return super if input.nil?

          source = existing_match?(record) ? 'TW' : 'CoL'
          return [source] unless resolved_and_renamed?(record)
          [source, "valid name for \"#{input}\""]
        end

        # @return [String] the same as #record_info, but the source tag is an inline
        #   brand-mark icon (TW_ICON/COL_ICON) rather than text, in front of a styled
        #   feedback badge (matching Levels::ColRecordInfo) for the note when present.
        def record_info_html(record)
          input = resolved_from(record)
          return super if input.nil?

          icon = existing_match?(record) ? TW_ICON : COL_ICON
          return icon unless resolved_and_renamed?(record)
          "#{icon}#{feedback_badge(%(valid name for "#{input}"), :warning)}"
        end

        private

        def attach_resolution(otu, term, valid_name)
          otu.define_singleton_method(:_col_resolution) { { input: term, valid_name: } }
          otu
        end

        # True when CoL actually changed the name — i.e. #resolved_from (what was
        # typed) differs from #valid_name_for (what the result actually shows).
        # False both for records with no CoL provenance at all and for the
        # "typed exactly the accepted name" case, where a "valid name for X" note
        # would just be noise.
        def resolved_and_renamed?(record)
          input = resolved_from(record)
          valid = valid_name_for(record)
          return false if input.nil? || valid.nil?
          !input.casecmp?(valid)
        end

        # The raw text CoL resolved to produce this record — whether it's an
        # existing Otu match (#call attached _col_resolution) or a creation offer
        # (#call's TaxonName-level delegate set _col_extension[:resolved_from]).
        # nil for anything without CoL provenance.
        def resolved_from(record)
          return record._col_resolution[:input] if record.respond_to?(:_col_resolution)
          return record._col_extension[:resolved_from] if record.respond_to?(:_col_extension)
          nil
        end

        # The name CoL actually resolved to (what the record shows) — for an
        # existing match, stored on #call; for a creation offer, the record's own
        # name (#call already set it to the resolved valid name).
        def valid_name_for(record)
          return record._col_resolution[:valid_name] if record.respond_to?(:_col_resolution)
          return record.name if record.respond_to?(:_col_extension)
          nil
        end

        # True for a real, already-existing Otu record; false for a creation offer
        # (still purely CoL data, not yet in TW). Only meaningful once
        # #resolved_and_renamed? has already confirmed the record has CoL provenance.
        def existing_match?(record)
          record.respond_to?(:_col_resolution)
        end

        def feedback_badge(text, modifier)
          "<span class=\"feedback feedback-thin feedback-#{modifier}\">#{ERB::Util.html_escape(text)}</span>"
        end

      end
    end
  end
end
