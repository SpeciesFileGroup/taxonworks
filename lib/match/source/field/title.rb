module Match
  module Source
    class Field

      # The title: compared to the row's title when it has one, otherwise
      # looked for in the rest of a verbatim citation.
      class Title < Field

        def compare(row, source)
          title = plain_title(source)

          {
            title_similarity:
              if row.title
                similarity(row.title, title)
              elsif row.text
                word_similarity(title, row.text)
              end
          }
        end

        def score(c)
          c[:title_similarity].to_f
        end

        private

        def plain_title(source)
          @plain_titles ||= {}
          return @plain_titles[source.id] if @plain_titles.key?(source.id)

          @plain_titles[source.id] = InputRow.plain_text(source.title)
        end

      end
    end
  end
end
