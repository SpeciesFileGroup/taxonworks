module Match
  module Source
    class Field

      # The year, and its suffix (`1936a`). A suffix depends on the author's
      # other works in the bibliography it came from, so it's reported but
      # counts for little.
      class Year < Field

        def self.source_columns
          %i{year year_suffix}
        end

        def compare(row, source)
          {
            year_difference: (row.year && source.year) ?
              (row.year - source.year).abs : nil,
            year_suffix_match: (row.year_suffix && source.year_suffix) ?
              row.year_suffix == source.year_suffix : nil
          }
        end

        def score(c)
          s = { 0 => 1.0, 1 => 0.5 }[c[:year_difference]].to_f
          s += 0.5 if c[:year_suffix_match]
          s
        end

      end
    end
  end
end
