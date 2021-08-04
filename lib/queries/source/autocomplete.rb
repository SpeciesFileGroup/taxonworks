module Queries
  module Source
    class Autocomplete < Queries::Query

      # Either match against all Sources (default) or just those with ProjectSource
      # @return [Boolean]
      # @param limit_to_project [String] `true` or `false`
      attr_accessor :limit_to_project

      # @param [Hash] args
      def initialize(string, project_id: nil, limit_to_project: false)
        @limit_to_project = limit_to_project
        super
      end

      # @return [Scope]
      def base_query
        ::Source #.select('sources.*')
      end

      # @return [ActiveRecord::Relation]
      #   if and only iff author string matches
      def autocomplete_exact_author
        a = table[:cached_author_string].eq(query_string)
        base_query.where(a.to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      #   author matches any full word exactly
      def autocomplete_any_author
        a = table[:cached_author_string].matches_regexp('\m' + query_string + '\M')
        base_query.where(a.to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      #   author matches start
      def autocomplete_start_of_author
        a = table[:cached_author_string].matches(query_string + '%')
        base_query.where(a.to_sql).limit(8)
      end

      # @return [ActiveRecord::Relation]
      #   author matches partial string
      def autocomplete_partial_author
        a = table[:cached_author_string].matches('%' + query_string + '%')
        base_query.where(a.to_sql).limit(5)
      end

      # @return [ActiveRecord::Relation]
      #   multi-year match? otherwise pointless
      def autocomplete_year
        a = table[:year].eq_any(years)
        base_query.where(a.to_sql).limit(5)
      end

      # @return [ActiveRecord::Relation]
      #   title matches start
      def autocomplete_start_of_title
        a = table[:title].matches(query_string + '%')
        base_query.where(a.to_sql).limit(5)
      end

      # @return [ActiveRecord::Relation]
      #   author matches partial string
      def autocomplete_wildcard_pieces_and_year
        a = match_ordered_wildcard_pieces_in_cached
        b = match_year
        return nil if a.nil? || b.nil?
        c = a.and(b)
        base_query.where(c.to_sql).limit(5)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_year_letter
        a = match_year
        b = match_year_suffix
        return nil if a.nil? || b.nil?
        c = a.and(b)
        base_query.where(c.to_sql).limit(10)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_exact_author_year_letter
        a = match_exact_author
        b = match_year_suffix
        c = match_year
        return nil if [a,b,c].include?(nil)
        d = a.and(b).and(c)
        base_query.where(d.to_sql).limit(2)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_exact_author_year
        a = match_exact_author
        b = match_year
        return nil if a.nil? || b.nil?
        c = a.and(b)
        base_query.where(c.to_sql).limit(10)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_wildcard_author_exact_year
        a = match_year
        b = match_wildcard_author
        return nil if a.nil? || b.nil?
        c = a.and(b)
        base_query.where(c.to_sql).limit(10)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_wildcard_anywhere_exact_year
        a = match_year
        b = match_wildcard_in_cached
        return nil if a.nil? || b.nil?
        c = a.and(b)
        base_query.where(c.to_sql).limit(10)
      end

      # match ALL wildcards, but unordered, if 2 - 6 pieces provided
      # @return [Arel::Nodes::Matches]
      def match_wildcard_author
        b = fragments
        return nil if b.empty?
        a = table[:cached_author_string].matches_all(b)
      end

      # @return [Arel::Nodes::Equatity]
      def match_exact_author
        table[:cached_author_string].eq(author_from_author_year)
      end

      # @return [Arel::Nodes::Equatity]
      def match_year_suffix
        table[:year_suffix].eq(year_letter)
      end

      # @return [Arel::Nodes::Equatity]
      def match_year
        a = years.first
        return nil if a.nil?
        table[:year].eq(a)
      end

      # @return [String]
      def author_from_author_year
        query_string.match(/^(.+?)\W/).to_a.last
      end

      # @return [Arel::Nodes::Equatity]
      def member_of_project_id
        project_sources_table[:project_id].eq(project_id)
      end

      # @return [ActiveRecord::Relation, nil]
      #    if user provides 5 or fewer strings and any number of years look for any string && year
      def fragment_year_matches
        if fragments.any?
          s = table[:cached].matches_any(fragments)
          s = s.and(table[:year].eq_any(years)) if !years.empty?
          s
        else
          nil
        end
      end

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_exact_author_year_letter,
          autocomplete_exact_author_year,
          autocomplete_identifier_cached_exact, 
          autocomplete_wildcard_author_exact_year,
          autocomplete_exact_author,
          autocomplete_identifier_identifier_exact,
          autocomplete_exact_id,
          autocomplete_start_of_author,  
          autocomplete_wildcard_anywhere_exact_year,
          autocomplete_identifier_cached_like,
          autocomplete_ordered_wildcard_pieces_in_cached,
          autocomplete_cached_wildcard_anywhere,
          autocomplete_start_of_title
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q ,i|
          if project_id && limit_to_project
            a = q.joins(:project_sources).where(member_of_project_id.to_sql)
          else
            a = q.left_outer_joins(:citations)
                 .select('sources.*, COUNT(citations.id) AS use_count, MAX(citations.project_id) AS in_project_id')
                 .where('citations.project_id = ? OR citations.project_id IS NULL', Current.project_id)
                 .group('sources.id')
                 .order('in_project_id, use_count DESC')
          end
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result[0..19]
      end

      # @return [Arel::Table]
      def table
        ::Source.arel_table
      end

      # @return [Arel::Table]
      def project_sources_table
        ::ProjectSource.arel_table
      end
    end
  end
end
