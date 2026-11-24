module Match
  module Source
    class Field

      # The journal, as either the Source's `journal` or its Serial's name,
      # whichever is closer: compared to the row's journal when it has one,
      # otherwise looked for in the rest of a verbatim citation.
      class Journal < Field

        def prepare(candidates)
          sources = candidates.values.flatten.uniq
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
                .filter_map { |n| ::Utilities::Strings.plain_text(n) }.uniq
            ]
          }

          @similarities = Trigrams.evaluate(
            candidates.flat_map { |row, sources_of_row|
              sources_of_row.flat_map { |source| compared(row, source) }
            }
          )
        end

        def compare(row, source)
          comparisons = compared(row, source)

          {
            journal_similarity:
              if comparisons.any?
                comparisons.map { |c| @similarities[c] }.max
              end
          }
        end

        def score(c)
          c[:journal_similarity].to_f
        end

        private

        # @return [Array<Array>] the comparisons (see Trigrams.evaluate), one
        #   per journal name of the Source; empty when either side has none
        def compared(row, source)
          @names[source.id].filter_map { |name|
            if row.journal
              [row.journal, name, :similarity]
            elsif row.text
              [name, row.text, :word_similarity]
            end
          }
        end

      end
    end
  end
end
