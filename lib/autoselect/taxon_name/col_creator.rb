module Autoselect
  module TaxonName
    # Creates TaxonName records (and CoL URI identifiers) from a Catalog of Life selection.
    #
    # Receives an ordered list of rows (distal → proximal, i.e. kingdom first, target last).
    # Each row represents one name to be created or an existing TaxonName to be used as a parent.
    # Rows with a taxonworks_id are already in the project and serve only as parent anchors.
    #
    # @param rows [Array<Hash>] ordered distal→proximal; each hash has:
    #   col_name      [String]  — scientific name string from CoL
    #   col_rank      [String]  — human-readable rank (e.g. 'genus', 'species')
    #   col_id        [String]  — CoL taxon ID used to build the identifier URI
    #   taxonworks_id [Integer, nil] — existing TaxonName ID; if present, no creation occurs for this row
    #   col_authorship [String, nil] — combined author+year string from CoL (e.g. 'Linnaeus, 1758')
    #   col_year      [String, nil]  — year string extracted from CoL combinationAuthorship (target row only)
    # @param project_id [Integer]
    # @param user_id [Integer]
    class ColCreator

      COL_BASE_URI = 'https://www.catalogueoflife.org/data/taxon/'.freeze

      def initialize(rows:, project_id:, user_id:)
        @rows       = rows
        @project_id = project_id.to_i
        @user_id    = user_id.to_i
      end

      # @return [Hash] { taxon_name_id: Integer, created_ids: Array<Integer> }
      def call
        # Seed parent_id from the project root so the topmost created name has a valid parent.
        parent_id   = project_root_id
        created_ids = []

        @rows.each do |row|
          if row[:taxonworks_id].present?
            parent_id = row[:taxonworks_id].to_i
            next
          end

          rank_class = resolve_rank_class(row[:col_rank])

          # Skip rows whose rank is entirely unknown to TaxonWorks — we cannot create a
          # valid Protonym without a rank_class (e.g. CoL-only ranks like 'domain').
          next if rank_class.nil?

          author, year = split_authorship(row[:col_authorship], row[:col_year])

          tn = ::TaxonName.create!(
            type:                'Protonym',
            name:                row[:col_name],
            parent_id:,
            rank_class:,
            verbatim_author:     author,
            year_of_publication: year,
            project_id:          @project_id,
            created_by_id:       @user_id,
            updated_by_id:       @user_id
          )

          if row[:col_id].present?
            ::Identifier.create!(
              type:              'Identifier::Global::Uri',
              identifier:        COL_BASE_URI + row[:col_id].to_s,
              identifier_object: tn,
              project_id:        @project_id,
              created_by_id:     @user_id,
              updated_by_id:     @user_id
            )
          end

          created_ids << tn.id
          parent_id = tn.id
        end

        { taxon_name_id: parent_id, created_ids: }
      end

      private

      # Returns the TaxonName id of the project's Root node.
      def project_root_id
        ::Project.find(@project_id).root_taxon_name.id
      end

      # Maps a human-readable CoL rank string to a TaxonWorks rank_class string.
      # Tries all nomenclatural code lookup constants in order so that any code's ranks resolve.
      # Returns nil for unknown ranks; callers should skip creation for those rows.
      def resolve_rank_class(rank_string)
        return nil if rank_string.blank?
        r = rank_string.to_s.downcase
        ::ICZN_LOOKUP[r] || ::ICN_LOOKUP[r] || ::ICNP_LOOKUP[r] || ::ICVCN_LOOKUP[r]
      end

      # Splits a CoL authorship string into [verbatim_author, year_of_publication].
      #
      # TaxonWorks Protonym validates that verbatim_author contains no digits, so the year
      # must be stored separately in year_of_publication.
      #
      # CoL provides authorship in two forms:
      #   "Linnaeus, 1758"                        → author "Linnaeus", year 1758
      #   "(Chatton, 1925) Whittaker & Margulis, 1978" → author "(Chatton) Whittaker & Margulis", year 1978
      #
      # An explicit col_year (from the target row's combinationAuthorship.year) takes precedence.
      # If no year can be extracted the author string is returned as-is with year nil.
      def split_authorship(col_authorship, col_year)
        return [nil, nil] if col_authorship.blank?

        # Prefer the explicit year already extracted server-side (present for the target row).
        year = col_year.presence&.to_i

        # Strip any trailing ", YYYY" or " YYYY" from the authorship string.
        # Also strip years embedded inside parenthetical groups, e.g. "(Chatton, 1925)".
        author = col_authorship
          .gsub(/,?\s*\b\d{4}\b/, '')   # remove ", 1925" and " 1925" occurrences
          .gsub(/\(\s*\)/, '')           # clean up empty parens left behind
          .gsub(/,\s*\z/, '')            # strip trailing comma
          .strip

        # If no explicit year was given, extract the last 4-digit year from the string
        # (the combination year, not the basionym year in parentheses).
        if year.nil?
          if (m = col_authorship.scan(/\b(\d{4})\b/).last)
            year = m[0].to_i
          end
        end

        author = nil if author.blank?
        [author, year]
      end

    end
  end
end
