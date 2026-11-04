# lib/autoselect/levels/col_record_info.rb
#
# Shared mixin for CoL level classes. Provides styled record_info_html using
# TaxonWorks feedback CSS classes to communicate CoL status at a glance, led by
# a TaxonWorks/CoL source mark (see ColSourceMark), with a code badge when the
# results span more than one code (see ColCodeBadge).
module Autoselect
  module Levels
    module ColRecordInfo
      include ::Autoselect::Levels::ColSourceMark

      def record_info(record)
        col_ext = record._col_extension
        return [] unless col_ext
        [
          col_ext[:col_status].presence,
          col_ext[:col_rank].presence,
          col_ext[:col_code_acronym]
        ].compact
      end

      def record_info_html(record)
        col_ext = record._col_extension
        return '' unless col_ext

        h = ApplicationController.helpers
        parts = []

        if (status = col_ext[:col_status].presence)
          # Anything other than an accepted name (synonym, ambiguous synonym,
          # misapplied, …) gets a more aggressive alert style to draw
          # attention to the nomenclatural caveat.
          type = status.to_s.casecmp?('accepted') ? :info : :warning
          parts << h.feedback_badge_tag(status, type)
        end

        if (rank = col_ext[:col_rank].presence)
          parts << h.feedback_badge_tag(rank, :light)
        end

        # Only when the results span more than one code, see ColCodeBadge.
        if (acronym = col_ext[:col_code_acronym])
          parts << h.feedback_badge_tag(acronym, :light)
        end

        col_source_icon(record) + parts.join(' ')
      end

    end
  end
end
