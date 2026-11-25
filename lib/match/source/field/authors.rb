module Match
  module Source
    class Field

      # The authors: the first author's surname and initials, and every row
      # surname against every Source surname.
      class Authors < Field

        # Edit distances are reported up to this; anything larger is
        # reported as this.
        DISTANCE_CAP = 4

        # Max edits a match may allow: below the cap, whose value is
        # open-ended.
        MAX_EDITS = DISTANCE_CAP - 1

        # The first authors agree within this many edits, see #agrees?.
        AGREEING_DISTANCE = 1

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
            first_author_distance: distances.first&.first,
            author_distances: distances.map(&:min),
            # max edits => row authors paired with a Source author
            matched_author_counts: (0..MAX_EDITS).map { |edits|
              paired_count(distances, edits)
            },
            first_author_initials_match:
              initials_match(row.first_author_initials, source_initials),
            source_first_author_initials: source_initials,
            source_author_count: source_surnames.size
          }
        end

        # The first author is two thirds (half that with 1-2 edits), the share
        # of authors that agree a third.
        def score(c)
          s = 0.0
          s += 2 if c[:first_author_distance] == 0
          s += 1 if c[:first_author_distance]&.between?(1, 2)
          if c[:author_distances].any?
            s += c[:author_distances].count { |d| d&.zero? }.to_f /
              [c[:author_distances].size, c[:source_author_count]].max
          end
          s / 3.0
        end

        # The first author agrees, ignoring diacritics, case etc. (see
        # #distance) and up to AGREEING_DISTANCE edits (`Müler` / `Müller`).
        def agrees?(c)
          c[:first_author_distance].present? &&
            c[:first_author_distance] <= AGREEING_DISTANCE
        end

        private

        # Edit distance between two surnames, ignoring diacritics, case,
        # spaces, and punctuation (`Müller` = `Muller`, `De Long` = `DeLong`;
        # see #keys): the smallest distance between any key of `a` and any key
        # of `b`, capped at DISTANCE_CAP.
        def distance(a, b)
          @distances ||= {}
          @distances[[a, b]] ||= keys(a).product(keys(b)).map { |x, y|
            if x == y
              0
            elsif (x.length - y.length).abs >= DISTANCE_CAP
              DISTANCE_CAP
            else
              [DidYouMean::Levenshtein.distance(x, y), DISTANCE_CAP].min
            end
          }.min
        end

        # The whole name and each of its words, particles aside: one side may
        # cite only part of a compound surname (`García López` as `García`,
        # `Gomes Alves` as `Alves`, `van der Merwe` as `Merwe`).
        def keys(name)
          @keys ||= {}
          @keys[name] ||=
            [name, *::Utilities::AuthorNames.surname_words(name)]
              .map { |n| ::Utilities::AuthorNames.fold(n) }
              .reject(&:empty?).uniq
        end

        def surnames(source)
          @surnames ||= {}
          @surnames[source.id] ||=
            ::Utilities::AuthorNames.surnames(source.cached_author_string)
        end

        # A Source's `author` is BibTeX ("Last, Given and Last, Given").
        # `BibTeX::Names.parse` gives the list of names (nil if it can't
        # parse); its `.first` is the first author (a BibTeX::Name), whose
        # `.first` is that author's given names, e.g. "Franciscus Gerardus
        # Albertus Maria" from "Smit, Franciscus Gerardus Albertus Maria and
        # Jones, A."; nil when there are none ("Smit").
        def first_author_initials(source)
          @initials ||= {}
          @initials[source.id] ||= ::Utilities::AuthorNames.initials(
            BibTeX::Names.parse(source.author.to_s)&.first&.first
          )
        end

        # How many row authors can each be paired with a different Source
        # author, within max_edits: `Emery, Emery & Popple` finds 2 in `Emery,
        # Popple & Smith`, not 3.
        #
        # Pairing each row author with the first close Source author can
        # undercount: with 1 edit allowed, row `Smith, Smyth` against Source
        # `Smyth, Smit` pairs Smith-Smyth, leaving Smyth nothing. So when a row
        # author's Source author is taken, the row author holding it tries to
        # move to another (Smith to Smit), freeing it (Smyth-Smyth): 2 pairs.
        # (Kuhn's algorithm for bipartite matching; fine for author lists'
        # sizes.)
        #
        # @param distances [Array<Array>] per row author, the distance to each
        #   Source author
        # @return [Integer]
        def paired_count(distances, max_edits)
          paired_row = {} # Source author => row author paired with it

          distances.each_index.count { |row|
            pair(row, distances, max_edits, paired_row, Set.new)
          }
        end

        # Pairs `row` with a Source author within max_edits: a free one, or one
        # whose row author can move to another (Smith takes Smit so that Smyth
        # gets Smyth).
        #
        # @param paired_row [Hash] Source author => row author, updated
        # @param tried [Set] Source authors already tried while pairing this
        #   row, so that moves don't go round in circles
        # @return [Boolean] whether `row` was paired
        def pair(row, distances, max_edits, paired_row, tried)
          distances[row].each_with_index do |distance, source_author|
            next if distance.nil? || distance > max_edits ||
              tried.include?(source_author)

            tried << source_author
            holder = paired_row[source_author]
            if holder.nil? ||
                pair(holder, distances, max_edits, paired_row, tried)
              paired_row[source_author] = row
              return true
            end
          end
          false
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
