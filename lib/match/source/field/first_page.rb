module Match
  module Source
    class Field

      # The first page: the first number in a page range, `149` of `149-158`.
      class FirstPage < Field

        # @param value [String, nil] e.g. `149-158`, `p. 5`
        # @return [String, nil] e.g. `149`
        def self.number(value)
          value.to_s[/\d+/]
        end

        # Source pages with no number (`i-iv`) disagree with a row's page.
        def compare(row, source)
          {
            first_page_match: (row.first_page && source.pages.present?) ?
              row.first_page == self.class.number(source.pages) : nil
          }
        end

        def score(c)
          c[:first_page_match] ? 1.0 : 0.0
        end

      end
    end
  end
end
