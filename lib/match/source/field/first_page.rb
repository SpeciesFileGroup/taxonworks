module Match
  module Source
    class Field

      # The page: the row's first page against the Source's pages. It agrees
      # when it's the Source's first page (`149` of `149-158`), or within its
      # page range: a catalog cites the page a name is on (`152`), not the
      # first page of the work.
      class FirstPage < Field

        # A Source's page range, `149-158`, `149 - 158`, `149–158`.
        RANGE_PATTERN = /\A\D*?(\d+)\s*[-–—]\s*(\d+)/

        # Source pages with no number (`i-iv`) disagree with a row's page.
        def compare(row, source)
          {
            first_page_match: (row.first_page && source.pages.present?) ?
              page_agrees?(row.first_page, source.pages) : nil
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

        private

        def page_agrees?(page, source_pages)
          first_page = ::Utilities::Bibliography.first_page(source_pages)
          return true if page == first_page

          first, last = source_pages.match(RANGE_PATTERN)&.captures&.map(&:to_i)
          !first.nil? && last > first && page.to_i.between?(first, last)
        end

      end
    end
  end
end
