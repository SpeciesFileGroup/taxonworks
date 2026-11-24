module Match
  module Source
    class Field

      # The journal, as either the Source's `journal` or its Serial's name,
      # whichever is closer: compared to the row's journal when it has one,
      # otherwise looked for in the rest of a verbatim citation.
      class Journal < Field

        def prepare(_rows, sources)
          serial_names = ::Serial
            .where(id: sources.filter_map(&:serial_id).uniq)
            .pluck(:id, :name)
            .to_h

          # source id => the Source's journal names. The column, not
          # Source::Bibtex#journal, which loads the Serial of each Source.
          @names = sources.to_h { |s|
            [
              s.id,
              [s[:journal], serial_names[s.serial_id]]
                .filter_map { |n| InputRow.plain_text(n) }.uniq
            ]
          }
        end

        def compare(row, source)
          names = @names[source.id]

          {
            journal_similarity:
              if row.journal
                names.map { |n| similarity(row.journal, n) }.max
              elsif row.text
                names.map { |n| word_similarity(n, row.text) }.max
              end
          }
        end

        def score(c)
          c[:journal_similarity].to_f
        end

      end
    end
  end
end
