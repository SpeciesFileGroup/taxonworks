# lib/autoselect/levels/col_resolved_name.rb
#
# Shared record_info rendering for the `col_valid_name` levels (Otu and TaxonName),
# which resolve a typed term through Catalogue of Life synonymy to its accepted
# name. Every result they return is a CoL result carrying what was typed
# (`_col_extension[:resolved_from]`), and this makes that provenance visible:
#
#   * a source mark — TW_ICON when the resolved name is already in TaxonWorks,
#     COL_ICON when it would be created;
#   * a status badge, but only when CoL's status isn't 'accepted' (i.e.
#     'provisionally accepted' - Vendor::Colrapi.resolve_accepted_names gives
#     nothing else). An 'accepted' badge on every row would be noise;
#   * a rank badge, as on the catalogue_of_life levels;
#   * a code badge when the results span more than one code (ColCodeBadge);
#   * a "valid name for X" note, but only when CoL actually followed synonymy,
#     X being the synonym CoL matched, with its authorship
#     (`_col_extension[:resolved_synonym]`) - homonyms resolve to different
#     names, e.g. Abies alba (Aiton) Michx. to Picea glauca.
#     What was typed is a poor stand-in: a partial, authored, or subgenus-form
#     term differs from the result without any synonymy involved.
#   * an "ambiguous synonym" badge after the note when X is one: this is
#     only one of its valid names (e.g. a pro parte synonym gives a row per
#     target).
#
module Autoselect
  module Levels
    module ColResolvedName
      include ::Autoselect::Levels::ColSourceMark

      # @return [Array<String>] source tag ("TW"/"CoL"), then any non-accepted
      #   status, the rank, the code (see ColCodeBadge), and a "valid name for
      #   X" note when CoL followed synonymy (then "ambiguous synonym" when X
      #   is one). Falls back to the ancestor's info for anything without CoL
      #   provenance.
      def record_info(record)
        return super if resolved_from(record).nil?

        [col_source_tag(record), *col_resolved_badges(record).map(&:first)]
      end

      # @return [String] same as #record_info, but the source tag is an inline
      #   brand-mark icon in front of styled feedback badges for the rest.
      def record_info_html(record)
        return super if resolved_from(record).nil?

        h = ApplicationController.helpers
        badges = col_resolved_badges(record).map do |text, type|
          h.feedback_badge_tag(text, type)
        end
        col_source_icon(record) + badges.join(' ')
      end

      private

      # @return [Array<Array(String, Symbol)>] [text, feedback type] pairs
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

        if (acronym = extension[:col_code_acronym])
          badges << [acronym, :light]
        end

        if (synonym = resolved_synonym(record))
          badges << [%(valid name for "#{synonym}"), :warning]
          if record._col_extension[:resolved_ambiguous]
            badges << ['ambiguous synonym', :warning]
          end
        end

        badges
      end

      # The synonym CoL matched and followed to this record's valid name. nil
      # when CoL didn't follow synonymy, or for anything without CoL provenance.
      def resolved_synonym(record)
        return nil if resolved_from(record).nil?
        record._col_extension[:resolved_synonym].presence
      end

      # The raw text CoL resolved to produce this record. nil for anything
      # without CoL provenance.
      def resolved_from(record)
        if record.respond_to?(:_col_extension)
          return record._col_extension[:resolved_from]
        end
        nil
      end

    end
  end
end
