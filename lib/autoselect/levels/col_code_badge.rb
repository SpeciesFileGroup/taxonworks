# lib/autoselect/levels/col_code_badge.rb
#
# The nomenclatural code badge (CoL's acronym for it, e.g. ICZN) on the
# results of the Catalogue of Life levels. It's shown only when a level's
# results span more than one code - the same name in two codes, e.g. Pieris,
# a butterfly and a plant - where the authorship alone can't tell them apart
# (CoL may have none for one of them).
#
# Whether to show it depends on every result, so a level marks its results
# once (.mark) and ColRecordInfo / ColResolvedName render the badge.
module Autoselect
  module Levels
    module ColCodeBadge

      # @param records [Array<OpenStruct>] CoL level pseudo-records
      # @return [Array<OpenStruct>] records; when they span more than one code
      #   each one with a known code gets _col_extension[:col_code_acronym]
      def self.mark(records)
        codes = records.map { |record| record._col_extension[:col_code] }
        return records if codes.compact.uniq.size < 2

        records.each do |record|
          extension = record._col_extension
          acronym = ::Vendor::Colrapi::COL_CODE_ACRONYMS[extension[:col_code]]
          next if acronym.nil?

          record._col_extension = extension.merge(col_code_acronym: acronym)
        end
      end

    end
  end
end
