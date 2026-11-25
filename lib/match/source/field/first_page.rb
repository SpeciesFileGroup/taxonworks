module Match
  module Source
    class Field

      # The first page: the first number in a page range, `149` of `149-158`.
      class FirstPage < Field

        # Source pages with no number (`i-iv`) disagree with a row's page.
        def compare(row, source)
          {
            first_page_match: (row.first_page && source.pages.present?) ?
              row.first_page ==
                ::Utilities::Bibliography.first_page(source.pages) : nil
          }
        end

        def score(c)
          c[:first_page_match] ? 1.0 : 0.0
        end

        def agrees?(c)
          c[:first_page_match] == true
        end

        def compared?(c)
          !c[:first_page_match].nil?
        end

      end
    end
  end
end
