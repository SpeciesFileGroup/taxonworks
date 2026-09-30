# lib/autoselect/levels/col_resolved_name.rb
#
# Shared record_info rendering for the `col_valid_name` levels (Otu and TaxonName),
# which resolve a typed term through Catalogue of Life synonymy to its accepted
# name. Every result they return is a CoL result carrying what was typed
# (`_col_extension[:resolved_from]`), and this makes that provenance visible:
#
#   * a source mark — TW_ICON when the resolved name is already in TaxonWorks,
#     COL_ICON when it would be created (see ColSourceMark) — so it's always
#     clear the result came through CoL resolution, not a plain local match;
#   * a status badge, but only when CoL's status isn't 'accepted'. The level's
#     name promises a valid name, yet Vendor::Colrapi.resolve_accepted_name
#     resolves a top hit to itself unless it's a synonym with a single accepted
#     target (ambiguous synonyms, misapplied names, ...) — those must not look
#     like accepted names. An 'accepted' badge on every row would be noise;
#   * a rank badge, as on the catalogue_of_life levels;
#   * a "valid name for X" note, but only when CoL actually *changed* the name.
#     When what was typed already is the accepted name the note would imply a
#     difference that isn't there, so it's left off.
#
# The source mark comes first: without it, a note sitting next to whatever
# project-local info the record already carries gives no cue where it came from.
#
# The icons come from ColSourceMark, shared with the catalogue_of_life levels.
module Autoselect
  module Levels
    module ColResolvedName
      include ::Autoselect::Levels::ColSourceMark

      # @return [Array<String>] source tag ("TW"/"CoL"), then any non-accepted
      #   status, the rank, and a "valid name for X" note when CoL changed the
      #   name. Falls back to the ancestor's info for anything without CoL
      #   provenance.
      def record_info(record)
        return super if resolved_from(record).nil?

        [col_source_tag(record), *col_resolved_badges(record).map(&:first)]
      end

      # @return [String] same as #record_info, but the source tag is an inline
      #   brand-mark icon in front of styled feedback badges for the rest.
      def record_info_html(record)
        return super if resolved_from(record).nil?

        badges = col_resolved_badges(record).map do |text, modifier|
          col_resolved_feedback_badge(text, modifier)
        end
        col_source_icon(record) + badges.join(' ')
      end

      private

      # @return [Array<Array(String, Symbol)>] [text, feedback modifier] pairs
      #   for everything after the source mark, in display order
      def col_resolved_badges(record)
        extension = record._col_extension
        badges = []

        status = extension[:col_status].presence
        if status && !status.to_s.casecmp?('accepted')
          badges << [status, :warning]
        end

        if (rank = extension[:col_rank].presence)
          badges << [rank, :light]
        end

        if resolved_and_renamed?(record)
          badges << [%(valid name for "#{resolved_from(record)}"), :warning]
        end

        badges
      end

      # True when CoL actually changed the name — #resolved_from (what was typed)
      # differs from #valid_name_for (what the result shows). False both for
      # records with no CoL provenance and for the "typed exactly the accepted
      # name" case, where a "valid name for X" note would just be noise.
      def resolved_and_renamed?(record)
        input = resolved_from(record)
        valid = valid_name_for(record)
        return false if input.nil? || valid.nil?
        !input.casecmp?(valid)
      end

      # The raw text CoL resolved to produce this record. nil for anything
      # without CoL provenance.
      def resolved_from(record)
        return record._col_extension[:resolved_from] if record.respond_to?(:_col_extension)
        nil
      end

      # The name CoL actually resolved to (what the record shows, already set to
      # the resolved valid name).
      def valid_name_for(record)
        return record.name if record.respond_to?(:_col_extension)
        nil
      end

      def col_resolved_feedback_badge(text, modifier)
        "<span class=\"feedback feedback-thin feedback-#{modifier}\">#{ERB::Util.html_escape(text)}</span>"
      end

    end
  end
end
