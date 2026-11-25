module Match
  module Source
    class Field

      # The year, and its suffix (`1936a`). A suffix depends on the author's
      # other works in the bibliography it came from, so it's reported but
      # counts for little.
      class Year < Field

        def compare(row, source)
          {
            year_difference: (row.year && source.year) ?
              (row.year - source.year).abs : nil,
            year_suffix_match: (row.year_suffix && source.year_suffix) ?
              row.year_suffix == source.year_suffix : nil
          }
        end

        # The year is two thirds (half that a year apart), the suffix a third.
        def score(c)
          s = { 0 => 2, 1 => 1 }[c[:year_difference]].to_i
          s += 1 if c[:year_suffix_match]
          s / 3.0
        end

        def agrees?(c)
          c[:year_difference] == 0
        end

        def compared?(c)
          !c[:year_difference].nil?
        end

      end
    end
  end
end
