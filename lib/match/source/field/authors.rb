module Match
  module Source
    class Field

      # The authors: the first author's surname and initials, and every row
      # surname against every Source surname.
      class Authors < Field

        # Edit distances are reported up to this; anything larger is
        # reported as this.
        DISTANCE_CAP = 4

        def self.source_columns
          %i{cached_author_string author}
        end

        def compare(row, source)
          source_surnames = surnames(source)
          first_input = row.surnames.first
          first_source = source_surnames.first
          source_initials = first_author_initials(source)
          # row surname => [distance to each Source surname]
          distances = row.surnames.map { |s|
            source_surnames.map { |t| distance(s, t) }
          }

          {
            first_author_exact: (first_input && first_source) ?
              first_input.squish == first_source.squish : nil,
            first_author_distance: (first_input && first_source) ?
              distance(first_input, first_source) : nil,
            author_distances: distances.map(&:min),
            author_distance_matrix: distances,
            first_author_initials_match:
              initials_match(row.first_author_initials, source_initials),
            source_first_author_initials: source_initials,
            source_author_count: source_surnames.size
          }
        end

        def score(c)
          s = 0.0
          s += 1.0 if c[:first_author_distance] == 0
          s += 0.5 if c[:first_author_distance]&.between?(1, 2)
          if c[:author_distances].any?
            s += 0.5 * c[:author_distances].count { |d| d&.zero? } /
              [c[:author_distances].size, c[:source_author_count]].max
          end
          s
        end

        private

        # Folded edit distance, also trying the last word of each name so that
        # `van der Merwe` matches `Merwe`; capped at DISTANCE_CAP.
        def distance(a, b)
          keys(a).product(keys(b)).map { |x, y|
            if x == y
              0
            elsif (x.length - y.length).abs >= DISTANCE_CAP
              DISTANCE_CAP
            else
              [DidYouMean::Levenshtein.distance(x, y), DISTANCE_CAP].min
            end
          }.min
        end

        def keys(name)
          @keys ||= {}
          @keys[name] ||=
            [name, name.split.last]
              .map { |n| ::Utilities::AuthorNames.fold(n) }
              .reject(&:empty?).uniq
        end

        def surnames(source)
          @surnames ||= {}
          @surnames[source.id] ||=
            ::Utilities::AuthorNames.surnames(source.cached_author_string)
        end

        # A Source's `author` is BibTeX ("Last, Given and Last, Given").
        def first_author_initials(source)
          @initials ||= {}
          @initials[source.id] ||= ::Utilities::AuthorNames.initials(
            BibTeX::Names.parse(source.author.to_s)&.first&.first
          )
        end

        # Lenient on purpose: people go by a later given name (Jordan, K. is
        # Heinrich Ernst Karl), and lists get middle initials wrong (Amarga,
        # A.C. is Ace Kevin S.); only initials with nothing in common
        # disagree.
        #
        # @return [Boolean, nil] nil when either has no initials, otherwise
        #   whether they share an initial
        def initials_match(a, b)
          return nil if a.empty? || b.empty?

          a.intersect?(b)
        end

      end
    end
  end
end
