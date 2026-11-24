module Match
  module Source
    class Field

      # The title: compared to the row's title when it has one, otherwise
      # looked for in the rest of a verbatim citation.
      class Title < Field

        def prepare(candidates)
          @similarities = Trigrams.evaluate(
            candidates.flat_map { |row, sources|
              sources.filter_map { |source| compared(row, source) }
            }
          )
        end

        def compare(row, source)
          { title_similarity: @similarities[compared(row, source)] }
        end

        def score(c)
          c[:title_similarity].to_f
        end

        private

        # @return [Array, nil] the comparison (see Trigrams.evaluate), nil when
        #   either side has no title to compare
        def compared(row, source)
          title = plain_title(source)
          return nil if title.nil?

          if row.title
            [row.title, title, :similarity]
          elsif row.text
            [title, row.text, :word_similarity]
          end
        end

        def plain_title(source)
          @plain_titles ||= {}
          return @plain_titles[source.id] if @plain_titles.key?(source.id)

          @plain_titles[source.id] =
            ::Utilities::Strings.plain_text(source.title)
        end

      end
    end
  end
end
