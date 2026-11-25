module Match
  module Source
    class Field

      # The title: compared to the row's title when it has one, otherwise
      # looked for in the rest of a verbatim citation.
      class Title < Field

        # Similar enough to agree, as the Match sources task's default
        # minimum title similarity.
        AGREEING_SIMILARITY = 0.6

        def prepare(candidates)
          @similarities = ::Utilities::Rails::Trigrams.evaluate(
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

        def agrees?(c)
          c[:title_similarity].to_f >= AGREEING_SIMILARITY
        end

        def compared?(c)
          !c[:title_similarity].nil?
        end

        private

        # A verbatim citation's title isn't split out (see
        # InputRow#unparsed_text), so the Source's title is looked for in all
        # of the row's unparsed text: word_similarity scores the stretch most
        # like the title, so the journal etc. around it don't count against it.
        #
        # @return [Array, nil] the comparison (see
        #   Utilities::Rails::Trigrams.evaluate); nil when the Source has no
        #   title, or the row has neither a title nor unparsed text
        def compared(row, source)
          title = plain_title(source)
          return nil if title.nil?

          if row.title
            [row.title, title, :similarity]
          elsif row.unparsed_text
            [title, row.unparsed_text, :word_similarity]
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
