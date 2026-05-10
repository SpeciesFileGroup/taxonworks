# lib/autoselect/levels/col_record_info.rb
#
# Shared mixin for CoL level classes. Provides styled record_info_html using
# TaxonWorks feedback CSS classes to communicate CoL status at a glance.
module Autoselect
  module Levels
    module ColRecordInfo

      def record_info(record)
        col_ext = record._col_extension
        return [] unless col_ext
        [col_ext[:col_status].presence, col_ext[:col_rank].presence].compact
      end

      def record_info_html(record)
        col_ext = record._col_extension
        return '' unless col_ext

        parts = []

        if (status = col_ext[:col_status].presence)
          parts << "<span class=\"feedback feedback-thin feedback-info\">#{ERB::Util.html_escape(status)}</span>"
        end

        if (rank = col_ext[:col_rank].presence)
          parts << "<span class=\"feedback feedback-thin feedback-light\">#{ERB::Util.html_escape(rank)}</span>"
        end

        parts.join(' ')
      end

    end
  end
end
