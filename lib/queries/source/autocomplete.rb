module Queries
  module Source
    class Autocomplete < Query::Autocomplete

      # Either match against all Sources (default) or just those with ProjectSource
      # @return [Boolean]
      # @param limit_to_project [String] `true` or `false`
      attr_accessor :limit_to_project

      # Comes from sessions_current_project_id in UI
      attr_accessor :project_id

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
        a = table[:cached_author_string].matches(query_string)
        base_query.where(a.to_sql)
      end

      # @return [ActiveRecord::Relation]
      #   author matches any full word exactly
      #     !!  Not used currently
      def autocomplete_any_author
        a = table[:cached_author_string].matches_regexp('\m' + query_string + '\M')
        base_query.where(a.to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      #   author matches start
      def autocomplete_start_of_author
        a = table[:cached_author_string].matches(query_string + '%')
        base_query.where(a.to_sql)
      end

      # @return [ActiveRecord::Relation]
      #   author matches partial string
      #      !! Not used currently
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
        base_query.where(a.to_sql)
      end

      # @return [ActiveRecord::Relation]
      #   title matches wildcard on alternate
      def autocomplete_wildcard_of_title_alternate
        base_query.joins(:alternate_values).
          where("alternate_values.alternate_value_object_attribute = 'title' AND alternate_values.value ILIKE ?", '%' + query_string + '%')
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
        d = match_year_suffix
        c = match_year
        return nil if [a,d,c].include?(nil)
        z = a.and(d).and(c)
        base_query.where(z.to_sql)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_exact_author_year
        return nil if query_string.split(' ').count > 2
        a = match_exact_author
        d = match_year
        return nil if a.nil? || d.nil?
        z = a.and(d)
        base_query.where(z.to_sql)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_start_author_year
        return nil if query_string.split(' ').count > 2
        a = match_start_author
        d = match_year
        return nil if a.nil? || d.nil?
        z = a.and(d)
        base_query.where(z.to_sql)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_wildcard_author_exact_year
        return nil if query_string.split(' ').count > 2
        a = match_year
        d = match_wildcard_author
        return nil if a.nil? || d.nil?
        z = a.and(d)
        base_query.where(z.to_sql)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_exact_in_cached
        a = with_cached_like
        return nil if a.nil?
        base_query.where(a.to_sql)
      end

      # @return [ActiveRecord::Relation, nil]
      def autocomplete_wildcard_anywhere_exact_year
        a = match_year
        b = match_wildcard_in_cached
        return nil if a.nil? || b.nil?
        c = a.and(b)
        base_query.where(c.to_sql)
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
        table[:cached_author_string].matches(author_from_author_year)
      end

      # @return [Arel::Nodes::Equatity]
      def match_start_author
        a = author_from_author_year
        return nil if a.blank?
        table[:cached_author_string].matches(a + '%')
      end

      # @return [Arel::Nodes::Equatity]
      def match_year_suffix
        return nil if year_letter.blank?
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
        query_string.match(/[[[:word:]]]+/).to_a.last
        #query_string.match(/^(.+?)\W/).to_a.last
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

        # [ query, order by use if true- don't if nil ]
        queries = [
          [ autocomplete_exact_id, false],
          [ autocomplete_identifier_identifier_exact, false],
          [ autocomplete_exact_author_year_letter&.limit(20), true],
          [ autocomplete_identifier_cached_exact, false],
          [ autocomplete_exact_author_year&.limit(20), true],
          [ autocomplete_start_author_year&.limit(20), true],
          [ autocomplete_wildcard_author_exact_year&.limit(20), true],
          [ autocomplete_exact_author&.limit(20), true],
          [ autocomplete_start_of_author&.limit(20), true],
          #[ autocomplete_wildcard_anywhere_exact_year&.limit(10), true],
          [ autocomplete_identifier_cached_like, true],
          [ autocomplete_exact_in_cached&.limit(20), true],
          [ autocomplete_ordered_wildcard_pieces_in_cached&.limit(20), true],
          [ autocomplete_cached_wildcard_anywhere&.limit(20), true],
          [ autocomplete_start_of_title&.limit(20), true],
          [ autocomplete_wildcard_of_title_alternate&.limit(20), true]
        ]

        queries.delete_if{|a,b| a.nil?} # Note this pattern differs because [[]] so we don't use compact. /lib/queries/repository/autocomplete.rb follows same pattern

        result = []

        queries.each do |q, scope|
          a = q

          # Limit autocomplete to ONLY project sources if limit_to_project == true
          if project_id && limit_to_project
            a = a.joins(:project_sources).where(member_of_project_id.to_sql)
          end

          # Order results by number of times used *in this project*
          if project_id && scope
            a = a.left_outer_joins(:citations)
              .select("sources.*, COUNT(citations.id) AS use_count, CASE WHEN citations.project_id = #{Current.project_id} THEN citations.project_id ELSE NULL END AS in_project")
              .where('citations.project_id = ? OR citations.project_id IS DISTINCT FROM ?', project_id, project_id)
              .group('sources.id, citations.project_id')
              .order('in_project, use_count DESC')
          end

          a ||= q
          result += a.to_a
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
